# Como correr el proyecto

Este documento te guiará en los pasos necesarios para ejecutar el proyecto que gestiona la base de datos del sistema del centro logístico utilizando Docker y MySQL.

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalados los siguientes programas en tu entorno de desarrollo:

- **Docker**: [Instalar Docker](https://docs.docker.com/get-docker/)
- **Make**: [Instalar Make](https://www.gnu.org/software/make/)

## Archivos Importantes

- `.env`: Contiene las variables de entorno necesarias para configurar MySQL.
- `docker-compose.yml`: Archivo de configuración de Docker Compose.
- `Estructura_db.sql`: Script SQL que crea la estructura de la base de datos.
- `population.sql`: Script SQL que inserta datos en la base de datos.
- `Makefile`: Archivo que automatiza las tareas de configuración y manejo de la base de datos.

## Pasos para Ejecutar el Proyecto

### 1. Configuración Inicial

Primero, asegúrate de tener un archivo `.env` con las configuraciones adecuadas que vienen por defecto:

```bash
MYSQL_DATABASE=CentroLogistico
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=root
```
### Recomendaciones antes de empezar
Recomiendo usar la terminal del codespace de github para trabajar con la base de datos:
1. Para ingresar dentro del repositorio del proyecto, en la parte superior aparece un icono verde que dice "<> code".
2. Presionalo y se abrira una pestaña, dentro de ella presiona el boton "Create codespace on master", y te abrira el entorno para empezar a trabajar.
3. Luego elige la terminal en la parte inferior, asegurate de estar parado sobre el directorio /workspaces/Centro_Logistico_Martin_Carchano (master) $ e ingresa los codigos mencionados a continuación.

### 2. Levantar la Instancia de Docker
Para levantar la instancia de Docher y crear la base de datos:

```bash
make up
```
Este comando hará lo siguiente:

Levantar el contenedor de Docker con MySQL.
Esperar a que MySQL esté listo para recibir conexiones.
Crear la base de datos utilizando el script Estructura_db.sql.
Poblar la base de datos con datos iniciales utilizando el script population.sql.

### 3. Crear Objetos en la Base de Datos
Para crear objetos adicionales como vistas, funciones, procedimientos almacenados, triggers, y roles de usuarios:

```bash
make objects
```
### 4. Probar la Base de Datos
Para ejecutar pruebas sobre las tablas de la base de datos y verificar su correcta creación:

```bash
make test-db
```
### 5. Acceder al Cliente de MySQL
Puedes acceder al cliente de MySQL utilizando el siguiente comando:

```bash
make access-db
```
Si quieres acceder con un usuario específico (por ejemplo, deposito_resp_user):

```bash
make access-deposito-resp-db
```
### 6. Hacer un Backup de la Base de Datos
Para hacer un respaldo de la base de datos incluyendo la estructura y los datos:

```bash
make backup-db
```
El respaldo se guardará en la carpeta ./backup/ con el nombre CentroLogistico-backup.sql.

### 7. Restaurar la Base de Datos desde un Backup
Para restaurar la base de datos desde un archivo de respaldo:

```bash
make restore-db
```
### 8. Apagar y Eliminar la Base de Datos
Para eliminar la base de datos y bajar los contenedores de Docker:

```bash
make down
```
Este comando:

Elimina la base de datos.
Detiene y elimina los contenedores de Docker.

### Información Adicional
Para más detalles sobre cómo funciona cada comando, consulta el archivo Makefile  y el README en el repositorio.
