# Guía de Despliegue en AWS S3 + CloudFront

## Resumen de Costos
- **S3**: ~$0.50 - $1.00/mes (almacenamiento + transferencia mínima)
- **CloudFront**: ~$0.50 - $1.00/mes (CDN con 1TB gratis los primeros 12 meses)
- **Route53** (opcional): ~$0.50/mes si usas dominio personalizado
- **Total estimado: $1-2/mes**

---

## Paso 1: Build del Proyecto

Primero genera los archivos estáticos:

```bash
npm run build
```

Esto creará la carpeta `dist/` con todos los archivos optimizados.

---

## Paso 2: Crear Bucket de S3

### 2.1 Desde AWS Console:

1. Ve a [S3 Console](https://s3.console.aws.amazon.com/)
2. Click en "Create bucket"
3. Configuración:
   - **Bucket name**: `mi-portfolio-angel` (debe ser único globalmente)
   - **Region**: `us-east-1` (recomendado para CloudFront)
   - **Block all public access**: DESMARCAR (necesitamos acceso público)
   - Confirma que entiendes que el bucket será público
4. Click "Create bucket"

### 2.2 Configurar Bucket para Hosting:

1. Entra al bucket creado
2. Ve a la pestaña "Properties"
3. Scroll hasta "Static website hosting"
4. Click "Edit":
   - Enable: "Static website hosting"
   - Hosting type: "Host a static website"
   - Index document: `index.html`
   - Error document: `404.html` (opcional)
5. Guarda los cambios

### 2.3 Configurar Permisos del Bucket:

1. Ve a la pestaña "Permissions"
2. En "Bucket policy", click "Edit"
3. Pega esta política (reemplaza `mi-portfolio-angel` con tu nombre de bucket):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mi-portfolio-angel/*"
    }
  ]
}
```

4. Guarda los cambios

---

## Paso 3: Subir Archivos a S3

### Opción A: Usando AWS CLI (Recomendado)

1. Instala AWS CLI si no lo tienes:
```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

2. Configura tus credenciales:
```bash
aws configure
# Ingresa:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

3. Sube los archivos:
```bash
aws s3 sync dist/ s3://mi-portfolio-angel --delete
```

### Opción B: Usando la Consola Web

1. Ve a tu bucket en S3
2. Click "Upload"
3. Arrastra todos los archivos de la carpeta `dist/`
4. Click "Upload"

---

## Paso 4: Configurar CloudFront (CDN)

### 4.1 Crear Distribución:

1. Ve a [CloudFront Console](https://console.aws.amazon.com/cloudfront/)
2. Click "Create distribution"
3. Configuración:

**Origin Settings:**
- **Origin domain**: Selecciona tu bucket S3 (o pega la URL del endpoint de website)
- **Name**: Déjalo automático
- **Origin access**: Public (tu bucket ya es público)

**Default cache behavior:**
- **Viewer protocol policy**: Redirect HTTP to HTTPS
- **Allowed HTTP methods**: GET, HEAD
- **Cache policy**: CachingOptimized

**Settings:**
- **Price class**: Use all edge locations (mejor performance) o "Use only North America and Europe" (más económico)
- **Alternate domain name (CNAME)**: Déjalo vacío por ahora (o agrega tu dominio si tienes)
- **SSL Certificate**: Default CloudFront certificate
- **Default root object**: `index.html`

4. Click "Create distribution"
5. **Espera 5-15 minutos** mientras se despliega globalmente

### 4.2 Obtener URL de CloudFront:

1. Una vez que el estado sea "Deployed"
2. Copia el "Distribution domain name" (ej: `d111111abcdef8.cloudfront.net`)
3. **Esta es tu URL pública!**

---

## Paso 5: Configurar Error Pages (Opcional pero Recomendado)

Para que las rutas de Astro funcionen correctamente:

1. En CloudFront, ve a tu distribución
2. Pestaña "Error pages"
3. Click "Create custom error response":
   - **HTTP error code**: 404
   - **Customize error response**: Yes
   - **Response page path**: `/index.html`
   - **HTTP Response code**: 200
4. Repite para error 403

---

## Paso 6: Dominio Personalizado (Opcional)

Si tienes un dominio (ej: `angelsalinas.com`):

### Usando Route53:

1. Ve a [Route53 Console](https://console.aws.amazon.com/route53/)
2. Si tu dominio está en Route53:
   - Crea un registro A con Alias apuntando a CloudFront
3. Si tu dominio está en otro registrar:
   - Crea un CNAME apuntando a tu URL de CloudFront

### Actualizar CloudFront:

1. Edita tu distribución
2. En "Alternate domain names (CNAMEs)": agrega `www.angelsalinas.com`
3. En SSL Certificate:
   - Click "Request certificate" (ACM)
   - Valida el dominio
   - Selecciona el certificado creado
4. Guarda cambios

---

## Script de Deployment Automático

He creado un script `deploy.sh` para automatizar el despliegue:

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Comandos Útiles

### Actualizar el sitio:
```bash
npm run build
aws s3 sync dist/ s3://mi-portfolio-angel --delete
aws cloudfront create-invalidation --distribution-id TU_DISTRIBUTION_ID --paths "/*"
```

### Invalidar caché de CloudFront:
```bash
aws cloudfront create-invalidation --distribution-id TU_DISTRIBUTION_ID --paths "/*"
```

### Ver logs de S3:
```bash
aws s3 ls s3://mi-portfolio-angel/
```

---

## Troubleshooting

### El sitio muestra "403 Forbidden":
- Verifica que la bucket policy esté correcta
- Verifica que "Block all public access" esté desactivado

### CloudFront muestra error 404:
- Verifica que el "Default root object" sea `index.html`
- Configura las error pages como se indica arriba

### Los cambios no se ven:
- Invalida el caché de CloudFront
- Espera 5-10 minutos para que se propague

### Costos inesperados:
- Revisa el CloudFront price class
- Considera usar solo regiones específicas
- Activa CloudFront logs solo si es necesario

---

## Monitoreo de Costos

1. Ve a [AWS Cost Explorer](https://console.aws.amazon.com/cost-management/)
2. Activa "Free Tier" alerts
3. Configura budget alerts para $5/mes

---

## Próximos Pasos

1. Conecta GitHub Actions para CI/CD automático
2. Agrega Google Analytics
3. Optimiza imágenes con servicios como Cloudinary
4. Considera usar AWS Amplify como alternativa más simple
