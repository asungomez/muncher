# Muncher

## Tabla de contenidos

- [Propósito](#propósito)
- [Infraestructura](#infraestructura)
- [Configuración inicial](#configuración-inicial)
- [Controles de calidad](#controles-de-calidad)
  - [Ejecutar los controles a mano](#ejecutar-los-controles-a-mano)
  - [Qué comprueba](#qué-comprueba)
- [Memoria](#memoria)
  - [Generar la memoria](#generar-la-memoria)
- [Front-end](#front-end)
  - [Ejecutar la aplicación](#ejecutar-la-aplicación)

## Propósito

Muncher es una aplicación web pensada para facilitar la gestión integral de recetas de cocina. Permite crear nuevas recetas, importarlas desde diferentes formatos, conocer sus valores nutricionales, planificar menús y generar listas de la compra de forma automática. El objetivo principal es ofrecer una herramienta divertida y sencilla para organizar la cocina diaria y mejorar la experiencia alimentaria de los usuarios.

## Infraestructura

La aplicación está desarrollada con la siguiente arquitectura tecnológica:

- **Front-end**: Construido con Vite y React, proporcionando una experiencia rápida, interactiva y moderna para los usuarios. La interfaz permite acceder a todas las funcionalidades de la app de manera intuitiva.

- **GraphQL API**: Implementada con FastAPI y Strawberry, ofreciendo una API flexible y eficiente para manejar peticiones y mutaciones desde el front-end. Esta API gestiona la lógica principal de recetas, menús, nutrición y listas de la compra.

- **Base de Datos**: Utiliza PostgreSQL como base de datos relacional para almacenar recetas, ingredientes, información nutricional, menús y usuarios.

## Configuración inicial

Los únicos requisitos en tu máquina son **git** y **Docker**. No es necesario instalar Node.js, Yarn, LaTeX ni ninguna otra herramienta: todas viven dentro de la imagen definida en `docker/ci.Dockerfile`, que se construye automáticamente la primera vez que se necesita.

Después de clonar el repositorio, ejecuta el siguiente script para configurar los git hooks:

```
./scripts/setup-hooks.sh
```

## Controles de calidad

Los controles se gestionan con [pre-commit](https://pre-commit.com/) desde la raíz del repositorio y se ejecutan **dentro del contenedor**, tanto en tu máquina como en la integración continua. De este modo, un control que pasa en local pasa también en CI.

El hook de `pre-commit` se ejecuta automáticamente en cada commit sobre los archivos añadidos al índice. Cuando un control corrige un archivo, el commit se detiene para que revises los cambios y los añadas al índice antes de volver a intentarlo.

### Ejecutar los controles a mano

Sobre los archivos añadidos al índice:

```
./scripts/run-in-container.sh pre-commit run
```

Sobre todos los archivos del repositorio:

```
./scripts/run-in-container.sh pre-commit run --all-files
```

### Qué comprueba

- **Todos los archivos**: espacios al final de línea, salto de línea final, finales de línea, sintaxis de YAML y JSON, marcas de conflictos de fusión, claves privadas y archivos de tamaño excesivo.
- **Front-end**: ESLint y Prettier.
- **Memoria**: formateo de los archivos `.tex` con `latexindent`.

La configuración completa está en `.pre-commit-config.yaml`.

## Memoria

> El resto de esta sección y la del front-end describen todavía la ejecución en
> la máquina local. La contenedorización de la generación de la memoria y del
> servidor de desarrollo está pendiente; los controles de calidad ya se
> ejecutan dentro del contenedor.

### Prerrequisitos

- LaTex (`brew install basictex`)
- `sudo tlmgr install enumitem`

### Generar la memoria

La memoria del proyecto se encuentra en la carpeta `memoria`. Para generar el PDF, ejecuta el script `make-memoria.sh`.

```
cd memoria
./make-memoria.sh
```

El documento se genera en la carpeta `memoria/generated`.

Para actualizar el documento en vivo cuando se ejecuta el código, se puede usar el script `watch-memoria.sh`.

```
cd memoria
./watch-memoria.sh
```

## Front-end

### Ejecutar la aplicación

Prerrequisitos:

- Node.js 24
- Yarn

Instalación de dependencias y ejecución, desde el directorio `front-end`:

```
cd front-end
yarn install
yarn dev
```

La aplicación estará disponible en `http://localhost:5173`.

Para verificar la aplicación, consulta [Controles de calidad](#controles-de-calidad).
