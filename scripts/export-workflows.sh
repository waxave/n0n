#!/bin/bash
set -e

# Cargar utils
source "$(dirname "$0")/utils.sh"

ENVIRONMENT=${1:-dev}
COOKIE_FILE=".cookies/${ENVIRONMENT}.cookie"
API_URL="http://localhost:5678"
OUTPUT_DIR="./workflows"

mkdir -p "$OUTPUT_DIR"

info "📤 Exportando workflows desde '$ENVIRONMENT'..."

WORKFLOWS_JSON=$(curl -s -X GET "$API_URL/rest/workflows" -b "$COOKIE_FILE")

COUNT=$(echo "$WORKFLOWS_JSON" | jq '.data | length // 0')

if [ "$COUNT" -eq 0 ]; then
  warn "No se encontraron workflows."
else
  echo "$WORKFLOWS_JSON" | jq -c '.data[]' | while read -r workflow; do
    id=$(echo "$workflow" | jq -r '.id')
    name=$(echo "$workflow" | jq -r '.name' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -dc '[:alnum:]-')

    if [[ -z "$id" || -z "$name" ]]; then
      warn "Saltando workflow inválido"
      continue
    fi

    filename="$OUTPUT_DIR/[${id}]-${name}.json"
    info "📝 Guardando $filename"

    curl -s -X GET "$API_URL/rest/workflows/$id" -b "$COOKIE_FILE" | jq '.data' > "$filename"
  done

  success "Exportación de workflows completa"
fi
