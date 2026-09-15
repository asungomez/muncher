# Styles

Read this before writing any styling: a new component, a change to an existing
one, or a decision about how something should look.

This records how the front-end is styled today. Where a task would depart from
it, that is a design decision to take deliberately and write down here.

## Look and feel

**The reference is an 80s/90s magazine: colourful, vibrant, youthful, a little
grunge.** Printed and cut out rather than rendered — cards look pasted onto the
page, headings look hand-written or rubber-stamped, edges are hard and blocks of
colour are flat.

What that means in practice, and what the existing components already do:

- **Hard black borders, not subtle ones.** `border-4 border-black` on cards and
  images, `border-2 border-black` on pills. Nothing is borderless and nothing
  fades out.
- **Solid offset shadows instead of soft ones.** The shadows in the theme are
  `4px 4px 0px 0px <colour>` — a flat block of colour offset down and right, the
  way a sticker or a print sits above the page. Never a blurred drop shadow for
  interactive elements.
- **Flat, saturated colour.** No gradients, no tints, no translucency except
  when darkening a photograph for legibility.
- **Things sit at an angle.** Recipe cards are rotated by one or two degrees,
  alternating direction, and straighten on hover (`hover:rotate-0`). The page is
  a collage, not a grid of squares.
- **A paper background, always.** The layout tiles `/page_background.png` over
  `bg-paper-stock`, so no surface is plain white except where a component
  deliberately sets it.
- **Type is loud.** Display text uses the marker or block face; body text stays
  a plain sans. Headings are large and heavy — `text-5xl`/`text-6xl` for the
  hero title.
- **Movement is mechanical, not smooth.** Buttons shift down and right on hover
  while their shadow shrinks, and press flat on click
  (`active:shadow-none active:translate-x-1 active:translate-y-1`). It behaves
  like a physical button, over 150ms.

What to avoid, because it fights the reference: rounded corners, blurred
shadows, pastel or muted palettes, gradients, glassmorphism, thin light type,
generous whitespace used as the main visual device. If a design decision would
look at home in a contemporary SaaS dashboard, it is probably wrong here.

## Tailwind, and nothing else

Styling is **Tailwind utility classes in the markup**. There are no CSS modules,
no styled-components, no per-component `.css` files, and `src/index.css` holds
only the Tailwind import and the theme.

- Compose classes with **`cn()`** from `src/utils/cn.ts` — it is `clsx` plus
  `tailwind-merge`, so later classes win over earlier ones instead of both
  ending up in the output. Use it whenever classes are conditional, come from a
  variant map, or accept a `className` prop.
- **Accept `className` and merge it last**, as `Button` does, so a caller can
  adjust spacing without the component fighting them.
- **Variants are a record from a variant name to classes**, declared outside the
  component: see `variantStyles` in `Button`, `cardVariants` in `RecipeCard`,
  `colorClasses` in `Pill`. Add a variant by extending the record and its type,
  not by adding conditionals in the markup.
- **Inline `style` is for what Tailwind cannot express** — background images,
  `clipPath`, a computed `backgroundSize`. Everything else is a class.

## The theme

Colours, shadows and fonts are defined once, in the `@theme` block of
`src/index.css`, and become Tailwind utilities automatically: `--color-primary`
gives `bg-primary` and `text-primary`, `--shadow-secondary` gives
`shadow-secondary`, `--font-marker` gives `font-marker`.

| Token | Use |
| --- | --- |
| `primary` | Green. The main action colour; `primary-hover` for its hover state. |
| `secondary` | Yellow. The second action colour, and a card background. |
| `tertiary` | Pink. Accent, and a card background. |
| `quaternary` | Cyan. Accent, and a card background. |
| `secondary-dark` | Darker yellow, used as a shadow under yellow elements. |
| `dark` | Brown-black, for text on light surfaces. |
| `paper-stock` | The page's off-white. |
| `shadow-*` | Offset block shadows; each has a `-hover` variant that is 2px instead of 4px. |
| `font-marker` | *Permanent Marker*, for hand-written display text. |
| `font-block` | *Rubik Mono One*, for heavy stamped headings such as card titles. |

**Add a colour, shadow or font by adding a token here**, not by writing a hex
value or an arbitrary shadow in a component. A hard-coded `#f472b6` in markup is
a bug even if the shade is right. Tailwind's own palette (`bg-green-500`,
`text-gray-700`) is used in a few places for incidental shades, but anything
identifying the brand belongs in the theme.

Both fonts are loaded from Google Fonts in `front-end/index.html`. A new face
needs a link there as well as a token.

## Mobile first

**Write the mobile layout as the unprefixed classes, then add breakpoints for
larger screens.** `sm:`, `md:` and `lg:` only ever widen or elaborate; they
never rescue a layout that was designed at desktop width.

- Padding grows with the viewport: `px-4 sm:px-6 lg:px-8` is the repeated
  pattern for page-level containers.
- Grids start at one column: `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`.
- Content is centred within `max-w-6xl mx-auto`, which is the shared page width.
- Where a layout genuinely differs rather than reflows, render both and toggle
  them — the hero does this with `md:hidden` and `hidden md:block`, because the
  mobile version centres over a photograph while the desktop one splits the
  screen with a diagonal. Prefer one responsive layout; use two only when the
  designs are actually different.

Check a change at a narrow viewport before a wide one. `make up` serves the app
at `http://localhost:5173`.
