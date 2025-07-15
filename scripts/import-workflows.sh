#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
COOKIE_FILE=".cookies/${ENVIRONMENT}.cookie"
API_URL="http://localhost:5678"
WORKFLOWS_DIR="./workflows"

# Cargar funciones utilitarias
source "$(dirname "$0")/utils.sh"

info "📥 Importando workflows a '$ENVIRONMENT'..."

if has_json_files "$WORKFLOWS_DIR"; then
  for file in "$WORKFLOWS_DIR"/*.json; do
    name=$(jq -r '.name' "$file")

    if [[ -z "$name" || "$name" == "null" ]]; then
      warn "Archivo $file no tiene nombre válido."
      continue
    fi

    exists=$(entity_exists "workflows" "$name" "$COOKIE_FILE" "$API_URL")

    if [[ "$exists" -gt 0 ]]; then
      warn "Workflow '$name' ya existe. Se omitirá."
    else
      info "➕ Importando workflow '$name'"
      curl -s -X POST "$API_URL/rest/workflows" \
        -H "Content-Type: application/json" \
        -b "$COOKIE_FILE" \
        --data-binary "@$file" > /dev/null
    fi
  done

  success "Importación de workflows completa"
else
  warn "No hay archivos JSON en $WORKFLOWS_DIR para importar."
fi
