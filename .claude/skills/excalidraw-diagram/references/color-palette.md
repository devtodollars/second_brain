# Color Palette — DevToDollars Brand

Single source of truth for all Excalidraw diagram colors and fonts.

---

## Brand Colors

| Name | Hex | Usage |
|------|-----|-------|
| Gold (Primary) | `#ffca28` | Primary accent, highlights, CTA elements |
| Dark (Background) | `#1b1b1d` | Dark backgrounds, evidence artifacts |
| Charcoal | `#343434` | Secondary dark surfaces |
| Mid-grey | `#424242` | Borders, dividers |
| White | `#ffffff` | Text on dark, diagram background |
| Green | `#00813a` | Success, output, results |
| Green Light | `#00c65a` | Hover/active green |
| Orange | `#c87020` | Warnings, external integrations |

---

## Font

Excalidraw supports 4 built-in font families only (custom fonts like Montserrat/WoodHeinzNo2 cannot be embedded in JSON).

**Use `fontFamily: 2`** (Nunito) — clean, rounded sans-serif, closest match to Montserrat.

| fontFamily value | Font | When to use |
|-----------------|------|-------------|
| `2` | Nunito | All diagram text (default) |
| `3` | Cascadia Code | Code snippets / evidence artifacts only |
| `1` | Excalifont | Avoid (hand-drawn, off-brand) |

---

## Semantic Shape Colors

Each semantic purpose has a `backgroundColor` (fill) + `strokeColor` pair.

| Purpose | Fill | Stroke |
|---------|------|--------|
| Start / Input / Trigger | `#fff8e1` | `#ffca28` |
| End / Output / Result | `#e6f4ea` | `#00813a` |
| Process / Action / Step | `#f5f5f5` | `#343434` |
| Decision / Condition | `#fff3e0` | `#c87020` |
| AI / LLM / Model | `#1b1b1d` | `#ffca28` |
| Error / Warning | `#fff3e0` | `#c87020` |
| External / Integration | `#fafafa` | `#424242` |
| Storage / Database | `#e6f4ea` | `#00813a` |
| Primary (default) | `#ffffff` | `#1b1b1d` |
| Secondary / Supporting | `#f5f5f5` | `#424242` |
| Emphasis / Hero | `#1b1b1d` | `#ffca28` |

---

## Text Hierarchy Colors

| Level | strokeColor | fontSize | fontFamily | Use |
|-------|------------|----------|------------|-----|
| Title | `#1b1b1d` | 28 | `2` | Diagram title |
| Section heading | `#343434` | 20 | `2` | Section labels |
| Body | `#424242` | 16 | `2` | Main labels |
| Detail / Annotation | `#606060` | 13 | `2` | Supporting text |
| On-dark text | `#ffffff` | 16 | `2` | Text inside dark shapes |
| On-dark accent | `#ffca28` | 16 | `2` | Highlighted text on dark |

---

## Evidence Artifact Colors (Code / JSON Blocks)

Use `fontFamily: 3` (Cascadia Code) for all code blocks.

| Element | Color |
|---------|-------|
| Background (`backgroundColor`) | `#1b1b1d` |
| Stroke (`strokeColor`) | `#343434` |
| Text (general) | `#ffffff` |
| String values | `#ffca28` |
| Keys / labels | `#00c65a` |
| Numbers / values | `#c87020` |
| Comments | `#606060` |

> Note: Excalidraw text is a single color per element. Use `#ffffff` for general code text, and use `#ffca28` for key labels when a snippet highlights a specific value.

---

## Arrow / Line Colors

| Purpose | strokeColor | strokeWidth |
|---------|------------|-------------|
| Primary flow | `#1b1b1d` | `2` |
| Secondary / supporting | `#424242` | `1` |
| Emphasis / critical path | `#ffca28` | `3` |
| Dashed divider | `#bdbdbd` | `1` |
| Success path | `#00813a` | `2` |

---

## Diagram Background

`viewBackgroundColor: "#ffffff"` — white background (clean, works in both light and dark contexts).

For dark-mode style diagrams, use `"#1b1b1d"` as the background and flip text to `#ffffff`.
