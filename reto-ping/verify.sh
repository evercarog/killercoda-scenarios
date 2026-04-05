#!/bin/bash

# 1. ¿Se identificó?
if [ -z "$ESTUDIANTE" ]; then
  echo "⚠️ Por favor, ejecuta el Paso 1 para identificarte."
  exit 1
fi

# 2. Validar que el ping se hizo (buscando en el historial de root)
if ! grep -q "ping -c 4" /root/.bash_history; then
  echo "❌ No detecto el comando 'ping -c 4 google.com' en tu historial."
  exit 1
fi

# 3. Extraer métricas reales para IRSI
# Extraemos la IP (172.253.62.139 en tu caso) y el promedio (18.255 ms)
IP_REMOTA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')
LAT_AVG=$(ping -c 4 google.com | tail -1 | awk -F '/' '{print $5}')

# 4. Enviar al registro de IRSI (Tu Webhook de Google)
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

RESPONSE=$(curl -L -s -X POST $URL_WEBHOOK \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$ESTUDIANTE\", \"ip\": \"$IP_REMOTA\", \"latencia\": \"$LAT_AVG\"}")

if [[ "$RESPONSE" == *"Registro Exitoso"* ]]; then
  echo "✅ ¡Excelente trabajo, $ESTUDIANTE! Datos enviados a IRSI."
  exit 0
else
  echo "⚠️ Error al conectar con el servidor de notas. Intenta de nuevo."
  exit 1
fi