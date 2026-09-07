---
name: find-sources
description: Research a topic and return a vetted reading list with verified quotes and page numbers for the memoria. Use when the user asks to find literature, sources, references, bibliography or citations for a topic, question or section — e.g. "find sources about X", "look for literature on Y", "what can we cite for Z". Returns readings only; it never edits the memoria or the bibliography.
---

# Find sources

Given a topic, question or section of the memoria, return a shortlist of sources
the user can verify in under a minute each, with the exact passages that support
the point.

**This skill produces a reading list and nothing else.** Do not edit
`memoria/**`, do not add `\bibitem` entries, do not write prose. The user reads
the list, checks the quotes and decides what to cite. Offer to write the prose
and the bibliography entries at the end, as a separate step.

Read `agents/memoria/bibliography.md` before starting: it holds the project's
rules for what may be cited, and this skill exists to satisfy them.

## What qualifies

Rank candidates in this order, and say which tier each one is:

1. Peer-reviewed papers, journal articles and conference proceedings.
2. Books by recognised authors and publishers.
3. Publications by recognised bodies: standards organisations (IEEE, ISO,
   NIST), universities, government agencies, established consortia.
4. Official vendor or project documentation — acceptable for what a tool *is*
   or *does*, never for a general claim about engineering practice.

Blog posts, tutorials, Medium articles, marketing pages, aggregator summaries
and AI-generated content do not qualify. If the only support for a claim is a
blog post, report the claim as unsupported instead.

Every candidate must also meet the hard requirements in
`agents/memoria/bibliography.md`: freely accessible, direct and stable link, a
known page, a passage you actually read, and a passage that genuinely supports
the claim.

## Procedure

### 1. Turn the request into claims

Write down the specific claims the memoria needs to support. "Local
environments" is not a claim; "a developer's environment should resemble
production as closely as possible" is. Search for sources for each claim, not
for the topic as a whole.

### 2. Search

Use `WebSearch` for candidates, several queries in parallel. Bias queries
towards the qualifying tiers: add `pdf`, the venue (`IEEE`, `ACM`, `arXiv`,
`PLOS`, `NIST`), or `site:`-style domain hints. Prefer open-access venues,
which tend to be both citable and readable: arXiv, IEEE Access, PLOS, PubMed
Central, NIST publications, university repositories, eScholarship.

Check `memoria/src/sections/bibliography.tex` for works already cited and
prefer them when they cover the claim — a reused key is better than a new
source.

### 3. Read the passage

`WebFetch` handles HTML well. **It cannot read most PDFs**: it returns the
compressed byte stream and the answer will be "I cannot extract meaningful
passages". When that happens, WebFetch has already saved the file locally and
prints the path — extract its text instead.

There is no `pdftotext` on the host, and per
`agents/local-development/containerized-development.md` nothing gets installed
there. Extract in a throwaway container:

```bash
docker run --rm -v "<dir-with-pdfs>":/in -v "<scratchpad>":/out debian:bookworm-slim \
  bash -c 'apt-get update -qq >/dev/null 2>&1 \
    && apt-get install -y -qq poppler-utils >/dev/null 2>&1 \
    && for f in /in/*.pdf; do pdftotext -layout "$f" "/out/$(basename "$f" .pdf).txt"; done'
```

Then `grep -n` the text for the terms the claim turns on and read the
surrounding lines. Never quote a line a grep hit without reading the paragraph
around it — the sentence may be arguing the opposite, or describing a case that
does not apply.

### 4. Establish the page number

`pdftotext -layout` keeps the printed page numbers in the text, usually alone on
their own line in the running header or footer. Find the nearest ones on either
side of the passage to determine which printed page it falls on. Form feeds
(`\f`) mark PDF page breaks and can be counted as a cross-check, but the printed
number is what a reader looks for, and in a book it does not match the PDF page.

For a source with no pages — an HTML article, a numbered-rules paper, living
documentation — record the locator that does exist (rule number, section
heading) and flag it, because the project's `\bibitem` format expects a page.

### 5. Handle inaccessible sources

- **HTTP 403 or a Cloudflare interstitial**: the link is closed to automated
  access. Try to find another copy of the *same edition* — the printed
  pagination is stable across copies, so a passage located in one copy is valid
  for another. Report both links and say which one you actually read.
- **Paywalled**: drop the candidate. Do not cite from an abstract, a
  ResearchGate copy or another paper's description of it.
- **No free copy at all**: say so explicitly, name the work, and let the user
  decide. A canonical reference the user can supply themselves is worth more
  than a weak substitute chosen because it was reachable.

## What to report

For each accepted source:

- **Tier** — which of the four categories above it falls in.
- **Full reference** — authors, year, title, edition or venue, publisher.
- **Suggested citation key**, following the convention in
  `agents/memoria/bibliography.md` (first author's surname plus year).
- **Direct link**, and a note if it is a mirror rather than the publisher's copy.
- **Page** of the passage, or the locator that stands in for it.
- **The passage itself, verbatim, in its original language.** The user compares
  your quote against the source, so do not translate it here and do not
  paraphrase it. Translation happens later, when the prose is written.
- **The claim it supports**, in one line.

Then, briefly:

- **Rejected candidates** and why — paywalled, blog, wrong claim. This saves the
  user from suggesting them and shows the search was not thin.
- **Unsupported claims** — anything from step 1 you found nothing for. Say it
  plainly; an uncited paragraph the user knows about is fine, a fabricated
  citation is not.

Group the list into recommended and optional, and say which source you would
use for which sentence. Do not pad the list: three sources that each carry a
specific sentence are worth more than eight that vaguely concern the topic.

## Never

- Report a quote you did not read in the source itself.
- Guess a page number, a year, an edition, a DOI or a URL's shape.
- Present a work as free when you could not open it.
- Stretch a passage into a stronger claim than it makes; narrow the claim
  instead.
- Write into the memoria or the bibliography as part of this skill.
