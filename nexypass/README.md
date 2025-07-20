# NexyPass - Aplicación de Ruleta de Premios

Una aplicación web moderna y responsive que permite a los usuarios registrarse, verificar redes sociales y participar en sorteos de cuentas de streaming mediante una ruleta visual animada.

## 🚀 Características

- ✅ **Autenticación completa** con Supabase
- 🎯 **Ruleta animada** con 6 tipos de premios
- 📱 **Verificación de redes sociales** (TikTok/Instagram)
- 👤 **Perfil de usuario** con historial de giros
- 🏆 **Lista de ganadores** en tiempo real
- 🛡️ **Sistema anti-trampas** con límites de tiempo
- 📱 **Diseño 100% responsive**
- 🎨 **Degradado moderno** celeste a azul oscuro

## 🛠️ Tecnologías

- **Frontend**: Next.js 14, React 18, TypeScript
- **Estilos**: TailwindCSS
- **Animaciones**: Framer Motion
- **Backend**: Supabase (Auth + Database + Realtime)
- **Estado**: React Context API

## 📋 Configuración de Supabase

### 1. Crear proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Copia la URL del proyecto y la clave anónima

### 2. Configurar variables de entorno

Crea un archivo `.env.local` en la raíz del proyecto:

```env
NEXT_PUBLIC_SUPABASE_URL=tu_url_de_supabase_aqui
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima_aqui
NEXT_PUBLIC_APP_URL=http://localhost:8000
NEXT_PUBLIC_WHATSAPP_NUMBER=529514563572
```

### 3. Crear tablas en Supabase

Ejecuta estos comandos SQL en el editor SQL de Supabase:

```sql
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

### 4. Configurar Row Level Security (RLS)

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

### 5. Configurar triggers para actualización automática

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

## 🚀 Instalación y Ejecución

1. **Clonar el repositorio**
```bash
git clone <tu-repositorio>
cd nexypass
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
```bash
cp .env.local.example .env.local
# Editar .env.local con tus credenciales de Supabase
```

4. **Ejecutar en desarrollo**
```bash
npm run dev
```

5. **Abrir en el navegador**
```
http://localhost:8000
```

## 🎯 Funcionalidades Principales

### 🔐 Autenticación
- Registro con email, username y contraseña
- Inicio de sesión seguro
- Protección de rutas
- Gestión de sesiones con Supabase

### 📱 Verificación Social
- Verificación obligatoria de TikTok e Instagram
- Desbloqueo de la ruleta tras verificación
- Sistema de flags en base de datos

### 🎡 Ruleta de Premios
- 6 secciones con diferentes probabilidades:
  - 💰 Descuento S/1.00 (1% - máx. 10 ganadores)
  - 💸 Descuento S/0.50 (1% - máx. 10 ganadores)
  - 🌟 Crunchyroll 1 mes (1.2% - máx. 5 ganadores)
  - 🔄 Gira otra vez (20%)
  - 🔸 Sigue intentando (60%)
  - ❌ No ganaste nada (16.8%)

### ⏰ Sistema de Límites
- 2 giros cada 2 horas por usuario
- Validación en tiempo real
- Prevención de trampas con IP/fingerprint

### 🏆 Lista de Ganadores
- Actualización en tiempo real
- Solo muestra premios reales (descuentos y Crunchyroll)
- Animaciones y efectos visuales

### 👤 Perfil de Usuario
- Edición de información personal
- Historial completo de giros
- Estadísticas personalizadas
- Gestión de avatar

## 🛡️ Seguridad

- **Row Level Security (RLS)** en Supabase
- **Validación de sesiones** con JWT
- **Límites de tiempo** por usuario
- **Detección de múltiples cuentas**
- **Validación server-side** de premios

## 🎨 Diseño

- **Degradado principal**: #00CFFF → #0056B3
- **Tipografía**: Inter (Google Fonts)
- **Componentes**: TailwindCSS + componentes personalizados
- **Animaciones**: Framer Motion
- **Responsive**: Mobile-first design

## 📱 Responsive Design

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px  
- **Desktop**: > 1024px

## 🔧 Scripts Disponibles

```bash
npm run dev      # Desarrollo en puerto 8000
npm run build    # Build para producción
npm run start    # Servidor de producción
npm run lint     # Linter de código
```

## 📞 Soporte

Para soporte técnico o consultas:
- WhatsApp: +52 9514563572
- Email: soporte@nexypass.com

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

**NexyPass** - Tu Universo Digital, Simplificado 🚀
