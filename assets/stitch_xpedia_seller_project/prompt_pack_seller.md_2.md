# PROMPT PACK — Xpedia Partners Seller (Google Stitch)

Cara pakai:
1. Buat project baru di Stitch, mode **Mobile**.
2. Unggah / tempel `DESIGN.md` lebih dulu sebagai design-system rules project.
3. Generate per layar dengan prompt di bawah. Pakai **Flash** untuk draft, simpan **Pro/Thinking** untuk layar final.
4. Jangan regenerate untuk perubahan kecil — pakai **Direct Edit**.
5. Urutan penting: S01 → S05 dulu. Itu tulang punggung produk; sisanya mewarisi polanya.

Catatan: setiap prompt sudah menyebut aturan privasi dan SLA secara eksplisit, karena
model cenderung "membantu" dengan menambahkan nama lengkap dan alamat buyer kalau tidak dilarang.

---

## S01 — Onboarding: pilih tipe akun

```
Mobile screen, 390x844. Seller registration step 1 of 3: choose account type.
Top app bar with back arrow and title "Daftar Jadi Partner". A 3-step progress
indicator: "Tipe Akun" (active), "Dokumen", "Verifikasi".
Two large selectable cards stacked vertically:
- "Individual" — icon of a person, subtitle "Untuk penjual perorangan atau usaha rumahan",
  three checkmark bullets: "Mulai jualan cepat", "Pakai KTP pribadi", "Cocok untuk usaha kecil".
- "Company" — icon of a building, subtitle "Untuk badan usaha terdaftar (PT, CV)",
  bullets: "Pakai dokumen legal perusahaan", "Tunjuk PIC", "Kapasitas katalog 500+ SKU".
The selected card has a brand-primary border and a filled radio dot.
Below the cards, an info panel with brand-subtle background titled "Satu Identitas, Satu Akun"
and four small items in a 2x2 grid: "1 KTP", "1 Nomor HP", "1 Email", "1 Akun Seller".
Bottom: full-width primary button "Lanjutkan" (height 52).
```

## S02 — Verifikasi KYC: unggah dokumen

```
Mobile screen. Title "Unggah Dokumen". Step 2 of 3 active.
A list of upload rows, each a card: document name in Title/M, helper text in Body/S,
a status chip on the right, and a dashed upload area when empty.
Rows: "KTP" (chip "Terunggah", success), "Selfie dengan KTP" (chip "Terunggah"),
"NPWP" (empty, dashed area with camera icon and "Ambil foto atau unggah"),
"Rekening Bank" (empty).
Below, a warning-subtle banner: "Dokumen diverifikasi maksimal 2x24 jam kerja.
Toko belum bisa menjual sebelum verifikasi disetujui."
Bottom: full-width primary button "Kirim untuk Verifikasi", disabled state shown.
```

## S03 — Home / Dashboard seller

```
Mobile screen, scrollable. Top app bar: store avatar 40dp, store name "Toko Makmur Jaya",
seller status chip "Verified Company", notification bell with red badge "3".
Section 1 — "Info & Update Xpedia": a horizontal carousel of 3 announcement cards with
small category tags ("PENGUMUMAN RESMI", "UPDATE SISTEM", "PROGRAM PROMO"), each with a
title, one line of body, and a "Lihat Detail" link. This section is visually dominant.
Section 2 — "Perlu Tindakan": a vertical list of 4 rows, each with an icon, a label,
a count, and a chevron: "2 pesanan lewat SLA" (danger), "4 permintaan pembatalan",
"3 permintaan retur", "5 produk stok menipis". Red badges only where actionable.
Section 3 — "Ringkasan Toko": a 2x2 grid of stat cards, each with a Numeric/Stat number,
a label, and a small delta: "Pesanan Baru 12 (+20%)", "Perlu Dikirim 8",
"Dalam Pengiriman 15", "Saldo Wallet Rp 12.460.000".
Bottom navigation, 5 items: Beranda (active), Pesanan (badge 12), Produk, Chat (badge 8), Akun.
```

## S04 — Daftar Pesanan

```
Mobile screen. App bar title "Pesanan" with a search icon.
Scrollable horizontal tab bar: "Semua", "Processing" (active), "Dalam Pengiriman",
"Diterima", "Selesai", "Dibatalkan". Active tab has a brand-primary underline.
A filter row below: chips "Semua Kurir", "30 Hari Terakhir".
A vertical list of order cards. Each card shows:
- Row 1: order ID "XP2501182765" in Label/M and a status chip on the right.
- Row 2: masked buyer name "D******" and destination "Kota Jakarta Selatan".
- Row 3: 48dp product thumbnail, product name in Title/L (2 lines max), "2 barang".
- Row 4: "Total Pendapatan" label and price in Price/L.
- Row 5: an SLA countdown chip in danger-subtle, "Sisa 6 jam 45 menit untuk cetak resi".
- Row 6: two buttons side by side — Secondary "Chat Pembeli", Primary "Cetak Resi".
Never show buyer phone, email, or street address.
```

## S05 — Detail Pesanan

```
Mobile screen, scrollable, the most information-dense screen in the app.
App bar: back arrow, "Detail Pesanan", help icon.
Block 1 — order meta: order ID with copy icon, checkout date, payment status chip
"Payment Success", payment method "Xpedia Wallet".
Block 2 — a horizontal 5-step timeline: Payment Success (done), Processing (current),
Delivery, Diterima, Selesai. Completed steps use success, the current step uses brand-primary.
Block 3 — "Detail Produk (2 barang)": two product rows, each with a thumbnail,
name, a stock-mode chip ("Ready Stock" / "Pre-Order"), variant, quantity, and price.
Block 4 — "Informasi Pembeli": masked name "D******", masked phone "0812****456",
destination "Kota Jakarta Selatan" only, and a buyer note in a quoted style.
Add a small lock icon with the caption "Alamat lengkap hanya untuk keperluan pengiriman."
Block 5 — "Atur Pengiriman": two radio options, "Drop-off ke Kurir / Logistik" and
"Pickup / Dijemput di Lokasi Seller", plus a waybill number field with a scan icon.
Block 6 — "Rincian Pendapatan Seller", a right-aligned amount table in this exact order:
Total Nilai Barang Rp 3.198.000, Support Ongkir Seller −Rp 150.000,
Komisi Xpedia 5% −Rp 159.900, Xpedia Growth −Rp 0, Biaya Layanan Rp 0,
then a divider and Total Pendapatan Seller Rp 2.888.100 in Price/L.
Block 7 — an info banner: "Pesanan ini mengandung item Pre-Order. Seluruh pesanan
dikirim sekaligus setelah item dengan lead time terlama siap."
Sticky bottom bar: Secondary "Chat Pembeli", Primary "Cetak Resi" (height 52),
and below them a Ghost danger text button "Tolak Pesanan" with a small warning line
"Menolak pesanan memengaruhi performa toko Anda."
```

## S06 — Daftar Produk

```
Mobile screen. App bar "Produk" with search and a "+ Tambah" button.
Tabs: "Semua (124)", "Aktif (98)", "Stok Kosong (12)", "Discontinued (8)", "Draft (6)".
Filter chips: "Semua Kategori", "Semua Mode Stok".
List of product rows: 56dp thumbnail, product name in Title/L, SKU in Caption,
price in Price/M, a stock-mode chip (Ready Stock / Infinite / Low Stock / Pre-Order /
Custom Order), stock count, and a three-dot menu.
Low Stock rows show the count in warning color.
Discontinued rows are dimmed with a grey chip.
```

## S07 — Tambah / Edit Produk

```
Mobile screen, long form, sectioned.
Section "Media": a horizontal row of image slots, the first marked "Utama",
plus an "+ Tambah Foto" dashed slot. Caption: "Semua foto produk diberi watermark Xpedia."
Section "Informasi Produk": product name field, category picker row, brand picker row.
Section "Mode Stok & Fulfillment": a segmented control with Ready Stock / Infinite /
Pre-Order / Custom Order. When Pre-Order is selected, reveal a "Lead time" stepper in days.
Section "Varian": a list of variant rows, each with variant name, its own price field and
its own stock field, plus "+ Tambah Varian".
Section "Harga Grosir": tier rows of "Min. qty" and "Harga satuan", plus "+ Tambah Tier".
Section "Pengiriman": weight field, dimension fields, and a "Coverage Pengiriman" row
showing "Seluruh Indonesia kecuali 3 kota" with a chevron.
Sticky bottom: Secondary "Simpan Draft", Primary "Terbitkan".
```

## S08 — Partners Performance

```
Mobile screen. App bar "Performa". A month selector chip "September 2026".
An info line: "Performa dihitung per bulan kalender dan diterapkan ke bulan berikutnya."
Block 1 — "Rating Toko & Kepuasan Pelanggan": a large 4,9/5 with stars, review count,
and a 5-to-1 star distribution bar chart.
Block 2 — "Order Performance": a 2x2 grid — Pesanan Selesai 31.621, Pembatalan 0,8%,
Rasio Pesanan Berhasil 98,7%, Total Transaksi Sukses 32,1K. Each with a small delta arrow.
Block 3 — "Service Performance": Response Rate 99,2%, Rata-rata Balas Chat ≤ 4 menit,
Jam Operasional 08:00–22:00, Tingkat Penyelesaian Masalah 98,5%.
Block 4 — "Live Performance": Total Jam Live 320 jam, Jumlah Sesi 48, Checkout dari Live 3,2K,
Rata-rata Penonton 1,2K.
Keep it light: plain numbers and simple bars, no complex charts.
```

## S09 — Xpedia Growth

```
Mobile screen. App bar "Xpedia Growth".
Hero explainer card on brand-subtle: title "Lebih Banyak Dilihat, Lebih Banyak Terjual",
body "Xpedia Growth bukan iklan berbayar. Anda hanya membayar komisi tambahan saat
produk benar-benar terjual.", and a "Pelajari" link.
Eligibility banner: "Skor Natural Performance Anda 78. Growth aktif." in success-subtle.
A product picker row with a thumbnail and name.
The core control: a slider from 1% to 15% with the current value shown large
("10%") and, beside it, the resulting boost "27,2 poin dari 50".
Below the slider, a segmented control: "Aktif 7 Hari" / "Aktif Terus".
A lock notice in warning-subtle: "Pengaturan terkunci 7x24 jam setelah disimpan."
A small before/after comparison table: Tayangan, Klik, Terjual — each with a
"Tanpa Growth" and "Dengan Growth" column.
Bottom: full-width primary "Simpan Pengaturan".
Never use the words iklan, ads, CPC, or budget anywhere on this screen.
```

## S10 — Chat

```
Mobile screen, conversation view.
App bar: back arrow, buyer masked name "D******", online dot, and a "Lihat Pesanan" link.
Message list with two alignments. Seller messages are brand-primary bubbles with white
text; buyer messages are white bubbles with a border.
Include one product card message: a thumbnail, product name, price, and a "Lihat Produk" link.
Include one order reference message: order ID, status chip, and "Lihat Detail Pesanan".
Show the four message states on seller bubbles: pending (clock), 1 grey tick, 2 grey ticks,
2 blue ticks. Include a typing indicator with three dots.
Input bar at the bottom: a plus button, a text field "Ketik pesan...", an emoji icon,
a camera icon, and a send button. No attachment or file icon.
A thin footer banner: "Chat Xpedia aman dan terpercaya. Jangan bertransaksi di luar Xpedia."
```

## S11 — Xpedia Wallet

```
Mobile screen. App bar "Xpedia Wallet".
A balance card on brand-navy: label "Saldo Tersedia" and a large Rp 4.320.000,
below it two secondary items "Saldo Ditahan Rp 560.000" and "Bulan Ini Rp 12.450.000".
Two buttons on the card: "Tarik Dana" and "Belanja".
Below the card, "Rekening Bank": a list of up to 3 bank rows, each with the bank name,
masked account number, account holder, and a "Utama" chip on the default one.
An "+ Tambah Rekening" row, disabled once there are 3, with the caption
"Maksimal 3 rekening terverifikasi."
"Riwayat Transaksi": tabs Semua / Masuk / Keluar / Penarikan, then rows with a reference
number, description, date, a type chip, and a signed amount in success or danger.
```

## S12 — Xpedia 911

```
Mobile screen. App bar "Xpedia 911" with the subtitle "Bantuan 24 Jam".
A 2x2 grid of exactly four category cards, each with an icon, a title and one line of
helper text: "Pesanan" (pembatalan, refund, status), "Pengiriman" (resi, keterlambatan,
kurir), "Xpedia Wallet" (saldo, pencairan, transaksi), "Produk" (unggah, edit, moderasi).
Do not add any other category.
Below, "Tiket Saya": a list of ticket rows with a ticket ID, subject, a status chip
(Baru / Diproses / Menunggu Balasan / Selesai), and the last-update timestamp.
Bottom: full-width primary "Buat Permintaan Baru" and a secondary "Live Chat" row
with the note "Tim Xpedia 911 siap membantu.".
```

---

# Urutan generate yang saya sarankan

| Prioritas | Layar | Alasan |
|---|---|---|
| 1 | S05 Detail Pesanan | Layar terpadat dan paling banyak aturan. Kalau ini benar, sisanya mudah |
| 2 | S03 Home | Menentukan hierarki dan pola kartu |
| 3 | S04 Daftar Pesanan | Menentukan pola list + status chip |
| 4 | S10 Chat | Aturan paling spesifik (4 status pesan, tanpa attachment) |
| 5 | S09 Growth | Konsep paling mudah salah dipahami model |
| 6 | Sisanya | Mewarisi pola dari lima di atas |

# Setelah generate

1. Export **.zip** (bukan Paste to Figma kalau kamu memakai agent Pro — ekspor langsung ke Figma tidak tersedia di agent itu).
2. Untuk masuk ke Figma: buka plugin **html.to.design**, unggah .zip-nya.
3. Untuk kode: export **Flutter**, tapi perlakukan sebagai kerangka layout saja — bukan implementasi design system. Token tetap dari file Figma kita, bukan dari output Stitch.
