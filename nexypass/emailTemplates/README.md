# 📧 Plantillas de Email - NexyPass

Este directorio contiene las plantillas de email personalizadas para NexyPass, diseñadas para mejorar la experiencia del usuario y reforzar la identidad de marca.

## 📁 Archivos Disponibles

### `verifyEmail.html`
Plantilla para el correo de verificación de cuenta que se envía cuando un usuario se registra.

**Características:**
- ✨ Diseño moderno y responsivo
- 🎯 Branding consistente con NexyPass
- 🎁 Lista de beneficios y promociones
- 📱 Optimizado para móviles y escritorio
- 🔗 Botón CTA prominente + enlace de respaldo
- 📞 Información de contacto y redes sociales

### `welcomeEmail.html`
Plantilla para el correo de bienvenida que se envía después de que el usuario verifica su cuenta.

**Características:**
- 🎉 Celebración de cuenta verificada
- 🎯 Guía de próximos pasos
- 🎁 Showcase de premios disponibles
- 📱 Enlaces directos a funciones principales
- 🌐 Promoción de redes sociales
- 🛟 Información de soporte 24/7

## 🚀 Cómo Implementar

### Paso 1: Acceder a Supabase
1. Inicia sesión en tu dashboard de Supabase
2. Ve a **Authentication > Email Templates**

### Paso 2: Configurar las Plantillas

#### Para Email de Verificación:
1. Selecciona **"Confirm signup"** (Confirmar registro)
2. Abre el archivo `verifyEmail.html`
3. Copia todo el contenido HTML
4. Pégalo en el campo **"Email template"** de Supabase
5. Configura el **Subject** como: `Verifica tu cuenta - NexyPass 🚀`
6. Haz clic en **"Save"**

#### Para Email de Bienvenida (Opcional):
1. En tu aplicación, puedes enviar el email de bienvenida programáticamente
2. Usa el archivo `welcomeEmail.html` como base
3. Configura el **Subject** como: `¡Bienvenido a NexyPass! Tu cuenta está lista 🎉`
4. Envía este email después de que el usuario complete la verificación

### Paso 3: Probar
1. **Email de Verificación:**
   - Registra un usuario de prueba desde la app
   - Verifica que el email se reciba con el nuevo diseño
   - Confirma que el botón de verificación funciona correctamente

2. **Email de Bienvenida:**
   - Completa el proceso de verificación
   - Verifica que el email de bienvenida se envíe (si está implementado)
   - Confirma que los enlaces a la ruleta y catálogo funcionan

## 🎨 Personalización

### Colores Principales
- **Azul Principal:** `#667eea`
- **Púrpura:** `#764ba2`
- **Texto Oscuro:** `#2d3748`
- **Texto Claro:** `#4a5568`

### Fuentes
- **Principal:** Segoe UI, Tahoma, Geneva, Verdana, sans-serif
- **Tamaños:** 32px (logo), 24px (títulos), 16px (texto)

### Elementos Clave
- **Logo:** "NexyPass" con gradiente
- **Tagline:** "Tu Universo Digital, Simplificado"
- **CTA Button:** Gradiente azul-púrpura con sombra
- **Beneficios:** 6 elementos con iconos emoji

## 🔧 Variables de Supabase

La plantilla utiliza estas variables que Supabase reemplaza automáticamente:

```html
{{ .ConfirmationURL }}  <!-- Enlace de verificación -->
{{ .Token }}           <!-- Token de verificación -->
{{ .TokenHash }}       <!-- Hash del token -->
{{ .SiteURL }}         <!-- URL del sitio -->
{{ .Email }}           <!-- Email del usuario -->
```

## 📱 Compatibilidad

La plantilla está optimizada para:
- ✅ Gmail (Web y móvil)
- ✅ Outlook (Web y móvil)
- ✅ Apple Mail
- ✅ Yahoo Mail
- ✅ Clientes de email móviles
- ✅ Modo oscuro/claro

## 🛠️ Solución de Problemas

### El email no se ve correctamente
- Verifica que copiaste todo el HTML completo
- Asegúrate de que no hay caracteres especiales corruptos
- Prueba con diferentes clientes de email

### Las variables no se reemplazan
- Confirma que usas la sintaxis correcta: `{{ .VariableName }}`
- Revisa la documentación de Supabase para variables actualizadas
- Verifica que la configuración de autenticación esté correcta

### El botón no funciona
- Asegúrate de que `{{ .ConfirmationURL }}` esté correctamente configurado
- Verifica que la URL de redirección esté configurada en Supabase
- Prueba el enlace de respaldo en texto plano

## 📞 Soporte

Si necesitas ayuda con la implementación:
- 📱 WhatsApp: +52 9514563572
- 📧 Revisa la documentación en `GUIA_SUPABASE.md`
- 🌐 Consulta la documentación oficial de Supabase

## 🔄 Actualizaciones Futuras

Para actualizar la plantilla:
1. Modifica el archivo `verifyEmail.html`
2. Copia el nuevo contenido
3. Actualiza la plantilla en Supabase
4. Prueba con un registro de prueba
5. Documenta los cambios aquí

---

**Última actualización:** Diciembre 2024  
**Versión:** 1.0  
**Compatibilidad:** Supabase Auth v2+
