-- Actualización de la base de datos NexyPass
-- Ejecuta este código en el SQL Editor de Supabase para agregar el nuevo premio Disney+

-- Agregar el nuevo premio Disney+ a la tabla de premios
INSERT INTO prizes (type, label, probability, max_winners) VALUES
('disney', 'Disney+ (1 mes)', 1.0, 10);

-- Verificar que el premio se agregó correctamente
SELECT * FROM prizes WHERE type = 'disney';

-- Opcional: Ver todos los premios actuales
SELECT type, label, probability, max_winners, active FROM prizes ORDER BY probability DESC;
