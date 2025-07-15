#!/bin/bash
# utils.sh - Funciones reutilizables para scripts n8n

# Mensajes de log con emojis y colores (opcional)
info() {
  echo -e "ℹ️  $*"
}

warn() {
  echo -e "⚠️  $*"
}

error() {
  echo -e "❌ $*"
}

success() {
  echo -e "✅ $*"
}

# Verifica si hay archivos JSON en un directorio
has_json_files() {
  local dir=$1
  if compgen -G "$dir/*.json" > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Verifica si una entidad (workflow, credential, etc) ya existe en n8n
# $1: endpoint (e.g. workflows, credentials)
# $2: nombre de la entidad
# $3: archivo cookie para sesión
# $4: URL base de la API
entity_exists() {
  local endpoint=$1
  local name=$2
  local cookie_file=$3
  local api_url=$4

  curl -s -b "$cookie_file" "$api_url/rest/$endpoint" \
    | jq --arg NAME "$name" '.data | map(select(.name == $NAME)) | length'
}
