# MplusKnitrEngineQuartoRevealjs

# Quarto + Mplus reveal.js setup (notes to self)

These are my steps to get **Mplus output** to render in Quarto **reveal.js** slides with a gray box, 
line numbers, a copy button, a visible scrollbar, and a fixed number of visible lines. Also covers styling 
for **unbranded code fences** (no language).

---

## Files in this folder

- `mplus-output.css` — styles Mplus & non‑R code blocks (gray band, scrollbar, height, copy‑button spacing). **Knob:** `--mplus-visible-lines` sets visible lines.  
- `default-code-lang.lua` — sets the language of unlabeled code fences to `text` so they get line numbers + copy button + wrapper.

> If I move these, update the YAML `css:` and `filters:` paths accordingly.

---

## 1) Custom **knitr** engine for Mplus

Put this **in the first R chunk** of the document (or a reusable `_setup.R` sourced up front). Adjust the path to the Mplus binary for the machine.

```r
# Mplus engine for knitr / Quarto
knitr::knit_engines$set(mplus = function(options) {

  # 1) Save chunk code to .inp
  code <- paste(options$code, collapse = "\n")
  fileConn <- file("formplus.inp")
  writeLines(code, fileConn)
  close(fileConn)

  # 2) Run Mplus (adjust path if needed)
  # macOS example:
  system2("/Applications/Mplus/mplus", "formplus.inp")

  # 3) Read .out
  mplus_out <- readLines("formplus.out", warn = FALSE)

  # 4) Emit a fenced code block so Quarto adds line numbers + copy button
  rendered <- paste0(
    "```{.mplus .numberLines}\n",
    paste(mplus_out, collapse = "\n"),
    "\n```"
  )

  # CRUCIAL: let the markdown render
  options$results <- "asis"
  knitr::engine_output(options, code, rendered)
})
```

**Reminder:** If Mplus lives elsewhere, change the `system2()` call to the correct path.

---

## 2) Document / Project YAML

Turn on copy buttons & line numbers, load the CSS and Lua filter.

```yaml
filters:
  - default-code-lang.lua

format:
  revealjs:
    code-copy: true
    code-line-numbers: true
    css: mplus-output.css
```

> If these files are in another directory, use relative paths (e.g., `css: assets/mplus-output.css`).

---

## 3) Using the engine in slides

### Basic Mplus chunk
```{mplus}
TITLE: DCSM, MSQ sum scores from EPESE
DATA:  FILE = ex0201.dat;
...
```

### Optional smaller font for a specific chunk
When I want smaller Mplus output on a slide, **wrap the chunk** in a styled div:

````markdown
::: {style="font-size:0.80em;"}
```{mplus}
TITLE: ...
```
:::
````

*(This is **intentionally manual**; not baked into the engine.)*

---


## 5) Unbranded code fences (no language)

The **Lua filter** tags unlabeled fences as `text`, so Quarto gives them the same wrapper, line numbers, and copy button, and my CSS styles them like Mplus (but **R** chunks keep their own look).

Unlabeled example that will now behave like a normal code block:

````
```
some text lines…
```
````

---

## 7) Typical file layout

```
slides/
├─ Dual_Change_Score_Model_MSQTOT.qmd
├─ mplus-output.css
├─ default-code-lang.lua
├─ excalidraw/…
├─ figures/…
└─ data/…
```

(fin)
