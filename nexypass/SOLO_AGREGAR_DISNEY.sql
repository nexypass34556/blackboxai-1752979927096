-- SOLO EJECUTA ESTO SI YA TIENES LA BASE DE DATOS FUNCIONANDO
-- Ve a Supabase → SQL Editor → Pega este código → Ejecuta

INSERT INTO prizes (type, label, probability, max_winners) VALUES
('disney', 'Disney+ (1 mes)', 1.0, 10);

-- Verifica que se agregó correctamente
SELECT * FROM prizes ORDER BY type;
