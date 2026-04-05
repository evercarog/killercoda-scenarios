#!/bin/bash

# 1. Si la variable no existe, pedirla interactivamente
if [ -z "$ESTUDIANTE" ]; then
  echo "------------------------------------------------"
  echo "📝 REGISTRO DE ESTUDIANTE IRSI"
  echo "------------------------------------------------"
  printf "Por favor, ingresa tu nombre completo: "
  read -r ESTUDIANTE
  
  # Validar que no lo deje en blanco
  if [ -z "$ESTUDIANTE" ]; then
    echo "⚠️ Error: El nombre es obligatorio para registrar la nota."
    exit 1
  fi
  # Exportar para que quede en la sesión actual
  export ESTUDIANTE
fi

# 2. Verificar que el ping se realizó
# Buscamos en el historial del shell actual
if ! history | grep -q "ping -c 4"; then
  echo "❌ Error: No se detecta el comando 'ping -c 4 google.com'."
  echo "Debes ejecutar el paso 2 antes de finalizar."
  exit 1
fi

# 3. Extraer métricas reales
IP_REMOTA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')
LAT_AVG=$(ping -c 4 google.com | tail -1 | awk -F '/' '{print $5}')

# 4. Enviar a Google Sheets
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

echo "📡 Enviando reporte a IRSI..."
RESPONSE=$(curl -L -s -X POST "$URL_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$ESTUDIANTE\", \"ip\": \"$IP_REMOTA\", \"latencia\": \"$LAT_AVG\"}")

if [[ "$RESPONSE" == *"Registro Exitoso"* ]]; then
  echo "✅ ¡Excelente trabajo, $ESTUDIANTE!"
  echo "Tu resultado ha sido registrado correctamente."
  exit 0
else
  echo "⚠️ Error de conexión. Revisa el Apps Script o la URL."
  exit 1
fi