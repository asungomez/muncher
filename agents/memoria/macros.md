# Macros: requirements and user stories

Requirements and user stories in the memoria are **never** written as ad-hoc
prose or hand-built tables. They are declared with the custom LaTeX macros
defined in `memoria/src/macros.tex` (already `\input` by `memoria/src/index.tex`,
so no extra include is needed) and referenced with their companion `*ref`
macros.

All macro keys and all content are written in Spanish. Source files use tabs for
indentation.

## `\req` — declare a requirement

Lives in `memoria/src/sections/requirements.tex`, under the `\subsubsection*`
for its category.

```latex
\req[
	identificador=RF-GU-01,
	titulo={Registro de usuarios},
	descripcion={El sistema permitirá a los usuarios registrarse en la aplicación.},
	prioridad={Must Have}
]
```

Keys (all required, declared in this order):

| Key | Value |
| --- | --- |
| `identificador` | `RF-XX-YY` (functional) or `RNF-XX-YY` (non-functional). Unbraced. |
| `titulo` | Short noun phrase naming the requirement. |
| `descripcion` | One sentence, future tense: `El sistema permitirá…`. |
| `prioridad` | MoSCoW: `Must Have`, `Should Have`, `Could Have` or `Won't Have This Time`. |

`YY` is a two-digit sequential number **within its category**, starting at `01`.
New requirements append to the end of their category's list — never renumber
existing ones, since identifiers are cited throughout the document.

Existing categories (`XX`):

- Functional (`RF-`): `GU` gestión de usuarios · `IR` introducción de recetas ·
  `PM` planificación de menús · `VN` consulta de valores nutricionales ·
  `LC` gestión de listas de la compra.
- Non-functional (`RNF-`): `CO` compatibilidad · `IA` inteligencia artificial ·
  `CA` calidad · `DE` despliegue · `MO` monitorización · `SE` seguridad ·
  `RE` rendimiento · `US` usabilidad.

Adding a new category means also adding it to the `itemize` list that introduces
the category codes in `requirements.tex`, plus its own `\subsubsection*` with an
`\addcontentsline`.

## `\us` — declare a user story

Lives in `memoria/src/sections/user-stories.tex` (Anexo I), under the
`\subsection*` for its group.

```latex
\us[
	identificador=US-CI-01,
	titulo={Creación del repositorio de código},
	como={Desarrollador},
	quiero={Controlar las versiones de mi código, compartirlo con otros compañeros y mantener copias de seguridad para mejorar el acceso al mismo},
	requerimientos={\reqref{RNF-CA-01}, \reqref{RNF-DE-02}},
	puntos={1},
	criterios={
			\begin{itemize}
				\item El repositorio de código en la nube existe.
				\item Es accesible por todos los desarrolladores.
				\item Incluye instrucciones de uso.
			\end{itemize}
		},
	tareas={
			\begin{itemize}
				\item Inicialización de Git en un directorio local.
				\item Creación de un repositorio en Github.
				\item Redacción de las instrucciones de uso en un README.
			\end{itemize}
		}
]
```

Keys (all required, declared in this order):

| Key | Value |
| --- | --- |
| `identificador` | `US-XX-YY`. Unbraced. |
| `titulo` | Short noun phrase naming the story. |
| `como` | The role, e.g. `Desarrollador`, `Usuario`. |
| `quiero` | The goal, phrased as the value the role gets — no leading "quiero". |
| `requerimientos` | Comma-separated `\reqref{...}` calls for every requirement the story traces to. At least one. |
| `puntos` | Story points from the Fibonacci scale: `1`, `2`, `3`, `5` or `8`. |
| `criterios` | Acceptance criteria as an `itemize`. |
| `tareas` | Tasks as an `itemize`. |

Existing groups (`XX`): `CI` configuración inicial · `DE` despliegue en la nube ·
`MF` maquetación del front-end.

Same numbering rule as requirements: sequential within the group, append only,
never renumber. Every story must trace to at least one requirement via
`requerimientos` — that traceability is an explicit promise made in the prose
that opens Anexo I.

## `\reqref` / `\usref` — reference by identifier

Never write a bare identifier in prose or in a table. Use the reference macros,
which render the identifier in monospace and make it a clickable hyperlink to
the declaration:

```latex
\reqref{RNF-SE-01}
\usref{US-CI-01}
```

`\req` and `\us` create the `req:<id>` / `us:<id>` labels the references resolve
to, so the identifier passed to a `*ref` macro must match a declared one exactly
— a typo compiles to a broken link, not an error.

`\usref` is also how stories are listed in the sprint tables of
`memoria/src/sections/evolution.tex`.
