-- models/estado_actual_parkings.sql

WITH ultimos_registros AS (
  SELECT
    *,
    -- Numera cada fila por sensor, ordenando por el timestamp más nuevo
    ROW_NUMBER() OVER(
      PARTITION BY sensor_id 
      ORDER BY timestamp DESC
    ) as rn
  FROM
    raw_parkings_iot -- Lee del historial "sucio"
)

-- Selecciona solo la fila número 1 (la más nueva) de cada sensor
SELECT
  id,
  sensor_id,
  estado,
  timestamp
FROM
  ultimos_registros
WHERE
  rn = 1