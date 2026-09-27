# DESIGN.md — Xpedia Partners (Seller Mobile)

Design system rules for this project. Follow these exactly. Do not invent colors,
type sizes, spacing values, or component shapes that are not listed here.

Product: Xpedia Partners — seller app for an Indonesian 3P marketplace.
Platform: Mobile first, 390 × 844 dp. Target implementation is Flutter.
Tone: operational, dense but calm, trustworthy. Not playful, not marketing-heavy.
UI language: **Bahasa Indonesia**. Keep all labels in Bahasa Indonesia.

---

## 1. Color

Use ONLY these values. Names on the left are the token names — keep them in any
code export as CSS variables or Dart constants.

### Brand
| Token | Hex | Use |
|---|---|---|
| brand-navy | #0F286C | Headers on dark surfaces, cover/hero, wordmark backdrop |
| brand-primary | #0056FE | Primary buttons, links, active tab, selected state |
| brand-primary-pressed | #0047D1 | Pressed/hover state of primary |
| brand-subtle | #EBF2FF | Selected row background, info banner, primary chip background |

### Surface & text
| Token | Hex |
|---|---|
| bg-canvas | #F7F8FA |
| bg-surface | #FFFFFF |
| bg-sunken | #EFF1F4 |
| text-primary | #111827 |
| text-secondary | #4B5563 |
| text-tertiary | #6B7280 |
| text-placeholder | #9CA3AF |
| text-on-brand | #FFFFFF |
| border-subtle | #E5E7EB |
| border-default | #D1D5DB |
| border-strong | #9CA3AF |

### Feedback
| Token | Hex | Use |
|---|---|---|
| danger | #FB132D | "Tolak Pesanan", destructive actions, SLA breach |
| danger-subtle | #FFECEE | Danger banner background |
| success | #109553 | Completed, positive delta |
| success-subtle | #E8F8EF | |
| warning | #F59E0B | Processing, needs attention |
| warning-subtle | #FFF6E5 | |

### Order status (background / foreground pairs)
| Status | Background | Foreground |
|---|---|---|
| Processing | #FFF6E5 | #8C5002 |
| Dalam Pengiriman | #EBF2FF | #0047D1 |
| Diterima | #E6F7FA | #08677B |
| Selesai | #E8F8EF | #0C7A44 |
| Dibatalkan | #EFF1F4 | #4B5563 |
| Perlu Tindakan | #FFECEE | #D10C22 |
| Pre-Order | #F1EEFE | #6344D6 |
| Custom Order | #E0D9FD | #4E34AB |
| Secure+ | #EBF2FF | #0047D1 |

### Xpedia Signature badge
Black `#101014` background with gold text/border. Gold ramp: `#E8D08A` / `#C9A227` / `#8C6E12`.
Signature is an award badge, never a purchasable tier. Render it compact and premium,
never as a loud pill.

### Dark theme
Same token names. Canvas `#0B1220`, surface `#111827`, text-primary `#F7F8FA`,
text-secondary `#9CA3AF`, border-subtle `#1F2937`, primary `#4682FF`, danger `#FD4258`,
success `#22B268`, warning stays `#F59E0B`.

---

## 2. Typography

Font family: **Inter**. No other typeface.

| Style | Size / Line height | Weight | Use |
|---|---|---|---|
| Heading/XL | 24 / 32 | 700 | Screen title |
| Heading/L | 20 / 28 | 600 | Section title |
| Heading/M | 18 / 26 | 600 | Card group title |
| Title/L | 16 / 24 | 600 | Product name, list item title |
| Title/M | 14 / 20 | 600 | Sub-section, field group label |
| Body/L | 16 / 24 | 400 | Primary paragraph |
| Body/M | 14 / 20 | 400 | Default body |
| Body/S | 12 / 18 | 400 | Helper text |
| Label/L | 14 / 20 | 500 | Button label |
| Label/M | 12 / 16 | 500 | Chip, tag |
| Label/S | 11 / 14 | 500 | Micro label, SLA countdown |
| Caption | 11 / 14 | 400 | Timestamp, meta |
| Overline | 10 / 14 | 600, +0.6 tracking | Uppercase section marker |
| Price/L | 18 / 24 | 700 | Order total |
| Price/M | 16 / 22 | 700 | Product price |
| Price/S | 14 / 20 | 600 | Line item price |
| Numeric/Stat | 22 / 28 | 700 | Dashboard KPI number |

Never use text below 11 px. Never use more than 2 weights in one card.

---

## 3. Spacing, radius, size

Spacing scale (dp): 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 64. Nothing else.
Screen horizontal padding: 16. Card inner padding: 16. Gap between cards: 12.
Gap between sections: 24.

Radius (dp): 4 (xs), 6 (sm), 8 (md, default for cards and buttons), 12 (lg),
16 (xl), 24 (2xl), full (chips, avatars, badges).

Sizes (dp): icon 16 / 20 / 24. Avatar 32 / 40 / 56. Store logo 44.
Control height: 36 small, 44 medium, 52 large. App bar 56. Bottom nav 64.
**Minimum touch target 48 × 48 dp, always.**

Borders: 1 dp hairline for dividers and card outlines. 2 dp only for focus rings.
Shadows: very light. Cards use a 1 dp border instead of a heavy shadow.
Only bottom sheets, dialogs, and FABs get a visible shadow.

---

## 4. Component rules

**Buttons.** Four styles only: Primary (filled blue), Secondary (white with
border-default), Danger (filled red), Ghost (text only, blue). Radius 8. Full-width
primary action at the bottom of a screen uses height 52.

**Status chip.** Pill shape, height 24, padding 8 horizontal, Label/M, background and
foreground from the order-status table above. Never a bare colored dot alone.

**Cards.** White surface, radius 8, 1 dp border-subtle, padding 16. No gradients.

**Order card.** Must show, in this order: order ID + status chip on one line, buyer
name (masked), product thumbnail + product name + quantity, total price, SLA countdown
if action is required, then action buttons. Never show the buyer's full address,
phone, or email.

**Empty state.** Icon, one line of Title/M, one line of Body/S, one Secondary button.
Never a large illustration that pushes content below the fold.

**Bottom navigation.** Maximum 5 items. Active item uses brand-primary; inactive uses
text-tertiary. Badge counts use danger background with white text.

---

## 5. Non-negotiable product rules

These come from the approved product blueprint. Violating them makes the screen wrong,
no matter how good it looks.

1. **Buyer privacy.** The seller never sees the buyer's full name, phone number, email,
   or street address. Render name masked as `D******`, phone as `0812****456`, and show
   only the destination city. This is a hard rule on every order surface.
2. **No "Terima Pesanan" button.** Orders auto-enter Processing after payment.
   The commitment action is **"Cetak Resi"**. There IS a **"Tolak Pesanan"** button,
   styled Danger, with a warning that it affects store performance.
3. **Two SLAs**, both in working days: 2×24 jam kerja from payment to printing the
   waybill, then another 2×24 jam kerja to hand over. Show remaining time as a
   countdown chip when under 24 hours.
4. **Seller earnings panel** on order detail, in this exact order: Total Nilai Barang,
   Support Ongkir Seller, Komisi Xpedia 5%, Xpedia Growth, Biaya Layanan,
   **Total Pendapatan Seller**. Show Rp 0 lines rather than hiding them.
5. **Final Invoice only exists after an order is Completed.** Before that, the seller
   can only print the waybill / packing reference. Never label them the same thing.
6. **No product discussion / public Q&A anywhere.** Buyer questions go through private Chat only.
7. **Chat** allows text, photo, product card, order reference, and system vouchers only.
   No file attachments, no video, no audio. Sent messages cannot be edited or deleted.
   Show 4 message states: pending, 1 grey tick, 2 grey ticks, 2 blue ticks.
8. **Seller status** is one of: Verified Individual, Verified Company, Official Store,
   Managed by Xpedia. Xpedia Signature is a separate award badge on top of that.
9. **Stock modes:** Infinite, Ready Stock, Low Stock, Pre-Order, Custom Order,
   Out of Stock, Discontinued. Each has a distinct chip.
10. **Xpedia Growth** is extra commission (1%–15%), not paid advertising. Never use the
    words "ads", "iklan", "CPC", or "budget". Growth is locked for 7×24 hours once set,
    and is unavailable to sellers whose performance score is below 60.

---

## 6. Writing style for UI copy

Bahasa Indonesia, direct and operational. Use "Pesanan", "Produk", "Pengiriman",
"Pendapatan", "Performa". Avoid exclamation marks. Avoid marketing adjectives.
Numbers use Indonesian format: `Rp 2.888.100`, `98,7%`.
Dates: `18 Jan 2025, 14:32 WIB`.
