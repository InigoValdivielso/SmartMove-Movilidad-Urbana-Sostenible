-- Crear la tabla de usuarios registrados
CREATE TABLE usuarios (
    usuario_id INT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_registro DATE
);
CREATE TABLE IF NOT EXISTS raw_parkings_iot (
    id SERIAL PRIMARY KEY,           
    sensor_id VARCHAR(50) NOT NULL,  
    estado VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS raw_bici_stations (
    id SERIAL PRIMARY KEY,           
    station_id VARCHAR(100),         
    station_name VARCHAR(255),
    free_bikes INT,
    empty_slots INT,
    ebikes INT,
    normal_bikes INT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW() ,
    latitud REAL,   
    longitud REAL
);

CREATE TABLE IF NOT EXISTS raw_puntos_carga (
    id SERIAL PRIMARY KEY,          
    punto_id VARCHAR(50),            
    direccion VARCHAR(255),
    latitud REAL,
    longitud REAL,
    tipo_conector VARCHAR(50)
);

-- Insertar algunos usuarios de ejemplo
INSERT INTO usuarios (usuario_id, nombre_usuario, email, fecha_registro)
VALUES
(1, 'ana_gomez', 'ana.gomez@email.com', '2023-01-15'),
(2, 'bruno_diaz', 'bruno.diaz@email.com', '2023-02-20'),
(3, 'carla_ruiz', 'carla.ruiz@email.com', '2023-03-05');