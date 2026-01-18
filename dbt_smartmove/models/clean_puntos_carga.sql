-- models/clean_puntos_carga.sql

-- Esta tabla es estática, pero n8n la inserta múltiples veces.
-- Usamos ROW_NUMBER() para deduplicarla y quedarnos solo con una copia.

WITH ranked_puntos AS (
  SELECT
    *,
    -- Agrupamos por el ID del punto y los ordenamos por el ID serial (el más nuevo)
    ROW_NUMBER() OVER(
      PARTITION BY punto_id 
      ORDER BY id DESC
    ) as rn
  FROM
    raw_puntos_carga -- Lee de la tabla "sucia" con duplicados
)

-- Seleccionamos solo la fila 1 de cada grupo (la más reciente)
SELECT
  punto_id as punto_carga_id,
  direccion,
  latitud,
  longitud,
  tipo_conector
FROM
  ranked_puntos
WHERE
  rn = 1