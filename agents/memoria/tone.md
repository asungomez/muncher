# Tone and voice

Applies to every piece of prose written into `memoria/src/**` — sections,
introductions, retrospectives, figure captions, macro field content. Read it
before writing or editing any text in the memoria.

## Language

**The memoria is written entirely in Spanish (Spain).** No exceptions: prose,
headings, list items, table headers, captions and the content of macro keys are
all Spanish. `babel` is loaded with `spanish` as the main language.

Terms that stay in their original form:

- Product and tool names: *Muncher*, *Vite*, *React*, *FastAPI*, *GitHub*,
  *PostgreSQL*.
- Established technical terms with no settled Spanish equivalent: *sprint*,
  *front-end*, *testing*, *commit*, *deploy*, *runtime*. Prefer the Spanish term
  when one is genuinely in use (*historia de usuario*, not *user story*;
  *requerimiento*, not *requirement*; *listas de la compra*, not *shopping
  lists*).
- **Names of cloud services and their concepts are never translated**: *stack*,
  not *pila*; *bucket*, not *cubo*. This applies wherever the project writes
  Spanish, including the documents under `docs/`, not only the memoria. The
  exception is *plantilla* for *template*, which is established usage and stays
  in Spanish.

**Never translate a technical term literally when the result is not what
Spanish-speaking practitioners actually say.** A literal rendering reads as
translated text even when each word is correct — *tiempo de ejecución* for
*runtime* is the canonical example, and it is wrong here regardless of being a
dictionary-accurate gloss. When no established Spanish term exists, keep the
English one in `\textit{...}`. Note that *entorno de ejecución* for *execution
environment* is idiomatic and stays in Spanish; the test is usage, not
etymology.
- Method and framework names quoted as such: *MoSCoW*, *Must Have*,
  *Should Have*, *DSDM*.

Keep terminology consistent with what the document already uses — the same
concept must always get the same word.

## Register

The memoria is an academic technical report. Write it as such:

- **Formal and impersonal.** Third person and passive/impersonal constructions:
  *se presentan los requerimientos*, *el sistema permitirá*, *esta sección
  establece*. Never first person singular (*yo*, *he decidido*), never address
  the reader as *tú* or *usted*, no rhetorical questions to the reader.
- **Explanatory, not telegraphic.** Full, well-formed paragraphs of several
  sentences. A section does not open with a bullet list; it opens with prose
  that frames what follows and why it matters.
- **Justified.** Do not merely state a decision — explain the reasoning and its
  consequences. When a claim rests on an external source, cite it with
  `\cite{...}` (see [bibliography.md](bibliography.md) once written).
- **Measured.** Avoid marketing language, superlatives and hype
  (*revolucionario*, *la mejor solución*, *increíblemente rápido*). Claims stay
  proportionate to the evidence: *permite*, *reduce*, *facilita* rather than
  *garantiza* unless it truly does.
- **No filler.** Skip empty transitions and self-congratulation. Every paragraph
  should add information.

## Tense

- Requirements and planned behaviour: future — *el sistema permitirá…*.
- Descriptions of the document itself and of the state of the art: present —
  *esta sección analiza…*, *la mayoría de las soluciones se especializa en…*.
- Sprint retrospectives and completed work: past — *el sprint finalizó con
  éxito…*.

## Structure conventions

- Sections and subsections are unnumbered (`\section*`, `\subsection*`,
  `\subsubsection*`) and each is followed by its matching
  `\addcontentsline{toc}{...}{...}` so it still appears in the table of
  contents.
- Headings are sentence case in Spanish: *Requerimientos funcionales*, not
  *Requerimientos Funcionales*.
- Every list, table or figure is introduced by a sentence of prose that says
  what it contains.
- Emphasis of key terms uses `\textbf{...}`; the product name is normally
  written `\textbf{Muncher}` when introduced in a paragraph.
- Quotations from sources go in double quotes followed by the `\cite{...}`.

## Formatting of the source

- Files use tabs for indentation.
- Both hard-wrapped (~80 columns) and single-line paragraphs exist in the
  sources. Match whatever the file being edited already does rather than
  reflowing it — reflowing turns a small change into an unreadable diff.
- `latexindent` runs on staged `.tex` files via the pre-commit hook, so leave
  alignment of table columns to it instead of hand-tuning.
