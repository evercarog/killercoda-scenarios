#!/bin/bash

# 1. Pedir nombre si no existe
if [ -z "$ESTUDIANTE" ]; then
  echo "------------------------------------------------"
  echo "📝 REGISTRO DE ESTUDIANTE IRSI"
  echo "------------------------------------------------"
  printf "Por favor, ingresa tu nombre completo: "
  read -r ESTUDIANTE
  
  if [ -z "$ESTUDIANTE" ]; then
    echo "⚠️ Error: El nombre es obligatorio."
    exit 1
  fi
  export ESTUDIANTE
fi

# 2. VALIDACIÓN TÉCNICA (En lugar de historial)
# Intentamos capturar la latencia. Si falla, es que no hay conexión o no se hizo el ping.
LAT_AVG=$(ping -c 4 google.com | tail -1 | awk -F '/' '{print $5}')

if [ -z "$LAT_AVG" ]; then
  echo "❌ Error: No se pudo obtener métricas de red."
  echo "Asegúrate de haber ejecutado el ping correctamente."
  exit 1
fi

# 3. Extraer IP remota
IP_REMOTA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')

# 4. Enviar a Google Sheets
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

echo "📡 Enviando reporte a IRSI..."

# Usamos --max-time para que el script no se quede colgado si falla el internet
RESPONSE=$(curl -L -s --max-time 10 -X POST "$URL_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$ESTUDIANTE\", \"ip\": \"$IP_REMOTA\", \"latencia\": \"$LAT_AVG\"}")

# Depuración: Si falla, mostramos qué respondió el servidor (útil para ti)
if [[ "$RESPONSE" == *"Registro Exitoso"* ]]; then
  echo "✅ ¡Excelente trabajo, $ESTUDIANTE!"
  echo "Tu resultado ha sido registrado correctamente en el panel de IRSI."
  exit 0
else
  echo "⚠️ El servidor de IRSI respondió: $RESPONSE"
  echo "Revisa si el Apps Script está publicado como 'Cualquiera' (Anyone)."
  exit 1
fi