# Portfolio de Angel Salinas

Portafolio personal desarrollado con **Astro** y **Tailwind CSS**, desplegado en **AWS S3 + CloudFront**.

## Características

- **Diseño Moderno**: Animación de fondo estilo lámpara de lava con colores morados
- **Efecto de Tipeo CLI**: Animación de terminal para presentar el nombre
- **100% Estático**: Generado con Astro para máximo performance
- **Responsive**: Optimizado para todos los dispositivos
- **Bajo Costo**: ~$1-2/mes en AWS

## Stack Tecnológico

- **Framework**: [Astro](https://astro.build) v5
- **Estilos**: [Tailwind CSS](https://tailwindcss.com) v4
- **Hosting**: AWS S3 + CloudFront
- **Deployment**: Script automatizado bash

## Desarrollo Local

### Requisitos
- Node.js 18+
- npm o yarn

### Instalación

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev
```

El sitio estará disponible en `http://localhost:4321`

### Scripts Disponibles

```bash
npm run dev      # Servidor de desarrollo
npm run build    # Build de producción
npm run preview  # Preview del build
npm run deploy   # Deploy a AWS (ver DEPLOY.md)
```

## Despliegue en AWS

Para desplegar en AWS S3 + CloudFront:

1. Lee la guía completa en [DEPLOY.md](./DEPLOY.md)
2. Edita `deploy.sh` con tus valores de AWS
3. Ejecuta el deploy:

```bash
npm run deploy
```

## Estructura del Proyecto

```
/
├── public/             # Archivos estáticos (imágenes, favicon)
│   └── profile.jpg     # Foto de perfil
├── src/
│   ├── pages/          # Páginas de Astro
│   │   └── index.astro # Página principal
│   └── styles/         # Estilos globales
│       └── global.css  # CSS con animaciones
├── deploy.sh           # Script de deployment
├── DEPLOY.md           # Guía de despliegue
└── package.json
```

## Personalización

### Cambiar Información Personal

Edita `src/pages/index.astro`:

- **Nombre**: Línea 158 - cambia `"Angel Salinas"`
- **Título**: Línea 45 - cambia `"Desarrollador Full Stack"`
- **Descripción**: Líneas 48-51
- **Skills**: Líneas 89-108
- **GitHub URL**: Línea 62

### Cambiar Colores

Edita `src/styles/global.css`:

```css
:root {
  --color-primary: #8b5cf6;      /* Color principal (morado) */
  --color-primary-dark: #7c3aed;
  --color-primary-light: #a78bfa;
  --color-secondary: #5b9dff;     /* Color secundario (azul) */
  --color-secondary-dark: #3b82f6;
}
```

### Cambiar Foto de Perfil

Reemplaza `public/profile.jpg` con tu foto (recomendado: 500x500px)

## Animaciones

### Lámpara de Lava
Implementada con CSS puro usando:
- `filter: blur(120px)` para difuminado
- Gradientes radiales para los colores
- Keyframes para movimiento orgánico
- Dos blobs que flotan durante 35s y 40s

### Efecto de Tipeo
JavaScript vanilla que:
- Escribe letra por letra el nombre
- Cursor parpadeante con animación CSS
- 150ms de delay entre caracteres

## Performance

- **100/100** en Lighthouse Performance (generalmente)
- **Tamaño del build**: ~150KB (sin imágenes)
- **First Contentful Paint**: <1s
- **Time to Interactive**: <1.5s

## Costos Estimados en AWS

- **S3**: $0.50 - $1.00/mes
- **CloudFront**: $0.50 - $1.00/mes (1TB gratis primeros 12 meses)
- **Total**: ~$1-2/mes

## Próximas Mejoras

- [ ] Integración con GitHub API para proyectos dinámicos
- [ ] Blog con Astro Content Collections
- [ ] Dark/Light mode toggle
- [ ] Formulario de contacto
- [ ] SEO avanzado con Open Graph
- [ ] CI/CD con GitHub Actions

## Licencia

MIT - Siéntete libre de usar este template para tu propio portafolio

## Contacto

**Angel Salinas**
- GitHub: [@angelsalinas](https://github.com/angelsalinas)
- Portfolio: [Tu URL de CloudFront aquí]

---

Hecho con ❤️ usando Astro y desplegado en AWS
