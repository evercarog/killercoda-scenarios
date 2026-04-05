#!/bin/bash

# 1. Validar identificación
if [ -z "$ESTUDIANTE" ]; then
  echo "⚠️ Identificación requerida. Usa: export ESTUDIANTE='Tu Nombre'"
  exit 1
fi

# 2. Extraer datos del último ping exitoso
# Buscamos en el historial el último comando ping y extraemos IP y latencia media
LAST_PING=$(tail -n 20 ~/.bash_history | grep "ping -c 4" | tail -n 1)

if [ -z "$LAST_PING" ]; then
  echo "❌ No has ejecutado el comando solicitado: ping -c 4 google.com"
  exit 1
fi

# Simulamos la extracción de datos reales de la red para tu reporte
IP_DETECTADA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')
LATENCIA=$(ping -c 4 google.com | tail -1 | awk -F '/' '{print $5}')

# 3. Envío de telemetría a IRSI (Tu Google Sheet)
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

curl -L -X POST $URL_WEBHOOK \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$ESTUDIANTE\", \"ip\": \"$IP_DETECTADA\", \"latencia\": \"$LATENCIA\"}" \
  --silent > /dev/null

echo "✅ Verificado. Datos enviados al registro de IRSI."
exit 0