# Muncher

## Tabla de contenidos

- [Propósito](#propósito)
- [Infraestructura](#infraestructura)
- [Configuración inicial](#configuración-inicial)
- [Comandos disponibles](#comandos-disponibles)
- [Controles de calidad](#controles-de-calidad)
  - [Qué comprueba](#qué-comprueba)
- [Memoria](#memoria)
- [Front-end](#front-end)

## Propósito

Muncher es una aplicación web pensada para facilitar la gestión integral de recetas de cocina. Permite crear nuevas recetas, importarlas desde diferentes formatos, conocer sus valores nutricionales, planificar menús y generar listas de la compra de forma automática. El objetivo principal es ofrecer una herramienta divertida y sencilla para organizar la cocina diaria y mejorar la experiencia alimentaria de los usuarios.

## Infraestructura

La aplicación está desarrollada con la siguiente arquitectura tecnológica:

- **Front-end**: Construido con Vite y React, proporcionando una experiencia rápida, interactiva y moderna para los usuarios. La interfaz permite acceder a todas las funcionalidades de la app de manera intuitiva.

- **GraphQL API**: Implementada con FastAPI y Strawberry, ofreciendo una API flexible y eficiente para manejar peticiones y mutaciones desde el front-end. Esta API gestiona la lógica principal de recetas, menús, nutrición y listas de la compra.

- **Base de Datos**: Utiliza PostgreSQL como base de datos relacional para almacenar recetas, ingredientes, información nutricional, menús y usuarios.

## Configuración inicial

Los únicos requisitos en tu máquina son **git** y **Docker**. No es necesario instalar Node.js, Yarn, LaTeX ni ninguna otra herramienta: todas viven dentro de las imágenes definidas en `docker/`, que se construyen automáticamente la primera vez que se necesitan.

Después de clonar el repositorio, configura los git hooks:

```
make setup
```

## Comandos disponibles

Todas las tareas del repositorio se ejecutan con `make`. Los objetivos se agrupan por subsistema en el directorio `makefiles/` y llevan el nombre de aquel sobre el que actúan.

```
make            # lista los objetivos disponibles
```

| Objetivo | Descripción |
| --- | --- |
| `make up` | Arranca el entorno local en primer plano. |
| `make front-end-up` | Arranca únicamente el servicio del front-end. |
| `make down` | Detiene el entorno local y elimina sus contenedores. |
| `make logs` | Muestra los logs del entorno en ejecución. |
| `make checks` | Ejecuta todos los controles sobre el repositorio completo. |
| `make checks-staged` | Ejecuta todos los controles sobre los archivos añadidos al índice. |
| `make front-end-lint` | Analiza el front-end con ESLint. |
| `make front-end-format` | Formatea el front-end con Prettier. |
| `make front-end-build` | Genera los artefactos desplegables del front-end. |
| `make memoria-lint` | Formatea las fuentes de la memoria con `latexindent`. |
| `make memoria-build` | Genera el PDF de la memoria en `memoria/generated`. |
| `make memoria-watch` | Regenera la memoria cada vez que cambian sus fuentes. |
| `make shell` | Abre una shell en el contenedor de controles. |
| `make setup` | Instala los git hooks. |

## Controles de calidad

Los controles se gestionan con [pre-commit](https://pre-commit.com/) desde la raíz del repositorio y se ejecutan **dentro del contenedor**, tanto en tu máquina como en la integración continua. De este modo, un control que pasa en local pasa también en CI.

El hook de `pre-commit` se ejecuta automáticamente en cada commit sobre los archivos añadidos al índice. Cuando un control corrige un archivo, el commit se detiene para que revises los cambios y los añadas al índice antes de volver a intentarlo.

Los objetivos `make front-end-lint`, `make front-end-format` y `make memoria-lint` seleccionan un control concreto de esa misma configuración, de modo que no pueden desviarse de lo que se comprueba al hacer commit.

### Qué comprueba

- **Todos los archivos**: espacios al final de línea, salto de línea final, finales de línea, sintaxis de YAML y JSON, marcas de conflictos de fusión, claves privadas y archivos de tamaño excesivo.
- **Front-end**: ESLint y Prettier.
- **Memoria**: formateo de los archivos `.tex` con `latexindent`.

La configuración completa está en `.pre-commit-config.yaml`.

## Memoria

Las fuentes de la memoria se encuentran en la carpeta `memoria` y el PDF se genera en `memoria/generated`. No hace falta instalar LaTeX: la cadena de herramientas vive en la imagen definida en `docker/memoria.Dockerfile`.

```
make memoria-build
make memoria-watch
```

## Front-end

No hace falta instalar Node.js ni Yarn, ni ejecutar `yarn install`: la cadena de herramientas y las dependencias viven en la imagen definida en `docker/front-end.Dockerfile`.

```
make up
```

La aplicación estará disponible en `http://localhost:5173`. El código fuente permanece en la máquina local y se monta en el contenedor, de modo que los cambios se recargan automáticamente en el navegador.

Para publicar el servidor en otro puerto, define `MUNCHER_FRONT_END_PORT`:

```
MUNCHER_FRONT_END_PORT=5200 make up
```

Los servicios del entorno local se declaran en `compose.yaml` y comparten una misma red, a la que se incorporarán la API y la base de datos.
