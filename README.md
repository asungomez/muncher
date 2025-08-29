# Muncher

## Tabla de contenidos

- [Propósito](#propósito)
- [Infraestructura](#infraestructura)
- [Memoria](#memoria)
  - [Prerrequisitos](#prerrequisitos)
  - [Generar la memoria](#generar-la-memoria)
- [Front-end](#front-end)
  - [Ejecutar la aplicación como un proceso Node.js](#ejecutar-la-aplicación-como-un-proceso-nodejs)

## Propósito

Muncher es una aplicación web pensada para facilitar la gestión integral de recetas de cocina. Permite crear nuevas recetas, importarlas desde diferentes formatos, conocer sus valores nutricionales, planificar menús y generar listas de la compra de forma automática. El objetivo principal es ofrecer una herramienta divertida y sencilla para organizar la cocina diaria y mejorar la experiencia alimentaria de los usuarios.

## Infraestructura

La aplicación está desarrollada con la siguiente arquitectura tecnológica:

- **Front-end**: Construido con Vite y React, proporcionando una experiencia rápida, interactiva y moderna para los usuarios. La interfaz permite acceder a todas las funcionalidades de la app de manera intuitiva.

- **GraphQL API**: Implementada con FastAPI y Strawberry, ofreciendo una API flexible y eficiente para manejar peticiones y mutaciones desde el front-end. Esta API gestiona la lógica principal de recetas, menús, nutrición y listas de la compra.

- **Base de Datos**: Utiliza PostgreSQL como base de datos relacional para almacenar recetas, ingredientes, información nutricional, menús y usuarios.

## Memoria

### Prerrequisitos

- LaTex

### Generar la memoria

La memoria del proyecto se encuentra en la carpeta `memoria`. Para generar el PDF, ejecuta el script `make_memoria.sh`.

```
cd memoria
./make_memoria.sh
```

El documento se genera en la carpeta `memoria/generated`.

Para actualizar el documento en vivo cuando se ejecuta el código, se puede usar el script `watch-memoria.sh`.

```
cd memoria
./watch-memoria.sh
```

## Front-end

### Ejecutar la aplicación como un proceso Node.js

Prerrequisitos:

- Node.js 24
- Yarn

Instalación de dependencias:

```
yarn install
```

Ejecución:

```
yarn dev
```

La aplicación estará disponible en `http://localhost:5173`.

### Verificar la aplicación

Los controles automáticos de calidad se ejecutan en cada Pull Request. Para ejecutarlos localmente, se puede usar el siguiente comando:

```
yarn lint:ci
yarn format:ci
```

Si alguno de los controles falla, existen comandos para corregir los errores automáticamente:

```
yarn lint
yarn format
```
