#!/bin/bash

# --- CONFIGURACIÓN ---
URL_WEBHOOK="https://script.google.com/macros/s/AKfycbxYS-Fj3fZEroUonK259XsMMaMceHbmdqz3y-EEmXX088lCYtGALgSlwdbOAymKZK97/exec"

# 1. Capturar el nombre del estudiante de forma interactiva
echo "========================================"
echo "      CERTIFICACIÓN DE REDES - IRSI     "
echo "========================================"
printf "👤 Nombre del Estudiante: "
read -r NOMBRE

# 2. Capturar métricas reales del sistema (Ping a Google)
echo "📡 Verificando conexión y capturando métricas..."
LAT_AVG=$(ping -c 4 google.com | tail -1 | awk -F '/' '{print $5}')
IP_REMOTA=$(ping -c 1 google.com | grep PING | awk '{print $3}' | tr -d '()')

# 3. Validación de seguridad
if [ -z "$LAT_AVG" ]; then
    echo "❌ Error: No se detecta conectividad. El reto no puede ser certificado."
    exit 1
fi

# 4. Enviar a Google Sheets
echo "🚀 Enviando reporte al panel de control..."
RESPONSE=$(curl -L -s -X POST "$URL_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"$NOMBRE\", \"ip\": \"$IP_REMOTA\", \"latencia\": \"$LAT_AVG\"}")

# 5. Resultado final
if [[ "$RESPONSE" == *"Registro Exitoso"* ]]; then
    echo "✅ ¡Felicidades $NOMBRE! Tu registro en IRSI ha sido exitoso."
else
    echo "⚠️ Respuesta del servidor: $RESPONSE"
    echo "Revisa la conexión o el script de Google."
fi