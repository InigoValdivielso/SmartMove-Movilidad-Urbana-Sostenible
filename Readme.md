# 🏙️ SmartMove – Movilidad Urbana Sostenible

Este proyecto implementa un pipeline de datos ELT (Extract, Load, Transform) completo para el caso de uso de "Gestión de Movilidad Urbana Sostenible".

El pipeline ingesta datos de múltiples fuentes (API, MQTT, XML), los carga en un Data Warehouse (PostgreSQL), los transforma y limpia (dbt), y los expone para su visualización (Metabase). Todo el stack está orquestado con Docker Compose.

## 📁 Estructura del Proyecto

El proyecto entregado contiene la siguiente estructura de archivos:
```text
/
├── data/
│   ├── n8n/                # <-- Contiene los workflows y credenciales de n8n
│   └── metabase/           # <-- Contiene la configuración y dashboards de Metabase
├── data_sources/
│   ├── files/
│   │   └── puntos_carga.xml    # <-- Fichero de datos estáticos
│   └── postgres_init/
│       └── init.sql            # <-- Script de inicialización de la BBDD
├── dbt_smartmove/
│   ├── models/
│   │   ├── estado_actual_bicis.sql
│   │   ├── estado_actual_parkings.sql
│   │   ├── clean_puntos_carga.sql
│   │   └── schema.yml      # <-- Pruebas de Calidad de Datos (dbt test)
│   └── dbt_project.yml     # <-- Configuración del proyecto dbt
├── mosquitto_config/
│   └── mosquitto.conf      # <-- Configuración del broker MQTT
├── docker-compose.yml      # <-- Orquestador de todos los servicios
├── simulador_mqtt.py       # <-- Script de Python para simular sensores IoT
└── README.md               # <-- Este archivo
```
Nota Importante: Las carpetas data/n8n y data/metabase son esenciales, ya que contienen los workflows y dashboards pre-configurados que se cargarán al iniciar.

## 🛠️ Prerrequisitos

Para ejecutar este proyecto, necesitará tener instalados:

* **Docker** (con Docker Compose)
* **Python 3.x**
* **pip** (para instalar las librerías de Python)

### Instalación de dependencias de Python
Para facilitar la instalación, el proyecto incluye archivos de requisitos:

- Dependencias mínimas para el simulador MQTT y para ejecutar dbt localmente:
```bash
pip install -r requirements.txt
```
## 🚀 Pasos para la Ejecución

Siga estos pasos en orden desde la raíz del proyecto.

### 1. Levantar la Infraestructura (Docker)

Abra una terminal en la carpeta raíz y ejecute:
```bash
docker-compose up -d
```
Espere unos 30-60 segundos a que todos los servicios (Postgres, n8n, Metabase, Mosquitto) se inicien y estabilicen.

NOTA IMPORTANTE SOBRE EL ARRANQUE:
- La primera vez que se ejecuta, puede ocurrir una "carrera de condiciones" (race condition) donde los servicios n8n o metabase arranquen más rápido que la base de datos postgres (que está "healthy" pero aún iniciando) y fallen.
Si tras ejecutar docker-compose ps ve que n8n_workflow o metabase_dashboard están en estado Exited o Restarting, es un comportamiento normal.
Para solucionarlo, simplemente espere 10 segundos más y vuelva a ejecutar:
```bash
docker-compose up -d
```
En el segundo intento, la base de datos ya estará lista y todos los servicios se conectarán correctamente.

### 2. Ejecutar el Simulador MQTT
Para que la tabla raw_parkings_iot reciba datos, debe ejecutar el simulador de Python en una nueva terminal.
1. (Primera vez) Instale las dependencias del simulador:
```bash
pip install -r requirements.txt
```
2. Ejecute el script (y déjelo corriendo en esta terminal):
```bash
python simulador_mqtt.py
```
Verá mensajes de "Conectado..." y "Mensaje enviado...".

### 3. Acceder a n8n para Ingestar Datos
1. Abra su navegador y vaya a: http://localhost:5678
2. Inicie sesión con:
    - Usuario: `valdivielso.inigo@opendeusto.es`
    - Contraseña: `Integracion2526`
3. El workflow "My workflow" ya está preconfigurado ya está cargado. Entre en él y haga clic en el switch que pone "Inactive" en la parte superior de la pantalla para iniciar la ingesta de datos.
4. Si está activado, el workflow ya estará:
- Escuchando los mensajes de MQTT (del script de Python).
- Ejecutando el Schedule (cada 10 min) para ingestar datos de la API de Bicis y del XML.

### 4. Ejecutar la Transformación con dbt
La ingesta ("EL") ya está funcionando. Ahora ejecutamos la transformación ("T").
1. (Primera vez) Instale las dependencias de dbt (opcional si desea ejecutar transformaciones localmente):
```bash
pip install -r requirements-dbt.txt
```
2. (Paso Crítico) Configurar la Conexión de dbt:
dbt necesita un archivo profiles.yml en su carpeta de usuario para saber cómo conectarse a la base de datos de Docker.
- Windows: Cree el archivo en `C:\Users\[TuUsuario]\.dbt\profiles.yml`
- Mac/Linux: Cree el archivo en `~/.dbt/profiles.yml`

Copie y pegue el siguiente contenido en ese archivo:
```yaml
dbt_smartmove: # Asegúrese de que este nombre coincide con 'name' en dbt_project.yml
    target: dev
    outputs:
        dev:
            type: postgres
            host: localhost
            user: postgres
            password: smartmove2026
            port: 5432
            dbname: smartmove_db
            schema: public
```
3. Ejecutar y Probar dbt:

Navegue a la carpeta del proyecto de dbt:
```bash
cd dbt_smartmove
```
Ejecute las transformaciones:
```bash
dbt run
```
Luego, ejecute las pruebas de calidad de datos:
```bash
dbt test
```
### 5. Acceder a Metabase para Visualizar Datos
1. Abra su navegador y vaya a: http://localhost:3000
2. Inicie sesión con:
    - Usuario: `valdivielso.inigo@opendeusto.es`
    - Contraseña: `admin1234`
3. La configuración de Metabase ya debería estar cargada (gracias al volumen data/metabase).
4. Para visualizar el dashboard de movilidad urbana, vaya al menú de la izquierda en el apartado de "COLECCIONES" y seleccione la carpeta "Nuestra Analítica". Dentro verá el dashboard "SmartMove".
