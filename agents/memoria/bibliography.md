# Bibliographic references

Read this before adding a citation, adding a `\bibitem`, or writing any theory
section.

The memoria opens each engineering area (requirements, cloud computing, agentic
engineering, whatever comes next) with a theory section grounded in published
literature. Those citations are the document's credibility, and they are the
single easiest thing for an agent to get wrong: a plausible author, a plausible
title, a plausible page, and a claim the source never makes.

**The governing rule: every citation must be verifiable by the user in under a
minute.** They open the link, go to the page, and read the passage you
attributed to it. Anything that cannot be checked that way does not go in the
document.

## Hard requirements for a source

A source may only be cited if **all** of these hold:

1. **You have actually read the passage.** Fetch the source and read the text
   you are about to cite, in this session. Never cite from recollection of what
   a book says, never cite a work you could not open, and never reconstruct a
   reference from memory of its bibliographic details.
2. **It is freely accessible online.** A journal article published open access,
   a standards document, a vendor whitepaper, an official guide, or a book
   available as a PDF at a stable public URL. No paywalls, no login, no
   library-only access, no "available on request".
3. **The link is direct and stable.** It must land on the document itself —
   preferably the PDF — not a search page, a landing page, a Google Books
   preview, or a bookshop listing. Institutional or publisher-hosted copies
   (`nvlpubs.nist.gov`, university servers, `scrumguides.org`) are preferred
   over aggregator mirrors, because they are less likely to disappear.
4. **You can point to the page.** The `\bibitem` records the page of the exact
   passage being used, so you must know it.
5. **The source actually supports the claim.** Not "a source that sounds like it
   would say this". If the passage is weaker or narrower than the sentence you
   wanted to write, change the sentence — do not stretch the source.

If a source fails any of these, do not cite it. Say so in your report to the
user: name the claim you could not support and what you looked for. An
unsupported paragraph the user knows about is fine; a fabricated citation is
not.

## Never do this

- Invent an author, title, year, edition, publisher, page, DOI or URL.
- Guess a URL's shape from a pattern (`.../sp800-145.pdf`) without loading it.
- Cite a work whose text you only know second-hand, from a summary, or from
  another paper's description of it.
- Paraphrase a source into a stronger claim than it makes.
- Attribute a well-known general idea to a specific page you have not opened,
  even when the attribution is almost certainly right.
- Leave a `\cite{...}` pointing at a key with no `\bibitem`, or add a `\bibitem`
  nothing cites.

## Finding sources

To research a topic and come back with candidate sources, use the
`find-sources` skill (`/find-sources <topic or question>`). It applies the rules
below and returns a reading list — references, links, pages and verbatim
passages — without writing anything into the memoria. Citing what it finds is a
separate, deliberate step.

## Reuse before adding

`memoria/src/sections/bibliography.tex` already lists the works below. Prefer
citing these over finding new sources for the same point, and never create a
second `\bibitem` for a work already listed.

| Key | Work |
| --- | --- |
| `Beck2001` | Manifesto for Agile Software Development |
| `Cohn2004` | Cohn — User Stories Applied |
| `Cohn2005` | Cohn — Agile Estimating and Planning |
| `DSDM2014` | DSDM Agile Project Framework Handbook (MoSCoW) |
| `Grance2011` | NIST Definition of Cloud Computing (SP 800-145) |
| `IEEE830-1998` | IEEE Std 830-1998, Software Requirements Specifications |
| `Karlsson1997` | Karlsson & Ryan — A Cost–Value Approach for Prioritizing Requirements |
| `Morris2016` | Morris — Infrastructure as Code |
| `PMI2021` | PMBOK Guide, 7th ed. |
| `Schwaber2020` | Schwaber & Sutherland — The Scrum Guide (2020) |
| `Sommerville2010` | Sommerville — Software Engineering, 9th ed. |
| `Wiegers2013` | Wiegers & Beatty — Software Requirements, 3rd ed. |

## `\bibitem` format

Entries live inside the `thebibliography` environment in
`memoria/src/sections/bibliography.tex`, sorted **alphabetically by the citation
key**, and follow an APA-style shape over four lines:

```latex
\bibitem{Grance2011}
Grance, T., \& Mell, P. (2011).
\textit{The NIST Definition of Cloud Computing} (Special Publication 800-145, p. 2).
National Institute of Standards and Technology.
\url{https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-145.pdf}
```

- **Key**: first author's surname plus year — `Sommerville2010`, `Cohn2005`. For
  a standard, its designation — `IEEE830-1998`. For a corporate author, a short
  name plus year — `PMI2021`, `DSDM2014`. Disambiguate same-author-same-year
  with a letter suffix.
- **Line 1**: authors as `Apellido, I.`, separated by commas with `\&` before
  the last, then `(year).` Corporate authors are written out in full.
- **Line 2**: `\textit{Title}` followed by a parenthetical carrying the edition
  and the page of the cited passage — `(9th ed., p. 83)`, `(1st ed., p. 4)`, or
  a document number where there is no edition.
- **Line 3**: publisher or issuing body. Omitted for a web-native source like
  `Beck2001`.
- **Line 4**: `\url{...}` with the direct link. Percent-encode spaces as `%20`.

The parenthetical page is the page of the passage that section cites. When you
cite a *different* passage of a work already listed, do not add a second
`\bibitem` — give the page in the prose alongside the `\cite{...}` and leave the
existing entry alone. (This is a known rough edge in the current convention;
flag it to the user if it starts to bite.)

## Citing in the prose

- `\cite{Key}` goes at the end of the sentence or clause it supports, before the
  full stop: `…reflejando las necesidades de los clientes \cite{Sommerville2010}.`
- Naming the author in the sentence is the house style and reads better than a
  bare citation: `Según Sommerville \cite{Sommerville2010}, …` or
  `(Wiegers y Beatty \cite{Wiegers2013})`.
- **The default is a cited paraphrase, not a literal quotation.** Explain the
  idea in the memoria's own Spanish prose and attribute it. Reserve a verbatim
  quotation for the occasional case where the source's exact wording is the
  point — a definition, a standard's normative sentence, a memorable formulation
  — and keep those short.
- Sources are in English and the memoria is in Spanish (see [tone.md](tone.md)),
  so both paraphrases and quotations are rendered into Spanish. Do it faithfully
  and conservatively: the user will compare your Spanish against the English on
  the cited page, so a loose or flattering rendering reads as a fabrication.
- When a verbatim quotation is used, put it in double quotes immediately
  followed by the citation: `Como señalan Karlsson y Ryan \cite{Karlsson1997},
  "un conocimiento claro e inequívoco sobre las prioridades…"`.
- Every substantive theoretical claim in a theory section carries a citation.
  Descriptions of Muncher's own decisions do not — those are the project's, not
  the literature's.

## Before you finish

- Every new `\cite{...}` resolves to a `\bibitem`, and vice versa.
- Every new `\bibitem` link was opened in this session and rendered the document.
- Every paraphrase, quotation and page number was read off that document, not
  inferred.
- New entries sit in alphabetical position by key.
- Tell the user, per new source: the key, the link, the page, and the sentence
  in the memoria it supports — so they can check each one directly.
