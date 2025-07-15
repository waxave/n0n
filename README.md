## Requisitos

- Docker & Docker Compose (`docker-compose` o `docker compose`)
- Bash
- Scripts personalizados `./scripts/`:
    - `login.sh`
    - `export-credentials.sh`
    - `import-credentials.sh`
    - `export-workflows.sh`
    - `import-workflows.sh`

---

## Comandos Disponibles

### Ambiente

| Comando              | Descripción                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `make create-env`    | Crea `.env` a partir de `.env.template` si no existe.                      |
| `make dump-env`      | Exporta variables de entorno actuales (prefijo `N8N_`) al archivo `.env`.  |

---

### Comandos para el servicio

| Comando              | Descripción                                                          |
|----------------------|----------------------------------------------------------------------|
| `make start`         | Levanta el entorno con Docker y muestra la URL según el entorno.    |
| `make stop`          | Detiene los contenedores.                                            |
| `make restart`       | Reinicia el entorno (`stop` + `start`).                              |
| `make clean`         | Detiene y elimina contenedores, volúmenes y órfanos.                |
| `make reset`         | Ejecuta `clean` seguido de `start`.                                 |
| `make bootstrap`     | Inicializa todo: `.env`, contenedores, login, importaciones.         |

---

### Login

| Comando       | Descripción                                                      |
|---------------|------------------------------------------------------------------|
| `make login`  | Ejecuta `login.sh` para obtener cookie válida para el entorno.   |

---

### Comandos para exportar

| Comando                  | Descripción                                     |
|--------------------------|-------------------------------------------------|
| `make export-credentials`| Exporta credenciales del entorno actual.       |
| `make export-workflows`  | Exporta workflows del entorno actual.          |
| `make export-all`        | Ejecuta ambos comandos anteriores.             |

---

### Comandos para importar

| Comando                  | Descripción                                     |
|--------------------------|-------------------------------------------------|
| `make import-credentials`| Importa credenciales al entorno actual.        |
| `make import-workflows`  | Importa workflows al entorno actual.           |
| `make import-all`        | Ejecuta ambos comandos anteriores.             |

---

### Comandos de limpieza

| Comando              | Descripción                                |
|----------------------|--------------------------------------------|
| `make clean-credentials` | Elimina credenciales exportadas.      |
| `make clean-workflows`   | Elimina workflows exportados.         |
| `make clean-exports`     | Ejecuta ambos comandos anteriores.     |

---

### Sincronización entre entornos

| Comando                 | Descripción                                                              |
|-------------------------|--------------------------------------------------------------------------|
| `make sync-from-sandbox`| Exporta desde `sandbox` y lo importa automáticamente a `dev`.           |

---

## Variables de entorno

La mayoría de los comandos se basan en la variable `ENV`, que por defecto es `dev`.

```bash
make ENV=sandbox start
```