-- ACTUALIZACIÓN DE BASE DE DATOS PARA SISTEMA DE INVITACIONES
-- Ejecutar después de la base de datos principal

-- Agregar campos para sistema de invitaciones a la tabla profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS invitation_code TEXT UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS invited_by UUID REFERENCES profiles(id);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS bonus_spins INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_invites INTEGER DEFAULT 0;

-- Crear tabla para tracking de invitaciones
CREATE TABLE IF NOT EXISTS invitations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  inviter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  invitee_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  invitation_code TEXT NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  bonus_granted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para generar código de invitación único mejorada
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists_check INTEGER;
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Sin caracteres confusos
  i INTEGER;
  attempts INTEGER := 0;
  max_attempts INTEGER := 100;
BEGIN
  LOOP
    code := '';
    -- Generar código aleatorio de 8 caracteres
    FOR i IN 1..8 LOOP
      code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    
    -- Verificar si ya existe
    SELECT COUNT(*) INTO exists_check FROM profiles WHERE invitation_code = code;
    
    -- Si no existe, salir del loop
    IF exists_check = 0 THEN
      EXIT;
    END IF;
    
    -- Prevenir loop infinito
    attempts := attempts + 1;
    IF attempts >= max_attempts THEN
      RAISE EXCEPTION 'No se pudo generar un código único después de % intentos', max_attempts;
    END IF;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Actualizar función para crear perfil con código de invitación
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  new_code TEXT;
BEGIN
  -- Generar código único
  new_code := generate_invitation_code();
  
  INSERT INTO public.profiles (id, username, email, invitation_code, bonus_spins, total_invites)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Usuario'),
    NEW.email,
    new_code,
    0,
    0
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para procesar invitación
CREATE OR REPLACE FUNCTION process_invitation(invitee_id UUID, invitation_code_input TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  inviter_record RECORD;
  invitation_exists INTEGER;
BEGIN
  -- Verificar si el código existe y obtener el invitador
  SELECT * INTO inviter_record 
  FROM profiles 
  WHERE invitation_code = invitation_code_input AND id != invitee_id;
  
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- Verificar si ya se usó esta invitación
  SELECT COUNT(*) INTO invitation_exists 
  FROM invitations 
  WHERE inviter_id = inviter_record.id AND invitee_id = invitee_id;
  
  IF invitation_exists > 0 THEN
    RETURN FALSE;
  END IF;
  
  -- Actualizar el invitado con el invitador
  UPDATE profiles 
  SET invited_by = inviter_record.id 
  WHERE id = invitee_id;
  
  -- Registrar la invitación
  INSERT INTO invitations (inviter_id, invitee_id, invitation_code)
  VALUES (inviter_record.id, invitee_id, invitation_code_input);
  
  -- Dar giro bonus al invitador
  UPDATE profiles 
  SET bonus_spins = COALESCE(bonus_spins, 0) + 1,
      total_invites = COALESCE(total_invites, 0) + 1
  WHERE id = inviter_record.id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Políticas para invitations
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own invitations" ON invitations
  FOR SELECT USING (auth.uid() = inviter_id OR auth.uid() = invitee_id);

CREATE POLICY "System can insert invitations" ON invitations
  FOR INSERT WITH CHECK (true);

-- Verificar que todo se creó correctamente
SELECT 'Sistema de invitaciones creado correctamente' as status;
