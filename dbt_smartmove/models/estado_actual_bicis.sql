-- models/estado_actual_bicis.sql

WITH ultimos_registros AS (
  SELECT
    *,
    ROW_NUMBER() OVER(
      PARTITION BY station_id 
      ORDER BY timestamp DESC
    ) as rn
  FROM
    raw_bici_stations
)

SELECT
  id,
  station_id,
  station_name,
  free_bikes,
  empty_slots,
  ebikes,
  normal_bikes,
  timestamp,
  latitud,
  longitud
FROM
  ultimos_registros
WHERE
  rn = 1