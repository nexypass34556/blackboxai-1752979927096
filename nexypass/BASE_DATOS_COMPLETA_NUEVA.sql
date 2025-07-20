-- BASE DE DATOS COMPLETA CON TODAS LAS MEJORAS
-- BORRA TODO Y EJECUTA ESTO SI QUIERES EMPEZAR DESDE CERO

-- Eliminar tablas existentes (CUIDADO: ESTO BORRA TODO)
DROP TABLE IF EXISTS winners CASCADE;
DROP TABLE IF EXISTS spins CASCADE;
DROP TABLE IF EXISTS prizes CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

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

-- Insertar premios ACTUALIZADOS con Disney+
INSERT INTO prizes (type, label, probability, max_winners) VALUES
('discount1', 'Descuento S/1.00', 1.0, 10),
('discount2', 'Descuento S/0.50', 1.0, 10),
('crunchyroll', 'Crunchyroll (1 mes)', 1.2, 10),
('disney', 'Disney+ (1 mes)', 1.0, 10),
('spinAgain', 'Gira otra vez', 20.0, 0),
('tryAgain', 'Sigue intentando', 59.8, 0),
('nothing', 'No ganaste nada', 16.0, 0);

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

-- Verificar que todo se creó correctamente
SELECT 'Premios creados:' as info;
SELECT type, label, probability, max_winners FROM prizes ORDER BY probability DESC;
