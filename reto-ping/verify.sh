#!/bin/bash

# 1. Definir nombre (Forzado para pruebas)
ESTUDIANTE_NAME="Ever_Caro_Test"

# 2. Intentar capturar datos
echo "Iniciando verificación..." > /tmp/debug.log
LAT_AVG=$(ping -c 2 google.com | tail -1 | awk -F '/' '{print $5}')
IP_REMOTA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')

echo "Latencia: $LAT_AVG | IP: $IP_REMOTA" >> /tmp/debug.log

# 3. URL de tu Webhook
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

# 4. Petición con verbiose para ver errores
echo "Enviando a Google..." >> /tmp/debug.log
RESPONSE=$(curl -L -s -X POST "$URL_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$ESTUDIANTE_NAME\", \"ip\": \"$IP_REMOTA\", \"latencia\": \"$LAT_AVG\"}")

echo "Respuesta de Google: $RESPONSE" >> /tmp/debug.log

# 5. Lógica de salida
if [[ "$RESPONSE" == *"Registro Exitoso"* ]]; then
  echo "✅ ¡Conexión con IRSI Exitosa!"
  exit 0
else
  echo "❌ Error. Revisa el log con: cat /tmp/debug.log"
  echo "Respuesta recibida: $RESPONSE"
  exit 1
fi