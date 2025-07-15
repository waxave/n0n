#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
COOKIE_DIR=".cookies"
COOKIE_FILE="$COOKIE_DIR/${ENVIRONMENT}.cookie"
API_URL="http://localhost:5678"

mkdir -p "$COOKIE_DIR"

function test_cookie() {
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -b "$COOKIE_FILE" "$API_URL/rest/workflows")
  if [ "$HTTP_CODE" -eq 200 ]; then
    return 0
  else
    return 1
  fi
}

if [ -f "$COOKIE_FILE" ] && test_cookie; then
  echo "✅ Cookie existente y válida encontrada en $COOKIE_FILE"
else
  echo "⚠️ Cookie no encontrada o inválida. Debes iniciar sesión."

  read -p "Usuario n8n: " USERNAME
  read -s -p "Contraseña n8n: " PASSWORD
  echo

  echo "🔐 Haciendo login como $USERNAME en $ENVIRONMENT..."

  RESPONSE=$(curl -s -X POST "$API_URL/rest/login" \
    -c "$COOKIE_FILE" \
    -H "Content-Type: application/json" \
    -d "{\"emailOrLdapLoginId\":\"$USERNAME\", \"password\":\"$PASSWORD\"}")

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo "✅ Login exitoso. Cookie guardada en $COOKIE_FILE"
  else
    echo "❌ Error de login:"
    echo "$RESPONSE"
    exit 1
  fi
fi
