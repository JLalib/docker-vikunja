# 🗂️ Vikunja en Docker

![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Vikunja](https://img.shields.io/badge/Vikunja-Self--Hosted-2563eb)
![SQLite](https://img.shields.io/badge/DB-SQLite-003B57?logo=sqlite&logoColor=white)
![Bash](https://img.shields.io/badge/Script-Bash-4EAA25?logo=gnubash&logoColor=white)

Despliegue de **[Vikunja](https://vikunja.io)**, un gestor de tareas autohospedado y ligero (tareas, fechas límite, notas, checklists y varias vistas), con Docker Compose y un script para gestionar usuarios.

## 🎬 Vídeo

[![Ver el vídeo en YouTube](https://img.youtube.com/vi/MYvLmPzhUlQ/maxresdefault.jpg)](https://youtu.be/MYvLmPzhUlQ)

👉 https://youtu.be/MYvLmPzhUlQ

## 📁 Estructura

```text
vikunja/
├── docker-compose.yml
├── vikunja-users.sh
├── db/       # base de datos SQLite
└── files/    # adjuntos
```

## 🚀 Instalación

### 1. Clona el repo y crea las carpetas

```bash
git clone https://github.com/jlalib/TU_REPO.git
cd TU_REPO
mkdir -p files db
```

### 2. `docker-compose.yml`

```yaml
services:
  vikunja:
    image: vikunja/vikunja:latest
    container_name: vikunja
    restart: unless-stopped
    environment:
      VIKUNJA_SERVICE_PUBLICURL: http://TU_IP:3456/
      VIKUNJA_DATABASE_TYPE: sqlite
      VIKUNJA_DATABASE_PATH: /db/vikunja.db
      VIKUNJA_SERVICE_JWTSECRET: cambia-esto-por-un-secreto-largo
      VIKUNJA_SERVICE_ENABLEREGISTRATION: "false"
    ports:
      - "3456:3456"
    volumes:
      - ./files:/app/vikunja/files
      - ./db:/db
```

> [!IMPORTANT]
> Cambia `TU_IP` por la IP o dominio de tu servidor y genera un `JWTSECRET` aleatorio, por ejemplo con `openssl rand -hex 32`.

### 3. Permisos

El contenedor corre como `uid=1000`, así que las carpetas deben ser escribibles por ese usuario:

```bash
sudo chown -R 1000:0 ./files ./db
```

### 4. Arranca

```bash
docker compose up -d
docker compose logs -f vikunja
```

Abre `http://TU_IP:3456`.

## 🔧 Problemas frecuentes

| Error | Causa | Solución |
|-------|-------|----------|
| `mkdir /app/vikunja/files/.tmp: permission denied` | Las carpetas las creó `root` | `sudo chown -R 1000:0 ./files ./db` y `docker compose up -d` |

## 👤 Gestión de usuarios

El registro público está desactivado (`VIKUNJA_SERVICE_ENABLEREGISTRATION: "false"`), así que los usuarios se crean por línea de comandos con `vikunja-users.sh`.

```bash
chmod +x vikunja-users.sh
./vikunja-users.sh
```

### `vikunja-users.sh`

```bash
#!/bin/bash

CONTAINER="vikunja"
BIN="/app/vikunja/vikunja"
LINE="------------------------------------------"

vk() {
    docker exec -i "$CONTAINER" "$BIN" "$@"
}

list_users() {
    echo "$LINE"
    echo -e "\e[0;32mUser list:\e[00m"
    vk user list
}

create_user() {
    read -rp "Enter the username: " username
    read -rsp "Enter the password: " password
    echo
    read -rp "Enter the email address: " email

    vk user create -e "$email" -p "$password" -u "$username"
}

delete_user() {
    list_users
    read -rp "Enter the ID of the user you want to delete: " userID

    # Con -c -n borra directamente, sin confirmación
    vk user delete "$userID" -c -n
}

main() {
    while true; do
        echo "$LINE"
        echo -e "\e[0;32mWhat action would you like to perform?\e[00m"
        echo "1. List users"
        echo "2. Create user"
        echo "3. Delete user"
        echo "4. Exit"
        echo "$LINE"

        read -rp "Enter the number of the action you want to perform: " option

        case $option in
            1) list_users ;;
            2) create_user ;;
            3) delete_user ;;
            4) echo -e "\e[0;32mExiting.\e[00m"; exit 0 ;;
            *) echo "Invalid option. Please select a valid option." ;;
        esac
    done
}

main
```

> [!WARNING]
> El borrado de usuarios es destructivo y no se puede deshacer. Además, la contraseña se pasa con `-p`, por lo que queda visible un instante en la lista de procesos del host.

## 🛠️ Mantenimiento

```bash
# Actualizar
docker compose pull && docker compose up -d

# Backup (db + adjuntos)
tar czf vikunja-backup-$(date +%F).tar.gz db files
```

Consejo: en lugar de `latest`, fija una versión concreta de la imagen y revisa las notas de versión antes de actualizar.

## 📚 Referencias

- [Web oficial de Vikunja](https://vikunja.io)
- [Documentación](https://vikunja.io/docs/)
- [Repositorio oficial](https://github.com/go-vikunja/vikunja)
- [Post en el blog](https://genbyte.blogspot.com)

## 🌍 GENBYTE

[![YouTube](https://img.shields.io/badge/YouTube-GENBYTE-FF0000?logo=youtube&logoColor=white)](https://www.youtube.com/@genbyte?sub_confirmation=1)
[![Blog](https://img.shields.io/badge/Blog-genbyte.blogspot.com-FF5722?logo=blogger&logoColor=white)](https://genbyte.blogspot.com)
[![GitHub](https://img.shields.io/badge/GitHub-jlalib-181717?logo=github)](https://github.com/jlalib)
