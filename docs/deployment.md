# Despliegue

## Tabla de contenidos

- [Rol de despliegue](#rol-de-despliegue)
  - [1. Crear el proveedor de identidad OIDC](#1-crear-el-proveedor-de-identidad-oidc)
  - [2. Crear el rol](#2-crear-el-rol)
  - [3. Adjuntar la política de permisos](#3-adjuntar-la-política-de-permisos)
  - [4. Configurar GitHub](#4-configurar-github)
- [Mantener la política al día](#mantener-la-política-al-día)
- [Destruir un entorno](#destruir-un-entorno)

## Rol de despliegue

Antes de poder aprovisionar la infraestructura, la cuenta de AWS necesita un rol
que GitHub Actions pueda asumir. Es el paso previo a todo lo demás: sin él no se
puede crear ningún recurso.

Es también el único paso de configuración que no vive en una plantilla de
CloudFormation, por un motivo inevitable: las credenciales con las que se crea
un _stack_ no pueden crearse desde ese mismo _stack_.

**No se generan credenciales permanentes.** El rol se asume a través del
proveedor OIDC de GitHub, de modo que no existe ninguna clave de acceso de AWS
que guardar como secreto ni que rotar: cada ejecución intercambia su token de
GitHub, de vida breve, por credenciales temporales de AWS.

Sustituye `<ACCOUNT_ID>` por el número de la cuenta de AWS y `<REGION>` por la
región en la que se despliega.

### 1. Crear el proveedor de identidad OIDC

Basta con uno por cuenta de AWS. En la consola de IAM, entra en **Identity
providers** → **Add provider** → **OpenID Connect** e introduce:

- **Provider URL**: `https://token.actions.githubusercontent.com`
- **Audience**: `sts.amazonaws.com`

No hace falta indicar ninguna huella digital (_thumbprint_): AWS valida el
certificado TLS del proveedor contra su propia biblioteca de autoridades de
certificación de confianza y solo recurre a las huellas cuando no puede hacerlo
([documentación de AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)).

### 2. Crear el rol

Crea un rol de IAM de tipo **Web identity** asociado a ese proveedor y dale el
nombre `muncher-deployment`. El formulario de la consola pide estos valores:

| Campo | Valor |
| --- | --- |
| Identity provider | `token.actions.githubusercontent.com` |
| Audience | `sts.amazonaws.com` |
| GitHub organization | `asungomez` |
| GitHub repository | `muncher` |
| GitHub branch | *(vacío)* |

El campo **GitHub organization** espera solo la cuenta propietaria, sin el
nombre del repositorio; en una cuenta personal es el propio nombre de usuario.
El repositorio va en su propio campo y, aunque la consola lo marque como
opcional, conviene rellenarlo: si se deja vacío, la condición resultante es
`repo:asungomez/*` y cualquier repositorio de la cuenta podría asumir el rol.
Dejar **GitHub branch** vacío produce `repo:asungomez/muncher:*`, que admite
cualquier flujo de trabajo del repositorio.

Al terminar, la política de confianza del rol debe ser equivalente a esta:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:asungomez/muncher:*"
        }
      }
    }
  ]
}
```

La condición sobre `sub` es lo que impide que cualquier otro repositorio pueda
asumir el rol, por lo que nunca debe sustituirse por `*`. El patrón anterior
admite cualquier flujo de trabajo de `asungomez/muncher`; para restringir el
despliegue a la rama principal, cámbialo por una coincidencia exacta:

```
"token.actions.githubusercontent.com:sub": "repo:asungomez/muncher:ref:refs/heads/main"
```

Los formatos de la reclamación `sub` son
`repo:OWNER/REPO:ref:refs/heads/BRANCH` para un _push_,
`repo:OWNER/REPO:pull_request` para un evento de _pull request_ y
`repo:OWNER/REPO:environment:NAME` cuando el trabajo se dirige a un entorno.

> Los repositorios creados después del 15 de julio de 2026 emplean un formato
> inmutable que incorpora identificadores numéricos
> (`repo:OWNER@OWNER-ID/REPO@REPO-ID:ref:...`). Este repositorio se creó el 21
> de agosto de 2025, así que le corresponde el formato anterior. Si en algún
> momento se activan las reclamaciones inmutables, los identificadores son
> `11634351` para la cuenta y `1042066289` para el repositorio.

### 3. Adjuntar la política de permisos

Esta es la política que necesita el rol:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudFormationStacks",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack",
        "cloudformation:CreateChangeSet",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:DeleteChangeSet",
        "cloudformation:DescribeChangeSet",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStackResources",
        "cloudformation:GetTemplate",
        "cloudformation:GetTemplateSummary",
        "cloudformation:ListStackResources"
      ],
      "Resource": "arn:aws:cloudformation:<REGION>:<ACCOUNT_ID>:stack/muncher-*/*"
    },
    {
      "Sid": "CloudFormationValidate",
      "Effect": "Allow",
      "Action": ["cloudformation:ValidateTemplate", "cloudformation:ListStacks"],
      "Resource": "*"
    },
    {
      "Sid": "FrontEndBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:GetBucketTagging",
        "s3:PutEncryptionConfiguration",
        "s3:GetEncryptionConfiguration",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::muncher-*", "arn:aws:s3:::muncher-*/*"]
    },
    {
      "Sid": "CloudFrontDistributions",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:UpdateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:TagResource",
        "cloudfront:ListTagsForResource",
        "cloudfront:CreateOriginAccessControl",
        "cloudfront:UpdateOriginAccessControl",
        "cloudfront:DeleteOriginAccessControl",
        "cloudfront:GetOriginAccessControl",
        "cloudfront:GetOriginAccessControlConfig",
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "StackRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:TagRole"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/muncher-*"
    },
    {
      "Sid": "StackFunctions",
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:InvokeFunction",
        "lambda:TagResource",
        "lambda:ListTags"
      ],
      "Resource": "arn:aws:lambda:<REGION>:<ACCOUNT_ID>:function:muncher-*"
    },
    {
      "Sid": "StackLogGroups",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy",
        "logs:TagResource",
        "logs:ListTagsForResource"
      ],
      "Resource": [
        "arn:aws:logs:<REGION>:<ACCOUNT_ID>:log-group:/aws/lambda/muncher-*",
        "arn:aws:logs:<REGION>:<ACCOUNT_ID>:log-group:/aws/lambda/muncher-*:*"
      ]
    },
    {
      "Sid": "StackLogGroupsDescribe",
      "Effect": "Allow",
      "Action": "logs:DescribeLogGroups",
      "Resource": "*"
    }
  ]
}
```

Dos decisiones de esta política son deliberadas:

- **Todo está limitado al prefijo `muncher-*`**, de manera que el rol no puede
  actuar sobre ningún otro recurso de la cuenta. Los recursos de las plantillas
  deben nombrarse en consecuencia.
- **CloudFront usa `"Resource": "*"`** porque sus acciones sobre distribuciones
  no admiten ARN a nivel de recurso. Allí donde una acción sí lo permite, se
  limita.
- **`logs:DescribeLogGroups` va en su propia sentencia con `"Resource": "*"`**
  porque tampoco admite restricción por recurso: es una limitación del servicio,
  no un descuido. CloudFormation la invoca para leer el ARN del grupo de logs, de
  modo que sin ella el despliegue falla al crear el rol que lo referencia.

La política contiene exactamente lo que necesita la plantilla actual, y nada
más.

Los permisos de IAM, Lambda y CloudWatch Logs corresponden a la función que
vacía el bucket del front-end antes de que CloudFormation lo elimine, sin la
cual un bucket con contenido impediría destruir el _stack_. `iam:CreateRole` es
la entrada de mayor alcance, y está restringida al prefijo `muncher-*`
precisamente para que el rol no pueda concederse a sí mismo más permisos de los
que tiene.

### 4. Configurar GitHub

El ARN del rol no es un secreto, así que basta con una **variable** del
repositorio. En **Settings** → **Secrets and variables** → **Actions** →
**Variables**, añade:

```
AWS_DEPLOYMENT_ROLE_ARN = arn:aws:iam::<ACCOUNT_ID>:role/muncher-deployment
AWS_REGION              = <REGION>
```

A partir de ahí, un trabajo que despliegue necesita el permiso `id-token` y la
acción de credenciales:

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ vars.AWS_DEPLOYMENT_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Verify the identity
        run: aws sts get-caller-identity
```

Sin `id-token: write` no se emite ningún token OIDC y la asunción del rol
falla, que es la causa habitual de que el primer despliegue no funcione.

## Mantener la política al día

La política de permisos de este documento es la referencia: no es una copia de
otro sitio. Cada recurso nuevo que aparezca en una plantilla de CloudFormation
puede requerir permisos adicionales, y si la política se queda atrás, el
despliegue falla.

El síntoma es reconocible: CloudFormation marca el _stack_ como fallido con un
mensaje de `AccessDenied` o `is not authorized to perform` que indica la acción
denegada, y a continuación revierte los cambios.

Cuando una plantilla incorpore un recurso:

1. Determina qué acciones requieren su creación, su actualización y su
   **eliminación**. Esta última es la que se olvida con más frecuencia, y su
   ausencia solo se descubre cuando un _stack_ no se puede destruir.
2. Añádelas a la política, en la sentencia del servicio correspondiente o en
   una nueva si el servicio no aparecía.
3. Limítalas al prefijo `muncher-*` salvo que el servicio no lo admita.
4. Actualiza el rol en la cuenta de AWS para que refleje el cambio.

## Destruir un entorno

Un _stack_ se puede eliminar y volver a crear desde la plantilla, y así se
comprueba que sigue siendo desplegable de una sola pasada:

```
aws cloudformation delete-stack --stack-name muncher-<ENVIRONMENT>
```

No hace falta vaciar el bucket a mano. CloudFormation no puede eliminar un
bucket que contenga objetos, así que la plantilla incluye una función que lo
vacía justo antes: el recurso personalizado que la invoca depende del bucket,
por lo que se elimina antes que él.
