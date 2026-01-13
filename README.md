# Muncher

## Tabla de contenidos

- [Propósito](#propósito)
- [Infraestructura](#infraestructura)
- [Configuración inicial](#configuración-inicial)
  - [Formateo de LaTeX (opcional)](#formateo-de-latex-opcional)
- [Memoria](#memoria)
  - [Prerrequisitos](#prerrequisitos)
  - [Generar la memoria](#generar-la-memoria)
- [Front-end](#front-end)
  - [Ejecutar la aplicación como un proceso Node.js](#ejecutar-la-aplicación-como-un-proceso-nodejs)
  - [Verificar la aplicación](#verificar-la-aplicación)

## Propósito

Muncher es una aplicación web pensada para facilitar la gestión integral de recetas de cocina. Permite crear nuevas recetas, importarlas desde diferentes formatos, conocer sus valores nutricionales, planificar menús y generar listas de la compra de forma automática. El objetivo principal es ofrecer una herramienta divertida y sencilla para organizar la cocina diaria y mejorar la experiencia alimentaria de los usuarios.

## Infraestructura

La aplicación está desarrollada con la siguiente arquitectura tecnológica:

- **Front-end**: Construido con Vite y React, proporcionando una experiencia rápida, interactiva y moderna para los usuarios. La interfaz permite acceder a todas las funcionalidades de la app de manera intuitiva.

- **GraphQL API**: Implementada con FastAPI y Strawberry, ofreciendo una API flexible y eficiente para manejar peticiones y mutaciones desde el front-end. Esta API gestiona la lógica principal de recetas, menús, nutrición y listas de la compra.

- **Base de Datos**: Utiliza PostgreSQL como base de datos relacional para almacenar recetas, ingredientes, información nutricional, menús y usuarios.

## Configuración inicial

Después de clonar el repositorio, ejecuta el siguiente script para configurar los git hooks:

```
./scripts/setup-hooks.sh
```

Este script configura un pre-commit hook que automáticamente:

- **Front-end**: Ejecuta ESLint y Prettier sobre los archivos staged.
- **Memoria**: Formatea archivos LaTeX con `latexindent` (opcional).

### Formateo de LaTeX (opcional)

El pre-commit hook puede formatear automáticamente los archivos `.tex` usando `latexindent`. Esta herramienta viene incluida con TeX Live, pero requiere dependencias de Perl adicionales.

**Con permisos de administrador:**

```bash
sudo cpan File::HomeDir Log::Log4perl Log::Dispatch Unicode::GCString
```

**Sin permisos de administrador (usando cpanminus):**

```bash
# Instalar cpanminus con local::lib
curl -L https://cpanmin.us | perl - --local-lib=~/perl5 App::cpanminus

# Activar local::lib
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Instalar las dependencias
cpanm File::HomeDir Log::Log4perl Log::Dispatch Unicode::GCString
```

Después de instalar sin permisos de administrador, añade esta línea a tu `~/.zshrc` para que persista:

```bash
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
```

Puedes verificar que funciona con:

```bash
echo "\\section{test}" | latexindent -s
```

Si `latexindent` no está disponible o no funciona, el hook simplemente omitirá el formateo de LaTeX y continuará sin errores.

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
