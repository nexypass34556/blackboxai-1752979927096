# 🗄️ GUÍA COMPLETA PARA MODIFICAR SUPABASE - NEXYPASS

## 📋 ÍNDICE
1. [Acceso a Supabase](#acceso-a-supabase)
2. [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
3. [Modificaciones Comunes](#modificaciones-comunes)
4. [Funciones y Triggers](#funciones-y-triggers)
5. [Políticas de Seguridad](#políticas-de-seguridad)
6. [Solución de Problemas](#solución-de-problemas)

---

## 🔐 ACCESO A SUPABASE

### 1. Iniciar Sesión
1. Ve a [supabase.com](https://supabase.com)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto NexyPass

### 2. Acceder al Editor SQL
1. En el panel izquierdo, haz clic en **"SQL Editor"**
2. Aquí puedes ejecutar consultas SQL directamente

---

## 🏗️ ESTRUCTURA DE LA BASE DE DATOS

### Tablas Principales

#### `profiles` - Perfiles de Usuario
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT NOT NULL,
  email TEXT NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  avatar_url TEXT,
  spins_used_today INTEGER DEFAULT 0,
  last_spin_at TIMESTAMP WITH TIME ZONE,
  invitation_code TEXT UNIQUE,
  invited_by UUID REFERENCES profiles(id),
  bonus_spins INTEGER DEFAULT 0,
  total_invites INTEGER DEFAULT 0
);
```

#### `spins` - Historial de Giros
```sql
CREATE TABLE spins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  prize_type TEXT NOT NULL,
  prize_label TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ip_address TEXT,
  user_agent TEXT
);
```

#### `winners` - Lista de Ganadores
```sql
CREATE TABLE winners (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  prize_type TEXT NOT NULL,
  prize_label TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `invitations` - Sistema de Invitaciones
```sql
CREATE TABLE invitations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  inviter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  invitee_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  invitation_code TEXT NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  bonus_granted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔧 MODIFICACIONES COMUNES

### 1. Agregar Nueva Columna a `profiles`
```sql
-- Ejemplo: Agregar campo para teléfono
ALTER TABLE profiles ADD COLUMN phone TEXT;
```

### 2. Modificar Límites de Giros
```sql
-- Cambiar la lógica en la función canUserSpin
-- Editar en src/lib/supabase.ts línea ~120
const totalAvailableSpins = 3 + bonusSpins // Cambiar de 2 a 3
```

### 3. Agregar Nuevo Tipo de Premio
```sql
-- No requiere cambios en BD, solo en el frontend
-- Editar src/components/Roulette/RouletteWheel.tsx
-- Agregar nuevo objeto al array 'prizes'
```

### 4. Cambiar Tiempo Entre Giros
```sql
-- Editar en src/lib/supabase.ts línea ~135
const hoursDiff = timeDiff / (1000 * 60 * 60)
if (hoursDiff < 1) { // Cambiar de 2 a 1 hora
```

---

## ⚙️ FUNCIONES Y TRIGGERS

### 1. Función para Generar Códigos de Invitación
```sql
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists_check INTEGER;
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  i INTEGER;
  attempts INTEGER := 0;
  max_attempts INTEGER := 100;
BEGIN
  LOOP
    code := '';
    FOR i IN 1..8 LOOP
      code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    
    SELECT COUNT(*) INTO exists_check FROM profiles WHERE invitation_code = code;
    
    IF exists_check = 0 THEN
      EXIT;
    END IF;
    
    attempts := attempts + 1;
    IF attempts >= max_attempts THEN
      RAISE EXCEPTION 'No se pudo generar un código único después de % intentos', max_attempts;
    END IF;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;
```

### 2. Trigger para Nuevos Usuarios
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  new_code TEXT;
BEGIN
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

-- Crear el trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 3. Función para Procesar Invitaciones
```sql
CREATE OR REPLACE FUNCTION process_invitation(invitee_id UUID, invitation_code_input TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  inviter_record RECORD;
  invitation_exists INTEGER;
BEGIN
  SELECT * INTO inviter_record 
  FROM profiles 
  WHERE invitation_code = invitation_code_input AND id != invitee_id;
  
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  SELECT COUNT(*) INTO invitation_exists 
  FROM invitations 
  WHERE inviter_id = inviter_record.id AND invitee_id = invitee_id;
  
  IF invitation_exists > 0 THEN
    RETURN FALSE;
  END IF;
  
  UPDATE profiles 
  SET invited_by = inviter_record.id 
  WHERE id = invitee_id;
  
  INSERT INTO invitations (inviter_id, invitee_id, invitation_code)
  VALUES (inviter_record.id, invitee_id, invitation_code_input);
  
  UPDATE profiles 
  SET bonus_spins = COALESCE(bonus_spins, 0) + 1,
      total_invites = COALESCE(total_invites, 0) + 1
  WHERE id = inviter_record.id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔒 POLÍTICAS DE SEGURIDAD (RLS)

### 1. Habilitar RLS en Todas las Tablas
```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE spins ENABLE ROW LEVEL SECURITY;
ALTER TABLE winners ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
```

### 2. Políticas para `profiles`
```sql
-- Los usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Permitir inserción para nuevos usuarios
CREATE POLICY "Enable insert for authenticated users" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### 3. Políticas para `spins`
```sql
-- Los usuarios pueden ver sus propios giros
CREATE POLICY "Users can view own spins" ON spins
  FOR SELECT USING (auth.uid() = user_id);

-- Permitir inserción de giros
CREATE POLICY "Users can insert own spins" ON spins
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 4. Políticas para `winners`
```sql
-- Todos pueden ver la lista de ganadores (sin datos sensibles)
CREATE POLICY "Anyone can view winners" ON winners
  FOR SELECT USING (true);

-- Solo el sistema puede insertar ganadores
CREATE POLICY "System can insert winners" ON winners
  FOR INSERT WITH CHECK (true);
```

### 5. Políticas para `invitations`
```sql
-- Los usuarios pueden ver sus invitaciones
CREATE POLICY "Users can view own invitations" ON invitations
  FOR SELECT USING (auth.uid() = inviter_id OR auth.uid() = invitee_id);

-- El sistema puede insertar invitaciones
CREATE POLICY "System can insert invitations" ON invitations
  FOR INSERT WITH CHECK (true);
```

---

## 🛠️ MODIFICACIONES PASO A PASO

### Cambiar Límite de Giros Diarios

#### 1. En Supabase (SQL Editor):
```sql
-- No hay cambios necesarios en la BD
```

#### 2. En el Código (src/lib/supabase.ts):
```typescript
// Línea ~120, cambiar:
const totalAvailableSpins = 3 + bonusSpins // Era 2, ahora 3
```

### Agregar Nuevo Campo al Perfil

#### 1. En Supabase:
```sql
ALTER TABLE profiles ADD COLUMN new_field TEXT DEFAULT '';
```

#### 2. En el Código:
```typescript
// En src/lib/supabase.ts, agregar al interface User:
export interface User {
  // ... campos existentes
  new_field?: string
}
```

### Cambiar Tiempo Entre Giros

#### En el Código (src/lib/supabase.ts):
```typescript
// Línea ~135, cambiar:
if (hoursDiff < 1) { // Era 2 horas, ahora 1 hora
  return {
    canSpin: false,
    reason: `Debes esperar 1 hora entre giros. Giros restantes: ${totalAvailableSpins - spinsUsed}`,
    nextSpinAt: new Date(lastSpin.getTime() + (1 * 60 * 60 * 1000)), // 1 hora
    remainingSpins: totalAvailableSpins - spinsUsed,
    bonusSpins: bonusSpins
  }
}
```

---

## 🚨 SOLUCIÓN DE PROBLEMAS

### Problema: Los códigos de invitación no se generan

#### Solución:
1. Verificar que el trigger esté activo:
```sql
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
```

2. Si no existe, recrearlo:
```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### Problema: Los giros no se actualizan

#### Solución:
1. Verificar la función `canUserSpin` en el código
2. Revisar los logs en Supabase Dashboard > Logs
3. Verificar las políticas RLS

### Problema: Las invitaciones no funcionan

#### Solución:
1. Verificar que la función `process_invitation` existe:
```sql
SELECT * FROM pg_proc WHERE proname = 'process_invitation';
```

2. Probar manualmente:
```sql
SELECT process_invitation('user-id-here', 'CODIGO123');
```

---

## 📊 CONSULTAS ÚTILES

### Ver Todos los Usuarios y sus Códigos
```sql
SELECT username, email, invitation_code, total_invites, bonus_spins 
FROM profiles 
ORDER BY created_at DESC;
```

### Ver Historial de Giros de un Usuario
```sql
SELECT p.username, s.prize_label, s.created_at 
FROM spins s 
JOIN profiles p ON s.user_id = p.id 
WHERE p.username = 'nombre_usuario'
ORDER BY s.created_at DESC;
```

### Ver Estadísticas de Invitaciones
```sql
SELECT 
  p1.username as invitador,
  p2.username as invitado,
  i.created_at
FROM invitations i
JOIN profiles p1 ON i.inviter_id = p1.id
JOIN profiles p2 ON i.invitee_id = p2.id
ORDER BY i.created_at DESC;
```

### Resetear Giros Diarios (Ejecutar diariamente)
```sql
UPDATE profiles SET spins_used_today = 0;
```

---

## 🔄 BACKUP Y RESTAURACIÓN

### Crear Backup
```sql
-- En tu terminal local (requiere pg_dump):
pg_dump "postgresql://[usuario]:[password]@[host]:[puerto]/[database]" > backup.sql
```

### Restaurar Backup
```sql
-- En tu terminal local (requiere psql):
psql "postgresql://[usuario]:[password]@[host]:[puerto]/[database]" < backup.sql
```

---

## 📞 CONTACTO Y SOPORTE

Si necesitas ayuda adicional:
1. Revisa la documentación oficial de Supabase
2. Consulta los logs en el Dashboard de Supabase
3. Verifica que todas las funciones y triggers estén activos
4. Asegúrate de que las políticas RLS estén configuradas correctamente

---

**⚠️ IMPORTANTE**: Siempre haz un backup antes de realizar cambios importantes en la base de datos.

**📝 NOTA**: Esta guía está actualizada para la versión actual de NexyPass. Mantén este documento actualizado cuando hagas cambios.
