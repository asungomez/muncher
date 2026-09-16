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
- [API](#api)
  - [Dependencias](#dependencias)
- [Despliegue](#despliegue)
  - [Configurar el despliegue en tu propia cuenta](#configurar-el-despliegue-en-tu-propia-cuenta)
  - [Muro de acceso del entorno de desarrollo](#muro-de-acceso-del-entorno-de-desarrollo)
  - [Dominio propio](#dominio-propio)
    - [1. Registrar el dominio en la consola de Route 53](#1-registrar-el-dominio-en-la-consola-de-route-53)
    - [2. Definir la variable del repositorio](#2-definir-la-variable-del-repositorio)
    - [3. Volver a desplegar](#3-volver-a-desplegar)

## Propósito

Muncher es una aplicación web pensada para facilitar la gestión integral de recetas de cocina. Permite crear nuevas recetas, importarlas desde diferentes formatos, conocer sus valores nutricionales, planificar menús y generar listas de la compra de forma automática. El objetivo principal es ofrecer una herramienta divertida y sencilla para organizar la cocina diaria y mejorar la experiencia alimentaria de los usuarios.

## Infraestructura

La aplicación está desarrollada con la siguiente arquitectura tecnológica:

- **Front-end**: Construido con Vite y React, proporcionando una experiencia rápida, interactiva y moderna para los usuarios. La interfaz permite acceder a todas las funcionalidades de la app de manera intuitiva.

- **API REST**: Implementada con FastAPI, que genera la especificación OpenAPI y la documentación interactiva a partir de las anotaciones de tipo de los propios _endpoints_. Esta API gestiona la lógica principal de recetas, menús, nutrición y listas de la compra.

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
| `make up` | Arranca el entorno local completo en primer plano. |
| `make front-end-up` | Arranca únicamente el servicio del front-end. |
| `make api-up` | Arranca únicamente el servicio de la API. |
| `make down` | Detiene el entorno local y elimina sus contenedores. |
| `make logs` | Muestra los logs del entorno en ejecución. |
| `make checks` | Ejecuta todos los controles sobre el repositorio completo. |
| `make checks-staged` | Ejecuta todos los controles sobre los archivos añadidos al índice. |
| `make front-end-lint` | Analiza el front-end con ESLint. |
| `make front-end-format` | Formatea el front-end con Prettier. |
| `make front-end-build` | Genera los artefactos desplegables del front-end. |
| `make front-end-install-dep` | Añade una dependencia al front-end (`DEP=paquete@versión`; `DEV=1` para desarrollo). |
| `make front-end-remove-dep` | Elimina una dependencia del front-end (`DEP=paquete`). |
| `make api-lint` | Analiza la API con Ruff. |
| `make api-format` | Formatea la API con Ruff. |
| `make api-install-dep` | Añade una dependencia a la API (`DEP=paquete==versión`; `GROUP=grupo` para una herramienta). |
| `make api-remove-dep` | Elimina una dependencia de la API (`DEP=paquete`; `GROUP=grupo`). |
| `make api-lock` | Vuelve a resolver `api/uv.lock` a partir de `api/pyproject.toml`. |
| `make api-shell` | Abre una shell en el contenedor de la API. |
| `make memoria-lint` | Formatea las fuentes de la memoria con `latexindent`. |
| `make memoria-build` | Genera el PDF de la memoria en `memoria/generated`. |
| `make memoria-watch` | Regenera la memoria cada vez que cambian sus fuentes. |
| `make infra-lint` | Valida las plantillas de CloudFormation. |
| `make infra-deploy` | Despliega el stack del entorno indicado (`ENVIRONMENT`, por defecto `dev`). |
| `make front-end-deploy` | Compila el front-end y lo sube al entorno indicado. |
| `make shell` | Abre una shell en el contenedor de controles. |
| `make setup` | Instala los git hooks. |

## Controles de calidad

Los controles se gestionan con [pre-commit](https://pre-commit.com/) desde la raíz del repositorio y se ejecutan **dentro del contenedor**, tanto en tu máquina como en la integración continua. De este modo, un control que pasa en local pasa también en CI.

El hook de `pre-commit` se ejecuta automáticamente en cada commit sobre los archivos añadidos al índice. Cuando un control corrige un archivo, el commit se detiene para que revises los cambios y los añadas al índice antes de volver a intentarlo.

Los objetivos `make front-end-lint`, `make front-end-format`, `make api-lint`, `make api-format` y `make memoria-lint` seleccionan un control concreto de esa misma configuración, de modo que no pueden desviarse de lo que se comprueba al hacer commit.

### Qué comprueba

- **Todos los archivos**: espacios al final de línea, salto de línea final, finales de línea, sintaxis de YAML y JSON, marcas de conflictos de fusión, claves privadas y archivos de tamaño excesivo.
- **Front-end**: ESLint y Prettier.
- **API**: Ruff, como *linter* y como *formatter*. El *linter* se ejecuta con todas sus reglas activadas (`select = ["ALL"]`): las excepciones se declaran una a una, con su motivo, en `api/pyproject.toml`. El *formatter* se ejecuta después, porque las correcciones del *linter* pueden dejar código sin formatear.
- **Memoria**: formateo de los archivos `.tex` con `latexindent`.

La configuración completa está en `.pre-commit-config.yaml`.

Las versiones de las herramientas de Python que ejecuta el contenedor de controles (`pre-commit`, `cfn-lint` y Ruff) se declaran en los grupos `checks` y `lint` de `api/pyproject.toml` y quedan fijadas en `api/uv.lock`. Para actualizar una, usa `make api-install-dep DEP=paquete==versión GROUP=grupo` en lugar de editar el `Dockerfile`.

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

Los servicios del entorno local se declaran en `compose.yaml` y comparten una misma red, a la que se incorporará la base de datos.

## API

No hace falta instalar Python ni ninguna herramienta de Python: el intérprete y las dependencias viven en la imagen definida en `docker/api.Dockerfile`.

```
make up
```

Con el entorno en marcha, la API responde en `http://localhost:9100`:

| Dirección | Contenido |
| --- | --- |
| [`/recipes`](http://localhost:9100/recipes) | La colección de recetas. Por ahora está fijada en el código. |
| [`/docs`](http://localhost:9100/docs) | La documentación interactiva, donde se pueden probar los _endpoints_. |
| [`/openapi.json`](http://localhost:9100/openapi.json) | La especificación OpenAPI, que FastAPI genera a partir de las anotaciones de tipo. |

El código fuente permanece en la máquina local y se monta en el contenedor, de modo que el servidor se reinicia solo en cuanto se guarda un archivo.

Para publicar el servidor en otro puerto, define `MUNCHER_API_PORT`:

```
MUNCHER_API_PORT=9200 make up
```

Para arrancar la API sin el front-end:

```
make api-up
```

### Dependencias

Las versiones exactas de todo el árbol de dependencias —directas y transitivas— están fijadas en `api/uv.lock`, que es lo que la imagen instala. No se instala nada a mano: las dependencias se gestionan con `make`, que actualiza a la vez `api/pyproject.toml` y el archivo de bloqueo.

```
make api-install-dep DEP=httpx==0.28.1
make api-remove-dep DEP=httpx
```

Si se omite la versión, se instala la más reciente y se fija esa. Después de cambiar las dependencias, el siguiente `make up` reconstruye la imagen con ellas.

`make api-lock` vuelve a resolver el archivo de bloqueo a partir del manifiesto, lo que hace falta si se edita `api/pyproject.toml` a mano.

## Despliegue

La infraestructura se define como código en plantillas de CloudFormation y se despliega desde GitHub Actions, que asume un rol de IAM en la cuenta de AWS.

La configuración inicial de ese rol —el proveedor de identidad OIDC, las políticas y las variables del repositorio— está documentada en [docs/deployment.md](docs/deployment.md). Es el paso previo a cualquier aprovisionamiento.

Cada entorno es un stack creado a partir de `infra/muncher.yaml`, cuyo único parámetro es el nombre del entorno.

El despliegue está repartido en cuatro workflows:

| Workflow | Cometido |
| --- | --- |
| `deploy-dev.yml` | Se ejecuta con cada cambio en `main`. Detecta qué ha cambiado y llama a los dos siguientes en el orden adecuado. |
| `deploy-infra.yml` | Despliega el stack. Se ejecuta si ha cambiado algo en `infra/`. |
| `deploy-front-end.yml` | Compila el front-end y lo sube. Se ejecuta si ha cambiado algo en `front-end/`, o si se ha desplegado el stack. |
| `deploy-prod.yml` | Despliega el stack y el front-end en `prod`. Solo se lanza a mano. |

El front-end espera al stack cuando este se despliega, y arranca de inmediato cuando no hay cambios de infraestructura. `deploy-infra.yml` y `deploy-front-end.yml` pueden lanzarse por separado desde la pestaña de acciones de GitHub, indicando el entorno, y en ese caso despliegan sin comprobar si algo ha cambiado.

`prod` nunca se despliega como efecto de un `push`: requiere lanzar `deploy-prod.yml` a mano. Para exigir además una aprobación, añade revisores obligatorios al entorno `prod` en la configuración del repositorio.

### Configurar el despliegue en tu propia cuenta

Si clonas o bifurcas este repositorio, los workflows no funcionarán hasta que apuntes a una cuenta de AWS propia. Hacen falta cuatro cosas.

**1. Un rol de despliegue en AWS.** GitHub Actions no usa claves de acceso, sino que asume un rol mediante OIDC. Su creación —el proveedor de identidad, la política de confianza y los permisos— está detallada en [docs/deployment.md](docs/deployment.md). Recuerda ajustar la condición `sub` de la política de confianza a **tu** repositorio, no a este.

**2. Dos variables del repositorio.** En **Settings** → **Secrets and variables** → **Actions** → **Variables**:

| Variable | Valor |
| --- | --- |
| `AWS_DEPLOYMENT_ROLE_ARN` | ARN del rol del paso anterior. |
| `AWS_REGION` | Región en la que se despliega, por ejemplo `eu-west-1`. |

Son variables y no secretos porque ninguno de los dos valores es confidencial.

**3. Los entornos `dev` y `prod`.** En **Settings** → **Environments**, crea uno con cada nombre. Los workflows los declaran, así que GitHub los crearía por su cuenta en el primer despliegue, pero creándolos a mano puedes configurarlos antes: en `prod` conviene añadir **Required reviewers**, de modo que cada despliegue de producción espere una aprobación.

**4. Las credenciales del muro de acceso** de `dev`, como secretos de ese entorno. Se explican en la sección siguiente.

Con eso, un cambio en `main` despliega `dev`, y `prod` se despliega lanzando `deploy-prod.yml` a mano.

### Muro de acceso del entorno de desarrollo

El front-end de `dev` está protegido con una autenticación básica que resuelve el propio navegador, para que el entorno no sea accesible por cualquiera. No hay pantalla de acceso en la aplicación: es el diálogo de credenciales del navegador, servido por una función de CloudFront que se ejecuta en cada petición.

El muro existe únicamente si el despliegue recibe usuario y contraseña. Defínelos como **secretos del entorno `dev`** —no del repositorio— en **Settings** → **Environments** → **dev** → **Environment secrets**:

```
FRONTEND_LOGIN_USER
FRONTEND_LOGIN_PASSWORD
```

Ese ámbito es lo que mantiene los entornos separados: `prod` no los define, así que se sirve sin muro y no puede recibir uno por descuido. En `dev`, en cambio, la ausencia de credenciales se trata como un error y el despliegue falla en lugar de dejar el entorno accesible.

> Es una barrera contra accesos casuales, no un control de seguridad: la contraseña queda legible en el código de la función para quien tenga permiso de lectura sobre CloudFront. No reutilices una contraseña de ningún otro sitio.

### Dominio propio

Si no se configura ningún dominio, cada entorno se sirve desde su URL de CloudFront, que es lo que ocurre por defecto. Para usar un dominio propio hay un único paso manual —el registro— y el resto lo hace el despliegue.

#### 1. Registrar el dominio en la consola de Route 53

El registro de un dominio no puede automatizarse: es una compra no reembolsable, exige aceptar los términos de ICANN y, en algunos casos, verificar por correo la dirección del contacto. Por eso se hace una sola vez desde la consola.

1. Entra en la [consola de Route 53](https://console.aws.amazon.com/route53/) y ve a **Domains** → **Registered domains**.
2. Pulsa **Register domains**, escribe el dominio que quieres y pulsa **Search** para comprobar si está libre. Si lo está, aparecerá en la lista de dominios seleccionados.
3. Pulsa **Proceed to checkout**.
4. En la página **Pricing**, elige el número de años y si quieres renovación automática. Ten en cuenta que ni el registro ni las renovaciones son reembolsables.
5. En **Contact information**, rellena los datos del contacto registrante, administrativo y técnico. Conviene usar el nombre que figura en tu documento de identidad, porque algunos registros lo exigen para cambios posteriores. Aquí puedes activar también la protección de privacidad para que tus datos no aparezcan en las consultas WHOIS.
6. En **Review**, revisa los datos, marca la casilla de los términos del servicio y pulsa **Submit**.
7. Ve a **Domains** → **Requests** para seguir el estado. Si la dirección de correo del contacto registrante no se había usado antes para registrar un dominio, recibirás un correo de verificación de `noreply@registrar.amazon` (o de `noreply@domainnameverification.net`, según el registrador del TLD). **Hay que seguir sus instrucciones**: si no se verifica, ICANN obliga a suspender el dominio y deja de ser accesible.

Al completarse el registro, Route 53 crea automáticamente la zona alojada del dominio. No hace falta crearla ni configurarla: el despliegue la localiza por su nombre.

> No uses este dominio como correo del usuario raíz de esta misma cuenta de AWS. Si la cuenta se suspendiera, el dominio se suspende en cinco días, y con él el correo con el que recuperarías el acceso.

#### 2. Definir la variable del repositorio

En **Settings** → **Secrets and variables** → **Actions** → **Variables**:

```
MUNCHER_DOMAIN_NAME = muncher.com
```

Es una variable y no un secreto: un dominio es público por definición.

#### 3. Volver a desplegar

Con eso, `dev` pasa a servirse en `dev.muncher.com` y `prod` en `muncher.com`, sin subdominio. El certificado, los registros DNS y la configuración de CloudFront los crea el propio despliegue; el primero tarda unos minutos más de lo habitual, porque espera a que se emita el certificado. Los detalles y el reparto entre stacks están en [docs/deployment.md](docs/deployment.md).

Si el dominio está registrado en otro proveedor, también sirve: delega sus servidores de nombres a una zona alojada de esta cuenta. Lo que necesita el despliegue es poder escribir en esa zona.

Para desplegar desde tu máquina, con tus propias credenciales de AWS en el entorno:

```
make infra-deploy ENVIRONMENT=dev
make front-end-deploy ENVIRONMENT=dev
```

El primer comando crea o actualiza el stack; el segundo compila el front-end y sube los archivos al bucket, invalidando la caché de CloudFront.
