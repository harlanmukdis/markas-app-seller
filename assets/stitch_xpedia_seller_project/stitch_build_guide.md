# PANDUAN BUILD DI STITCH — XPEDIA PARTNERS SELLER APP

Tujuan: menghasilkan **44 layar yang konsisten sebagai satu aplikasi**, bukan 44 gambar lepas.

Prasyarat di folder ini: `DESIGN.md`, `Seller-Use-Case-Catalog.md`, `reference/` (52 mockup PNG).

---

# LANGKAH 0 — Setup project (sekali saja)

1. Buat project baru di Stitch, mode **Mobile**.
2. Masukkan `DESIGN.md` sebagai **design system rules** project. Jangan dilampirkan ulang tiap prompt.
3. Kirim **APP BRIEF** di bawah sebagai pesan pertama. Ini yang membuat design agent tahu bentuk seluruh aplikasi sebelum menggambar satu layar pun.
4. Jangan generate apa pun di langkah ini. Tunggu agent mengonfirmasi struktur.

## APP BRIEF — tempel persis

```
I am building the complete seller app for Xpedia, an Indonesian 3P marketplace.
Before generating any screen, understand the whole application.

PRODUCT
Xpedia Partners — the seller-side mobile app. Android and iOS, built in Flutter.
Canvas 390x844 dp. UI language: Bahasa Indonesia. Follow DESIGN.md strictly.

WHO USES IT
A seller (individual or company) running their store from a phone: taking orders,
printing waybills, managing catalog and stock, chatting with buyers, watching
performance, and withdrawing earnings.

NAVIGATION — fixed, do not invent other structures
Bottom navigation, exactly 5 items:
1. Beranda — official Xpedia updates, action-required list, store summary, shortcuts
2. Pesanan — full order lifecycle, cancellations, complaints, returns, custom orders
3. Produk — catalog, stock, variants, pricing, product promos, coverage
4. Chat — private buyer conversations
5. Akun — hub containing: Xpedia Wallet, Xpedia Growth, Campaign, Partners
   Performance, Analytics, Pengiriman, Storefront & Live, Xpedia 911, Pengaturan

THE APP HAS 44 SCREENS ACROSS 20 MODULES
Onboarding (7), verification (3), home (2), orders (8), shipping (5), products (4),
chat (2), campaign (1), growth (1), analytics (1), storefront and live (2), reviews (1),
performance (1), wallet (2), notifications (1), support (2), settings (2).

NON-NEGOTIABLE PRODUCT RULES
1. The seller NEVER sees the buyer's full name, phone, email, or street address.
   Masked as D****** and 0812****456, destination city only.
2. There is no "Terima Pesanan" button. Orders auto-enter Processing after payment.
   The commitment action is "Cetak Resi". A red "Tolak Pesanan" button exists and
   carries a warning that it affects store performance.
3. Two SLAs, both in working days: payment to waybill = 2x24 jam kerja,
   waybill to handover = 2x24 jam kerja. Missing either auto-cancels with a full refund.
4. Seller earnings always appear in this order: Total Nilai Barang, Support Ongkir
   Seller, Komisi Xpedia 5%, Xpedia Growth, Biaya Layanan, Total Pendapatan Seller.
5. Final Invoice exists only after an order is Completed. Before that, only the
   waybill and packing reference exist. They are different documents.
6. There is no public product discussion or Q&A anywhere. Buyers use private chat.
7. Chat allows text, photo, product card, order reference, return/refund shortcut, and
   system vouchers only. No documents, video, or audio. Sent messages cannot be edited
   or deleted. Show 4 message states.
8. Seller status is one of: Verified Individual, Verified Company, Official Store,
   Managed by Xpedia. Xpedia Signature is a separate award badge, never purchasable.
9. Stock modes: Infinite, Ready Stock, Low Stock, Pre-Order, Custom Order,
   Out of Stock, Discontinued. Each has its own chip.
10. Xpedia Growth is extra commission from 1% to 15%, not advertising. Never use the
    words iklan, ads, CPC, or budget. Locked for 7x24 hours once set. Unavailable to
    sellers scoring under 60 on Natural Performance.

CONSISTENCY REQUIREMENTS
- One app bar pattern, one card pattern, one list-row pattern, one empty-state pattern
  across all 44 screens.
- Status chips always use the same shape and the color pairs in DESIGN.md.
- Every primary action sits in a sticky bottom bar, height 52, full width.
- Every destructive action is a Ghost danger text button, never a filled red primary.

Confirm you understand this structure. Do not generate screens yet.
I will send screen batches next.
```

---

# LANGKAH 1 — Generate per batch, bukan per layar

Stitch bisa membuat 5 layar sekaligus dan design agent-nya menjaga konsistensi **di dalam satu batch**. Jadi kelompokkan layar yang saling berhubungan, bukan acak.

Setiap batch: lampirkan 1–2 mockup referensi dari `reference/`, dan **selalu** sertakan kalimat penolakan layout desktop:

> Use the attached images as reference for information hierarchy, terminology, and
> visual tone only. Do NOT copy the desktop layout. Redesign as native mobile screens.

## Batch 1 — Inti operasional harian ⭐ mulai dari sini

Referensi: `v11-000`, `v2-000`

```
Generate 5 screens as one coherent flow:

1. BERANDA — Info & Update Xpedia carousel (visually dominant, 3 cards with category
   tags), then "Perlu Tindakan" list with 4 actionable rows and red badges, then
   "Ringkasan Toko" 2x2 stat grid, then shortcuts. Bottom nav with Beranda active.

2. DAFTAR PESANAN — horizontal scrollable tabs: Semua, Processing, Dalam Pengiriman,
   Diterima, Selesai, Dibatalkan. Order cards showing order ID + status chip, masked
   buyer name and destination city, product thumbnail with name and item count, total,
   an SLA countdown chip when action is needed, and two buttons.

3. DETAIL PESANAN — the densest screen. In order: order meta with payment status and
   method (Xpedia Wallet), a 5-stage horizontal timeline (Payment Success, Processing,
   Delivery, Diterima, Selesai), product list with stock-mode chips, masked buyer info
   block with a lock icon and the note that full address is for delivery only,
   "Atur Pengiriman" with Drop-off and Pickup radio options plus a waybill field,
   "Rincian Pendapatan Seller" as a 6-line amount table, a Pre-Order info banner.
   Sticky bottom: Secondary "Chat Pembeli" + Primary "Cetak Resi", and below them a
   Ghost danger "Tolak Pesanan" with a performance warning line.

4. ATUR PENGIRIMAN — the expanded shipping sheet: method selection, courier selection
   from the store's enabled couriers, waybill number field with a scan icon, package
   weight, and a primary "Simpan & Cetak Resi".

5. PRATINJAU RESI — the printable shipping label preview: Xpedia waybill number with
   barcode, order code, courier service, ETA, weight, sender store and city, masked
   recipient with destination city only, package contents table, handling icons,
   and a Secure+ marker area. Primary button "Cetak" and secondary "Bagikan".
```

## Batch 2 — Pengecualian pesanan

Referensi: `v2-001`, `v2-002`

```
Generate 5 screens:
1. TOLAK PESANAN — reason selection list, free-text note, a red warning panel stating
   the impact on Cancellation Rate and store reputation, destructive confirm.
2. CUSTOM ORDER — seller confirmation screen: buyer's custom spec with attached photos,
   a 2x24 jam kerja countdown, fields for seller lead time and final price,
   buttons Approve and Reject, and a chat entry point.
3. PARTIAL FULFILLMENT — item-by-item availability toggles, a summary of what will ship
   versus what will be cancelled, and a note that the buyer decides whether to proceed.
4. PERMINTAAN PEMBATALAN — buyer's cancellation request after waybill: reason, timeline,
   order summary, and Setuju / Tolak actions with consequences stated.
5. KOMPLAIN & RETUR — buyer complaint with photo evidence thumbnails, complaint type,
   countdown to respond, and four actions: Setuju Retur & Refund, Setuju Replacement,
   Tolak Permintaan, Eskalasi ke Xpedia.
```

## Batch 3 — Katalog & stok

Referensi: `v2-007`

```
Generate 5 screens:
1. DAFTAR PRODUK — tabs Semua, Aktif, Stok Kosong, Discontinued, Draft. Product rows
   with thumbnail, name, SKU, price, stock-mode chip, stock count, overflow menu.
2. TAMBAH / EDIT PRODUK — the longest form in the app, sectioned: Media (photo slots
   with a watermark note), Informasi Produk, Mode Stok & Fulfillment (segmented control
   revealing a lead-time stepper for Pre-Order), Varian (rows each with own price and
   stock), Harga Grosir (min qty and unit price tiers), Pengiriman (weight, dimensions,
   coverage row), Deskripsi, Compliance (hazardous material flag with document upload).
   Sticky bottom: Simpan Draft and Terbitkan.
3. STATUS MODERASI — list of products under review with status chips, structured
   rejection reasons, and a resubmit action.
4. COVERAGE & LOKASI — shipping coverage per product or store, an excluded-cities list,
   and management of up to 3 warehouse locations.
5. KURIR AKTIF — list of Xpedia-integrated couriers with toggles, plus a note that
   buyers only see couriers the seller has enabled.
```

## Batch 4 — Komunikasi

Referensi: `v2-010`, `v11-009`

```
Generate 5 screens:
1. DAFTAR CHAT — conversation list sorted by latest activity, unread badges, filters
   Semua / Belum Dibaca / Pesanan.
2. RUANG CHAT — buyer masked name, "Lihat Pesanan" link, message bubbles with the 4
   message states and a typing indicator, one product card message, one order reference
   message, input bar with plus, text, emoji, camera and send. No file attachment icon.
   A footer banner warning against off-platform transactions.
3. PUSAT NOTIFIKASI — grouped Critical, Operational, Informational with read and unread
   states.
4. GLOBAL SEARCH — unified search across orders, products, buyers and help topics, with
   recent searches and grouped results.
5. FINAL INVOICE — the post-completion invoice document view with download and share.
```

## Batch 5 — Pertumbuhan & performa

Referensi: `v2-009`, `v2-013`, `v11-004`

```
Generate 5 screens:
1. CAMPAIGN — campaign list with status chips, plus a create form: target all or
   selected products, schedule, discount type, bundling, shipping support, and a
   projected final price panel for margin protection.
2. XPEDIA GROWTH — eligibility banner showing the Natural Performance score, a product
   selector, a 1% to 15% slider showing resulting Growth points out of 50, a segmented
   control Aktif 7 Hari versus Aktif Terus, a 7x24 hour lock notice, and a before/after
   comparison table. Never use advertising vocabulary.
3. ANALYTICS — monthly sales, a funnel from store visits to products viewed to clicks
   to wishlist to sold, traffic sources, new versus loyal customers, best products.
4. PARTNERS PERFORMANCE — four blocks in fixed order: Rating Toko & Kepuasan Pelanggan
   with a star distribution, Order Performance, Service Performance, Live Performance.
   Plain numbers and simple bars, no complex charts.
5. ULASAN — review list with product reference on each card, photo thumbnails, star
   filters, and a seller reply composer. Seller cannot delete reviews.
```

## Batch 6 — Uang & akun

Referensi: `v2-011`, `v2-015`

```
Generate 5 screens:
1. XPEDIA WALLET — balance card on dark navy with Saldo Tersedia and Saldo Ditahan,
   Tarik Dana and Belanja actions, bank account list capped at 3, and a transaction
   ledger with reference numbers, type chips and signed amounts.
2. PENARIKAN DANA — amount entry, destination account selection, fee summary, and a
   6-digit PIN entry step.
3. PENGATURAN TOKO — store profile, description, operating hours, language ID/EN,
   notification preferences per category.
4. KEAMANAN AKUN — password, phone, email, 2FA, device history with logout-other-devices,
   and withdrawal PIN management.
5. PRIMARY STATUS & SIGNATURE — the store's status card showing one of the four primary
   statuses, and the Xpedia Signature badge section explaining it is awarded, not bought.
```

## Batch 7 — Onboarding bagian 1

Referensi: `v11-006`

```
Generate 5 screens:
1. MASUK / DAFTAR — phone and email entry, OTP step.
2. PILIH TIPE AKUN — Individual versus Company cards with benefit bullets, plus the
   "Satu Identitas, Satu Akun" panel showing 1 KTP, 1 nomor HP, 1 email, 1 akun seller.
3. DATA IDENTITAS INDIVIDUAL — name, KTP number, phone, email, with inline validation.
4. DATA BADAN USAHA — company legal name, entity type, business documents, and PIC
   identity fields.
5. REKENING BANK — bank selection, account number, account holder name, with a note
   that the name must match the verified identity.
```

## Batch 8 — Onboarding bagian 2

```
Generate 5 screens:
1. PROFIL TOKO — store name, logo upload with review note, store description.
2. PENOLAKAN DUPLIKASI — an error state explaining that the KTP, phone, or email is
   already used by another seller account, with support entry point.
3. UNGGAH DOKUMEN VERIFIKASI — document rows with upload areas and status chips, plus
   a 2x24 jam kerja review notice.
4. STATUS VERIFIKASI — pending, approved and rejected states with structured rejection
   reasons and a resubmit action.
5. AJUKAN KAPASITAS KATALOG — request form to raise the SKU limit above 500.
```

## Batch 9 — Storefront, live & dukungan

Referensi: `v11-005`, `buy-017`, `v2-014`

```
Generate 5 screens:
1. KELOLA STOREFRONT — banner management for the 1 main plus 2 small panel layout,
   etalase list with ordering, and a buyer-view preview action.
2. LIVE SELLING — pre-live setup and the live control view with pinned products,
   viewer count, and live statistics.
3. MONITORING PENGIRIMAN — shipment list with courier, latest scan, status chips, and
   a problem-cases filter.
4. XPEDIA 911 — exactly four category cards (Pesanan, Pengiriman, Xpedia Wallet,
   Produk) and a ticket list below. No other category.
5. DETAIL TIKET — conversation thread with the Xpedia 911 Team, status, attachments,
   and a reply composer.
```

---

# LANGKAH 2 — Verifikasi tiap batch

Setelah setiap batch selesai, buka `Seller-Use-Case-Catalog.md`, cari modulnya, dan cek
**setiap use case ID** punya tempat di layar. Kalau tidak ada, layarnya bolong.

Yang paling sering meleset, urut dari yang paling sering:

| # | Pelanggaran | Perbaikan lewat Direct Edit |
|---|---|---|
| 1 | Alamat lengkap buyer ditampilkan | `Remove the full street address. Show only the destination city and a masked name D******.` |
| 2 | Muncul tombol "Terima Pesanan" | `Remove the accept button. The only commitment action is "Cetak Resi".` |
| 3 | Rincian pendapatan urutannya berubah | `Reorder the earnings rows exactly: Total Nilai Barang, Support Ongkir Seller, Komisi Xpedia 5%, Xpedia Growth, Biaya Layanan, Total Pendapatan Seller.` |
| 4 | Growth pakai bahasa iklan | `Remove all advertising vocabulary. Growth is extra commission paid only on successful sales.` |
| 5 | Invoice dan resi disamakan | `Separate these. Before Completed only the waybill exists; Final Invoice appears only after Completed.` |
| 6 | Muncul tab diskusi produk | `Remove the product discussion tab entirely. Buyers use private chat only.` |
| 7 | Chat punya ikon lampiran file | `Remove the file attachment icon. Only photo, product card, order reference, and voucher are allowed.` |

**Pakai Direct Edit, jangan regenerate.** Regenerate membakar kredit dan sering mengubah
hal lain yang sudah benar.

---

# LANGKAH 3 — Rangkai jadi prototype

Setelah batch 1 sampai 4 selesai, pakai **Prototypes** untuk menyambungkan alur utama:

`Beranda → Daftar Pesanan → Detail Pesanan → Atur Pengiriman → Pratinjau Resi`

Ini bukan sekadar demo. Menjalankan alurnya adalah cara tercepat menemukan langkah yang
hilang — misalnya tidak ada jalan kembali ke daftar setelah resi tercetak, atau countdown
SLA yang tidak muncul lagi setelah tahap kedua dimulai.

---

# ANGGARAN KREDIT

Kuota bulanan sekitar 350 generasi standar dan 200 eksperimental.

| Pos | Perkiraan |
|---|---|
| 44 layar, generasi pertama | 44 |
| Iterasi rata-rata 2x per layar | 88 |
| Direct Edit koreksi | tidak dihitung generasi penuh |
| Layar prioritas 1 dipoles di mode Pro | 8 |
| **Total** | **±140 dari 350** |

Cukup longgar. Yang membakar kuota adalah regenerate berulang karena prompt kurang
spesifik — dan itulah yang dicegah oleh app brief di Langkah 0.

---

# URUTAN YANG SAYA SARANKAN

1. Langkah 0, tunggu agent konfirmasi
2. Batch 1 → verifikasi → perbaiki lewat Direct Edit sampai benar
3. **Berhenti di sini dan review.** Batch 1 menentukan pola seluruh aplikasi
4. Batch 2, 3, 4 → prototype alur utama
5. Batch 5, 6 → 7, 8, 9
6. Export: `.zip` untuk masuk Figma lewat html.to.design, atau Flutter untuk kerangka layout
