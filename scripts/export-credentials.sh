#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# Cargar variables del .env (solo las necesarias que empiezan con DB_ y N8N_)
if [ -f .env ]; then
  export $(grep -E '^(DB_|N8N_)' .env | grep -v '^#' | xargs)
fi

ENVIRONMENT=${1:-dev}
DB_CONTAINER="postgres"
OUTPUT_DIR="./credentials"

mkdir -p "$OUTPUT_DIR"

info "📤 Exportando credenciales desde '$ENVIRONMENT'..."
info "DB_USER = $DB_USER"
info "DB_DATABASE = $DB_DATABASE"
info "DB_HOST = $DB_HOST"
info "DB_PORT = $DB_PORT"
info "DB_PASSWORD = ${DB_PASSWORD:+*****}"

RESULT=$(docker exec -i "$DB_CONTAINER" env PGPASSWORD="$DB_PASSWORD" psql \
  -U "$DB_USER" \
  -d "$DB_DATABASE" \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -t -A -F"," \
  -c "SELECT id, name, type FROM credentials_entity;")

if [ -n "$RESULT" ]; then
  while IFS=',' read -r id name type; do
    safe_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -dc '[:alnum:]-')
    FILENAME="${OUTPUT_DIR}/[${id}]-${safe_name}.json"
    info "📝 Guardando $FILENAME"
    cat <<EOF > "$FILENAME"
{
  "name": "$name",
  "type": "$type",
  "data": {}
}
EOF
  done <<< "$RESULT"
  success "Exportación completa"
else
  warn "No se encontraron credenciales."
fi
