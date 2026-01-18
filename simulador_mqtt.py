import paho.mqtt.client as mqtt
import time
import json
import random

# Configuración del Broker MQTT (el que está en Docker)
BROKER_HOST = "localhost"
BROKER_PORT = 1883
TOPIC = "ciudad/parkings/estado"

# --- CAMBIO 1: Actualizar la firma de on_connect para la API v2 ---
def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("Conectado al Broker MQTT exitosamente.")
    else:
        print(f"Fallo al conectar, código de error: {reason_code}")

# --- CAMBIO 2: Usar la API v2 explícitamente ---
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="simulador_parking_01")
client.on_connect = on_connect
client.connect(BROKER_HOST, BROKER_PORT, 60)
client.loop_start()  # Inicia el loop en segundo plano

print(f"Iniciando simulación. Publicando en el topic: {TOPIC}")

try:
    # --- CAMBIO 3: Esperar activamente a que la conexión se establezca ---
    while not client.is_connected():
        print("Esperando conexión con el broker MQTT...")
        time.sleep(0.5)
    
    print("¡Conexión establecida! Comenzando a publicar.")

    # Bucle principal de publicación
    while True:
        # Simular datos de un sensor de parking
        sensor_id = f"PK-{random.randint(100, 110)}"
        estado = random.choice(["libre", "ocupado"])
        
        payload = {
            "sensor_id": sensor_id,
            "estado": estado,
            "timestamp": int(time.time())
        }
        
        # Publicar el mensaje
        payload_str = json.dumps(payload)
        result = client.publish(TOPIC, payload_str)
        
        # --- CAMBIO 4: No usar wait_for_publish() con loop_start() ---
        # Comprobamos solo si el mensaje se pudo encolar.
        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"Mensaje enviado: {payload_str}")
        else:
            print(f"Error al encolar mensaje, código: {result.rc}")
        
        # Esperar entre 5 y 10 segundos
        time.sleep(random.randint(5, 10))

except KeyboardInterrupt:
    print("\nSimulación detenida.")
finally:
    client.loop_stop()
    client.disconnect()
    print("Desconectado del Broker MQTT.")