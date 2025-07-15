#!/bin/bash
set -e

# Cargar utils
source "$(dirname "$0")/utils.sh"

ENVIRONMENT=${1:-dev}
COOKIE_FILE=".cookies/${ENVIRONMENT}.cookie"
API_URL="http://localhost:5678"
CREDENTIALS_DIR="./credentials"

info "📥 Importando credenciales a '$ENVIRONMENT'..."

if has_json_files "$CREDENTIALS_DIR"; then
  for file in "$CREDENTIALS_DIR"/*.json; do
    info " file = '$file'..."
    name=$(jq -r '.name' "$file")

    info " name = '$name'..."
    if [[ -z "$name" || "$name" == "null" ]]; then
      warn "Archivo $file no tiene nombre válido."
      continue
    fi

    exists=$(entity_exists "credentials" "$name" "$COOKIE_FILE" "$API_URL")

    if [[ "$exists" -gt 0 ]]; then
      warn "Credencial '$name' ya existe."
    else
      info "➕ Se importó credencial '$name'"
      curl -s -X POST "$API_URL/rest/credentials" \
        -H "Content-Type: application/json" \
        -b "$COOKIE_FILE" \
        --data-binary "@$file" > /dev/null
    fi
  done
else
  warn "No hay archivos JSON en $CREDENTIALS_DIR para importar."
fi

success "Importación de credenciales completa"
