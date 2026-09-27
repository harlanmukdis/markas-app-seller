# Colour Palette Brief — Marketplace Seller (Flutter)

A brief for producing a new colour palette for an existing Flutter app. It
describes the slots a palette has to fill and the way this app consumes
colour. It deliberately does not prescribe a visual direction — that is what
we are asking for.

Everything below was measured against the current codebase, not estimated.

---

## 1. What the product is

A **seller app** for an Indonesian marketplace: the tool a shop owner opens to
run their business. Not a consumer shopping app.

What people do in it: manage a product catalogue, track warehouse stock, work
an order queue, withdraw earnings, run vouchers and flash sales, group
products into bundles and shelves, answer buyer chat, read notifications.

How it is used: **phone-first**, portrait-locked, often one-handed and in a
shop rather than at a desk. It also builds for macOS and web. Sessions are
short and repeated through the day.

What the screens look like: dense and data-heavy. Scrolling lists of cards,
forms with many fields, small status pills, tables of numbers, currency
everywhere. Very little photography — most screens are type, rules and
small blocks of colour. Colour carries more of the hierarchy than usual here,
because the app currently ships with the platform default font rather than a
designed typeface.

Tone: plain, calm and businesslike. This is somebody's livelihood; it should
feel dependable rather than playful.

---

## 2. The palette contract

The app names fourteen colours. A new palette has to fill these slots, because
every screen refers to them by name. The usage count is how many places in the
code read each one — it is a fair proxy for how much each colour decides the
look.

| Slot | Role | Current | Uses |
|---|---|---|---|
| `kLightPrimaryColor` | Brand and action: buttons, links, selected state, key figures | `#1D55F3` | 104 |
| `kDarkPrimaryColor` | The same, on dark | `#246BFD` | 85 |
| `kLightSecondColor` | Primary text and icons | `#212121` | 74 |
| `kDarkSecondColor` | The same, on dark | `#F7F7F7` | 87 |
| `kLightThirdColor` | **Muted text** — captions, helper text, all small print | `#616161` | **158** |
| `kDarkThirdColor` | The same, on dark | `#E8E8E8` | 35 |
| `kBorderColor` | Hairlines and dividers | `#F2F2F2` | 3 |
| `kSuccessColor` | Healthy state: active, running, credited, saved | `Colors.green` | 18 |
| `kWarningColor` | Needs attention: not yet active, scheduled, muted, no discount | `Colors.deepOrangeAccent` | 31 |
| `kErrorColor` | Broken or blocked: frozen wallet, stalled sale, failed refresh | `Colors.redAccent` | 17 |
| `kWhiteColor` | Light surface: scaffold, cards, app bar | `#FFFFFF` | 55 |
| `kBlackColor` | Dark app bar and snackbar | `#000000` | 17 |
| `kDarkColor` | Dark surface: scaffold and cards | `#2B2B2B` | 18 |
| `kDeleteColor` | — | `#FF3D00` | **0** |

Two things worth acting on:

- **`kLightThirdColor` is the most-used colour in the app** — more than the
  brand colour. Nearly every card has a line of muted text under the title.
  If it is too pale the app becomes unreadable; if it is too dark the
  hierarchy collapses. Treat it as a primary decision, not a leftover.
- **`kDeleteColor` is referenced nowhere.** Drop it, or give it a real job.
- **The three status colours were never designed.** They are Flutter's stock
  `Colors.green`, `deepOrangeAccent` and `redAccent`, sitting next to a
  deliberate blue. They are the most obvious thing to fix.

---

## 3. Light and dark are explicit pairs, not derived

The app does **not** compute a dark theme from a light one. It stores both
colours and picks between them at the point of use, through a helper called
at **294 places** in the code.

So the palette must ship **both halves of every pair** for primary, secondary
text and muted text. A single hex per role is not enough.

Surfaces differ between the two in a way worth knowing:

- **Light:** white scaffold, white cards, white app bar.
- **Dark:** `#2B2B2B` scaffold and cards, **black** app bar and snackbar.

The dark app bar being pure black against a lighter scaffold is the current
behaviour; say so if you want to change it.

---

## 4. How the colours are actually used

These are the mechanics a palette has to survive. They constrain the choice
more than any style preference does.

**Status colours become pill backgrounds at 12% alpha, with the same colour
as the label on top.** A pill is `colour @ 12%` behind `colour @ 100%` text.
So every status colour must work twice: as small coloured text, and as a pale
wash behind it.

**Several of these pills appear in one list at once** — a promotions list can
show "Berjalan", "Terjadwal", "Tidak jalan" and "Berakhir" together. Success,
warning and error must stay clearly distinguishable **at 12% alpha**, not just
at full strength. This is where the current stock colours fail most visibly.

**The brand colour is used as a 6–8% tint** behind callout cards and notices
(the wallet balance card, the "one-way" notices, the chat identity banner).
It has to stay neutral and calm when washed out that far.

The full set of alpha values in use, so each can be checked:

| Alpha | Where |
|---|---|
| 0.06, 0.08 | Brand and info card tints (17 uses at 0.08) |
| 0.1, 0.12 | Status pill and banner backgrounds |
| 0.2, 0.22, 0.3 | Borders and chip outlines |
| 0.7, 0.8 | Timestamps and icons inside coloured chat bubbles |

**Muted text runs at 10–12px.** `kLightThirdColor` mostly appears in the two
smallest type styles. Contrast has to hold at that size.

---

## 5. Nine colours that currently escape the palette

These are hardcoded in shared widgets and therefore cannot be changed by
swapping the palette. The new palette should **name and absorb them**, so the
whole app becomes themeable.

| Current | Where | Suggested role |
|---|---|---|
| `#F4F6F9` | Text field fill, dropdown fill | Input surface |
| `#EDEDED` | Text field border, dropdown border | Input border |
| `#94A3B8` | Text field hint text | Hint text |
| `#F6F7FB` | Chat composer fill | Input surface (dark-mode twin needed) |
| `#F1F2F6` | Incoming chat bubble | Neutral bubble surface |
| `#F8F8F8` | App bar back-button fill | Control surface |
| `#BDD8FF` | App bar back-button ring | Control border |

Note the near-duplicates: `#F4F6F9`, `#F6F7FB` and `#F8F8F8` are three
slightly different off-whites doing the same job, and `#EDEDED` sits next to
`#F2F2F2` for borders. **Please collapse these into one input surface and one
border**, and give each a dark counterpart — several of them have none today,
which is why a few controls look wrong in dark mode.

*(A further 149 hardcoded colours live in unused template screens that ship
with the project but have no working code behind them. They are out of scope.)*

---

## 6. Technical constraints

- **Material 2**, not Material 3 (`useMaterial3: false`). No dynamic colour,
  no tonal palettes, no seed-colour generation.
- **The brand colour becomes a Material swatch.** It is expanded into the
  10-step 50→900 range at runtime. Supplying real, designed shades for the
  brand colour would be better than letting the app guess them.
- **Colours are compile-time constants** written as `Color(0xffRRGGBB)`. They
  must be plain hex. Nothing can be computed, blended or read from a file at
  startup.
- **The app does not use theme lookups.** Every widget names a colour
  directly, which is why the list in §2 is a hard contract: a colour that is
  not in it cannot be swapped later without editing screens one by one.
- **Portrait phone is the design target.** Also verify at macOS window width —
  content is capped at 640px and centred there, so wide backgrounds and narrow
  content sit together.

---

## 7. What to deliver

**A table of hex values keyed by the exact slot names in §2**, plus names and
values for the seven roles in §5 — each with a light and a dark value where
the role appears in both themes.

Preferred output, ready to paste:

```dart
const Color kLightPrimaryColor = Color(0xff1D55F3);
const Color kDarkPrimaryColor  = Color(0xff246BFD);
// …one line per slot
```

A plain `name → #hex` table is equally fine.

**Please also show, as swatches:**

1. Each status colour as it will really appear: a 12% background with the
   full-strength label on top, and the three of them side by side.
2. The brand colour at 8% behind a card of body text.
3. Muted text at 10px on both light and dark surfaces.

**Acceptance checks the palette has to pass:**

- Body text meets WCAG AA (4.5:1); muted small print meets at least 3:1 on its
  own surface.
- Success, warning and error are distinguishable from one another at 12%
  alpha, including for red–green colour blindness — they are the app's main
  state signal and they appear together.
- Brand-at-8% stays legible as a background for body text.
- Every paired role has both halves; no role in §2 or §5 is left unanswered.

Once the palette lands, applying it is a small change on our side: the fourteen
constants live in one file, and the nine loose colours in §5 move into it at
the same time.
