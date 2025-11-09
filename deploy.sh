#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración (EDITA ESTOS VALORES)
BUCKET_NAME="mi-portfolio-angel"  # Cambia esto por el nombre de tu bucket
DISTRIBUTION_ID=""  # Agrega tu CloudFront distribution ID aquí (opcional)

echo -e "${YELLOW}🚀 Iniciando deployment...${NC}\n"

# Verificar que existe el bucket name
if [ "$BUCKET_NAME" = "mi-portfolio-angel" ]; then
  echo -e "${RED}⚠️  IMPORTANTE: Debes editar deploy.sh y cambiar BUCKET_NAME por el nombre de tu bucket${NC}"
  exit 1
fi

# 1. Build del proyecto
echo -e "${YELLOW}📦 Construyendo el proyecto...${NC}"
npm run build

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Error en el build${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Build completado${NC}\n"

# 2. Verificar que AWS CLI está instalado
if ! command -v aws &> /dev/null; then
  echo -e "${RED}❌ AWS CLI no está instalado${NC}"
  echo -e "Instálalo con: ${YELLOW}brew install awscli${NC}"
  exit 1
fi

# 3. Verificar que AWS está configurado
if ! aws s3 ls &> /dev/null; then
  echo -e "${RED}❌ AWS CLI no está configurado${NC}"
  echo -e "Configúralo con: ${YELLOW}aws configure${NC}"
  exit 1
fi

# 4. Sincronizar archivos con S3
echo -e "${YELLOW}☁️  Subiendo archivos a S3...${NC}"
aws s3 sync dist/ s3://$BUCKET_NAME --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" \
  --exclude "*.xml"

# HTML y XML sin caché agresivo
aws s3 sync dist/ s3://$BUCKET_NAME --delete \
  --cache-control "public, max-age=0, must-revalidate" \
  --exclude "*" \
  --include "*.html" \
  --include "*.xml"

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Error al subir archivos a S3${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Archivos subidos a S3${NC}\n"

# 5. Invalidar caché de CloudFront (si está configurado)
if [ ! -z "$DISTRIBUTION_ID" ]; then
  echo -e "${YELLOW}🌐 Invalidando caché de CloudFront...${NC}"
  aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" \
    --output json > /dev/null

  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al invalidar CloudFront${NC}"
    exit 1
  fi

  echo -e "${GREEN}✓ Caché invalidado${NC}\n"
else
  echo -e "${YELLOW}⚠️  CloudFront distribution ID no configurado. Saltando invalidación.${NC}\n"
fi

# 6. Mostrar URLs
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment completado exitosamente!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "📍 ${YELLOW}URLs:${NC}"
echo -e "   S3: http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"

if [ ! -z "$DISTRIBUTION_ID" ]; then
  CF_URL=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'Distribution.DomainName' --output text 2>/dev/null)
  if [ ! -z "$CF_URL" ]; then
    echo -e "   CloudFront: https://$CF_URL"
  fi
fi

echo -e "\n${GREEN}🎉 Tu portafolio está en vivo!${NC}\n"
