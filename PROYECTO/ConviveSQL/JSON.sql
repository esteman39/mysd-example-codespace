-- ==========================
-- JSON
-- ===========================

-- 1. Cambiar el tipo de dato crudo de la columna a JSONB
ALTER TABLE InventariosHabitaciones
    ALTER COLUMN descripcionActivo TYPE JSONB
    USING to_jsonb(descripcionActivo);

ALTER TABLE InventariosHabitaciones
    ALTER COLUMN descripcionActivo SET NOT NULL;

-- 2. Agregar la restricción CHECK para validar la estructura del JSON Schema
ALTER TABLE InventariosHabitaciones
    ADD CONSTRAINT CHK_Inventario_Descripcion_JSON CHECK (
        jsonb_typeof(descripcionActivo) = 'object'
        AND descripcionActivo ? 'material'
        AND jsonb_typeof(descripcionActivo->'material') = 'string'
        AND length(descripcionActivo->>'material') BETWEEN 2 AND 120
        AND (descripcionActivo - ARRAY['material', 'color', 'dimensiones', 'numero_serie', 'observaciones']) = '{}'::jsonb
    );

-- 3. Ejemplo de inserción siguiendo el formato $$ ... $$::jsonb
INSERT INTO InventariosHabitaciones (
    idInventario,
    descripcionActivo,
    categoriaActivo,
    nombreActivo,
    estadoInicial,
    idHabitacion
)
VALUES (
    'MOB-ESCRITORIO-203',
    $$
    {
      "material": "Madera de roble y estructura metálica",
      "color": "Nogal mate",
      "dimensiones": "120 cm x 60 cm x 75 cm",
      "numero_serie": "MOB-2026-0094",
      "observaciones": "Sin novedades al ingreso"
    }
    $$::jsonb,
    'Escritorio Ejecutivo',
    'Mobiliario',
    'Bueno',
    'HAB-203'
);
