# 📧 Configuración Completa de Email Templates - NexyPass

Esta guía contiene todas las configuraciones necesarias para implementar las plantillas de email en Supabase.

## 🚀 Plantillas Disponibles

### 1. **Confirm Signup** (Confirmar registro)
- **Archivo:** `verifyEmail.html`
- **Subject:** `Verifica tu cuenta - NexyPass 🚀`
- **Descripción:** Email de verificación enviado al registrarse

### 2. **Invite User** (Invitar usuario)
- **Archivo:** `inviteUser.html`
- **Subject:** `¡Has sido invitado a NexyPass! 🎉`
- **Descripción:** Invitación para nuevos usuarios

### 3. **Magic Link** (Enlace mágico)
- **Archivo:** `magicLink.html`
- **Subject:** `Tu enlace de acceso a NexyPass ✨`
- **Descripción:** Acceso sin contraseña

### 4. **Change Email** (Cambiar email)
- **Archivo:** `changeEmail.html`
- **Subject:** `Confirma tu nuevo email - NexyPass 📧`
- **Descripción:** Confirmación de cambio de email

### 5. **Reset Password** (Restablecer contraseña)
- **Archivo:** `resetPassword.html`
- **Subject:** `Restablece tu contraseña - NexyPass 🔐`
- **Descripción:** Recuperación de contraseña

### 6. **Reauthenticate** (Reautenticación)
- **Archivo:** `reauthenticate.html`
- **Subject:** `Verificación de seguridad requerida - NexyPass 🛡️`
- **Descripción:** Verificación de seguridad adicional

---

## 📋 Pasos de Implementación

### Paso 1: Acceder a Supabase
1. Ve a https://supabase.com
2. Selecciona tu proyecto NexyPass
3. Ve a **Authentication > Email Templates**

### Paso 2: Configurar cada plantilla

#### 🔹 Confirm Signup
```
Template: Copia el contenido de verifyEmail.html
Subject: Verifica tu cuenta - NexyPass 🚀
```

#### 🔹 Invite User
```
Template: Copia el contenido de inviteUser.html
Subject: ¡Has sido invitado a NexyPass! 🎉
```

#### 🔹 Magic Link
```
Template: Copia el contenido de magicLink.html
Subject: Tu enlace de acceso a NexyPass ✨
```

#### 🔹 Change Email
```
Template: Copia el contenido de changeEmail.html
Subject: Confirma tu nuevo email - NexyPass 📧
```

#### 🔹 Reset Password
```
Template: Copia el contenido de resetPassword.html
Subject: Restablece tu contraseña - NexyPass 🔐
```

#### 🔹 Reauthenticate
```
Template: Copia el contenido de reauthenticate.html
Subject: Verificación de seguridad requerida - NexyPass 🛡️
```

---

## 🎯 Enlaces Importantes Incluidos

Todas las plantillas incluyen estos enlaces de acceso rápido:

- **🎯 Ver Ruleta:** `https://www.nexypass.site/wheel`
- **🛒 Nuestra Tienda:** `https://www.nexypass.site`
- **📱 WhatsApp Soporte:** `+52 9514563572`

---

## 🔧 Variables de Supabase Utilizadas

Las plantillas usan estas variables que Supabase reemplaza automáticamente:

- `{{ .ConfirmationURL }}` - Enlace de confirmación/verificación
- `{{ .Email }}` - Email del usuario
- `{{ .NewEmail }}` - Nuevo email (para cambio de email)
- `{{ .SiteURL }}` - URL de tu sitio
- `{{ .Token }}` - Token de verificación
- `{{ .TokenHash }}` - Hash del token
- `{{ .Timestamp }}` - Fecha y hora
- `{{ .IPAddress }}` - Dirección IP
- `{{ .UserAgent }}` - Información del navegador

---

## ✅ Lista de Verificación

Después de configurar cada plantilla:

- [ ] **Confirm Signup** configurado
- [ ] **Invite User** configurado  
- [ ] **Magic Link** configurado
- [ ] **Change Email** configurado
- [ ] **Reset Password** configurado
- [ ] **Reauthenticate** configurado
- [ ] Probar cada tipo de email con usuarios reales
- [ ] Verificar que los enlaces funcionan correctamente
- [ ] Confirmar que el diseño se ve bien en diferentes clientes de email

---

## 🧪 Cómo Probar

### Confirm Signup
1. Registra un nuevo usuario en tu app
2. Verifica que recibe el email con el nuevo diseño

### Reset Password
1. Ve a la página de login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Ingresa un email registrado
4. Verifica el email recibido

### Magic Link
1. Configura magic link en tu app
2. Intenta hacer login con magic link
3. Verifica el email recibido

### Otros
- **Invite User:** Usa la función de invitar usuarios de Supabase
- **Change Email:** Cambia el email desde el perfil del usuario
- **Reauthenticate:** Se activa automáticamente por políticas de seguridad

---

## 🎨 Características del Diseño

Todas las plantillas incluyen:

- ✨ **Diseño moderno** con gradientes azul-púrpura
- 📱 **Responsive** para móviles y escritorio
- 🎯 **Branding consistente** con logo NexyPass
- 🔗 **Enlaces de acceso rápido** a funciones principales
- 🛡️ **Información de seguridad** cuando es relevante
- 📞 **Contacto de soporte** siempre visible
- 🎁 **Promoción de beneficios** de la plataforma

---

## 📞 Soporte

Si tienes problemas con la implementación:

- **WhatsApp:** +52 9514563572
- **Documentación:** Revisa `README.md` en la carpeta emailTemplates
- **Vista Previa:** Abre `preview.html` para ver las plantillas

---

**¡Todas las plantillas están listas para copiar y pegar en Supabase! 🚀**
