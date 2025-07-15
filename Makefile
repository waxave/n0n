.PHONY: create-env dump-env start stop restart clean reset bootstrap \
        export-credentials import-credentials export-workflows import-workflows \
        export-all import-all sync-from-sandbox login \
        build-custom-nodes clean-custom-nodes

ENV ?= dev
COOKIE_FILE := .cookies/$(ENV).cookie
DOCKER_COMPOSE := $(shell command -v docker-compose >/dev/null 2>&1 && echo docker-compose || echo docker compose)
MAKE_CMD := make

create-env:
	@if [ ! -f .env ]; then \
		echo "→ Creando archivo .env desde plantilla"; \
		cp .env.template .env; \
	fi

dump-env:
	@printenv | grep '^N8N_' > .env

start:
	@$(DOCKER_COMPOSE) up -d --build
	@if grep -q '^ENV=dev' .env; then \
		PORT=$$(grep '^N8N_PORT=' .env | cut -d '=' -f2); \
		echo "🚀 n8n está iniciando en entorno DEV: http://localhost:$$PORT"; \
	else \
		echo "🚀 n8n está iniciando en entorno ${ENV} (producción/sandbox)"; \
	fi

stop:
	@echo "→ Ejecutando: $(DOCKER_COMPOSE) down"
	@$(DOCKER_COMPOSE) down

restart: stop start

clean:
	@echo "→ Ejecutando: $(DOCKER_COMPOSE) down -v --remove-orphans"
	@$(DOCKER_COMPOSE) down -v --remove-orphans

reset: clean start

bootstrap:
	@echo "→ Ejecutando: $(MAKE_CMD) create-env"
	@$(MAKE_CMD) create-env
	@echo "→ Levantando contenedores con docker-compose"
	@echo "→ Ejecutando: $(MAKE_CMD) start"
	@$(MAKE_CMD) start
	@echo "→ Importando credenciales y workflows"
	@echo "→ Ejecutando: $(MAKE_CMD) import-credentials"
	@$(MAKE_CMD) import-credentials
	@echo "→ Ejecutando: $(MAKE_CMD) import-workflows"
	@$(MAKE_CMD) import-workflows
	@echo "✅ Bootstrap completo"

login:
	@echo "→ Ejecutando login interactivo para obtener cookie"
	@./scripts/login.sh $(ENV)

export-credentials:
	@echo "→ Ejecutando: ./scripts/export-credentials.sh $(ENV)"
	@./scripts/export-credentials.sh $(ENV)

import-credentials: login
	@echo "→ Ejecutando: ./scripts/import-credentials.sh $(ENV)"
	@./scripts/import-credentials.sh $(ENV)

export-workflows: login
	@echo "→ Ejecutando: ./scripts/export-workflows.sh $(ENV)"
	@./scripts/export-workflows.sh $(ENV)

import-workflows: login
	@echo "→ Ejecutando: ./scripts/import-workflows.sh $(ENV)"
	@./scripts/import-workflows.sh $(ENV)

export-all: export-credentials export-workflows

import-all: import-credentials import-workflows

clean-credentials:
	@echo "→ Se eliminaron las credenciales $(ENV)"
	@rm -rf ./credentials

clean-workflows:
	@echo "→ Se eliminaron los workflows $(ENV)"
	@rm -rf ./workflows

clean-exports: clean-workflows clean-credentials

sync-from-sandbox:
	@echo "→ Ejecutando: $(MAKE_CMD) ENV=sandbox export-all"
	@$(MAKE_CMD) ENV=sandbox export-all
	@echo "→ Ejecutando: $(MAKE_CMD) ENV=dev import-all"
	@$(MAKE_CMD) ENV=dev import-all
