# 🚀 GUÍA COMPLETA: Configurar Supabase para NexyPass

Esta guía te llevará paso a paso para configurar Supabase y conectarlo con tu aplicación NexyPass.

## 📋 PASO 1: Crear cuenta en Supabase

1. **Ve a https://supabase.com**
2. **Haz clic en "Start your project"**
3. **Elige una opción para registrarte:**
   - **Opción A: Continue with GitHub** (recomendado si tienes GitHub)
   - **Opción B: Crear con email:**
     - Ingresa tu email
     - Crea una contraseña segura
     - Haz clic en "Sign Up"
     - Verifica tu email

## 📋 PASO 2: Crear tu proyecto

1. **Una vez dentro del dashboard, haz clic en "New Project"**
2. **Completa la información:**
   - **Organization:** Selecciona tu organización (o crea una nueva)
   - **Name:** `nexypass-app` (o el nombre que prefieras)
   - **Database Password:** Crea una contraseña segura (¡GUÁRDALA!)
   - **Region:** Selecciona la región más cercana a ti
   - **Pricing Plan:** Selecciona "Free" (es suficiente para empezar)

3. **Haz clic en "Create new project"**
4. **Espera 2-3 minutos** mientras Supabase configura tu proyecto

## 📋 PASO 3: Obtener las credenciales

1. **En el dashboard de tu proyecto, ve a Settings > API**
2. **Copia estos dos valores importantes:**
   - **Project URL:** `https://tuproyecto.supabase.co`
   - **anon public key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (una clave muy larga)

## 📋 PASO 4: Configurar las variables de entorno

1. **En tu proyecto NexyPass, abre el archivo `.env.local`**
2. **Reemplaza las líneas con tus credenciales reales:**

```env
# Reemplaza con TUS credenciales de Supabase
NEXT_PUBLIC_SUPABASE_URL=https://tuproyecto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Estas pueden quedarse igual
NEXT_PUBLIC_APP_URL=http://localhost:8000
NEXT_PUBLIC_WHATSAPP_NUMBER=529514563572
```

## 📋 PASO 5: Crear las tablas en la base de datos

1. **En Supabase, ve a SQL Editor**
2. **Haz clic en "New Query"**
3. **Copia y pega este código SQL:**

```sql
-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de perfiles de usuario
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT,
  verified BOOLEAN DEFAULT FALSE,
  spins_used_today INTEGER DEFAULT 0,
  last_spin_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Tabla de giros de ruleta
CREATE TABLE spins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  prize_type TEXT NOT NULL,
  prize_label TEXT NOT NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de premios disponibles
CREATE TABLE prizes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT UNIQUE NOT NULL,
  label TEXT NOT NULL,
  probability DECIMAL NOT NULL,
  max_winners INTEGER DEFAULT 0,
  current_winners INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de ganadores
CREATE TABLE winners (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  prize_type TEXT NOT NULL,
  prize_label TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar premios iniciales
INSERT INTO prizes (type, label, probability, max_winners) VALUES
('discount1', 'Descuento S/1.00', 1.0, 10),
('discount2', 'Descuento S/0.50', 1.0, 10),
('crunchyroll', 'Perfil Crunchyroll 1 mes', 1.2, 5),
('spinAgain', 'Gira otra vez', 20.0, 0),
('tryAgain', 'Sigue intentando', 60.0, 0),
('nothing', 'No ganaste nada', 16.8, 0);
```

4. **Haz clic en "Run" para ejecutar el código**

## 📋 PASO 6: Configurar Row Level Security (RLS)

1. **En el mismo SQL Editor, ejecuta este código:**

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE spins ENABLE ROW LEVEL SECURITY;
ALTER TABLE winners ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Políticas para spins
CREATE POLICY "Users can view own spins" ON spins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own spins" ON spins
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para winners (lectura pública)
CREATE POLICY "Anyone can view winners" ON winners
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own wins" ON winners
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para prizes (lectura pública)
CREATE POLICY "Anyone can view prizes" ON prizes
  FOR SELECT USING (true);
```

## 📋 PASO 7: Configurar triggers automáticos

1. **Ejecuta este último código SQL:**

```sql
-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Función para crear perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Usuario'),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil al registrarse
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 📋 PASO 8: Configurar autenticación

1. **Ve a Authentication > Settings**
2. **En "Site URL" agrega:** `http://localhost:8000`
3. **En "Redirect URLs" agrega:** `http://localhost:8000/**`
4. **Guarda los cambios**

## 📋 PASO 9: Personalizar el Correo de Verificación

Para mejorar la experiencia del usuario y reforzar la marca NexyPass, configuraremos un correo electrónico de verificación personalizado.

### 🎨 Configurar la Plantilla de Email:

1. **En tu dashboard de Supabase, ve a Authentication > Email Templates**
2. **Selecciona "Confirm signup" (Confirmar registro)**
3. **Abre el archivo `emailTemplates/verifyEmail.html` de tu proyecto NexyPass**
4. **Copia todo el contenido HTML del archivo**
5. **Pega el contenido en el campo "Email template" de Supabase**
6. **Asegúrate de que el "Subject" sea:** `Verifica tu cuenta - NexyPass 🚀`
7. **Haz clic en "Save" para guardar los cambios**

### ✨ Características de la Nueva Plantilla:

La plantilla personalizada incluye:

- **🎯 Branding Profesional:** Logo y colores de NexyPass
- **📱 Diseño Responsivo:** Se ve perfecto en móviles y escritorio
- **🎁 Guía de Beneficios:** Lista completa de lo que obtiene el usuario
- **⚡ CTA Prominente:** Botón llamativo para verificar la cuenta
- **🔗 Enlace de Respaldo:** Por si el botón no funciona
- **📞 Información de Contacto:** WhatsApp y redes sociales
- **🛡️ Mensaje de Seguridad:** Información sobre expiración del enlace

### 🧪 Probar la Plantilla:

1. **Registra un nuevo usuario de prueba desde tu app**
2. **Revisa el correo recibido para verificar:**
   - ✅ El diseño se muestra correctamente
   - ✅ El botón "Verificar mi Cuenta" funciona
   - ✅ Los colores y tipografía coinciden con NexyPass
   - ✅ El contenido es claro y atractivo

### 🔧 Solución de Problemas:

**Si el email no se ve bien:**
- Verifica que copiaste todo el HTML completo
- Asegúrate de que no hay caracteres especiales mal codificados
- Prueba enviando un email de prueba desde Supabase

**Si las variables no se reemplazan:**
- Confirma que usas `{{ .ConfirmationURL }}` (puede variar según la versión)
- Revisa la documentación de Supabase para variables de plantilla

### 📧 Variables Disponibles en Supabase:

- `{{ .ConfirmationURL }}` - Enlace de verificación
- `{{ .Token }}` - Token de verificación
- `{{ .TokenHash }}` - Hash del token
- `{{ .SiteURL }}` - URL de tu sitio
- `{{ .Email }}` - Email del usuario

## 📋 PASO 10: Probar la conexión

1. **Reinicia tu aplicación NexyPass:**
   ```bash
   # Detén el servidor (Ctrl+C)
   # Luego ejecuta:
   npm run dev
   ```

2. **Ve a http://localhost:8000**
3. **Ya no deberías ver el mensaje de "Supabase not configured"**
4. **Prueba registrarte con un email y contraseña**

## 🎉 ¡LISTO!

Tu aplicación NexyPass ahora está completamente conectada con Supabase. Puedes:

- ✅ Registrar usuarios
- ✅ Iniciar sesión
- ✅ Verificar redes sociales
- ✅ Girar la ruleta
- ✅ Ver ganadores en tiempo real
- ✅ Gestionar perfiles

## 🔧 Solución de problemas

### Si ves errores:

1. **Verifica que las credenciales en `.env.local` sean correctas**
2. **Asegúrate de que todas las tablas se crearon correctamente**
3. **Revisa que RLS esté habilitado**
4. **Reinicia la aplicación después de cambiar `.env.local`**

### Si necesitas ayuda:

- Revisa los logs en la consola del navegador
- Verifica los logs de Supabase en el dashboard
- Asegúrate de que el proyecto de Supabase esté activo

## 📞 Contacto

Si tienes problemas, puedes contactar por WhatsApp: +52 9514563572

---

**¡Tu aplicación NexyPass está lista para funcionar! 🚀**
