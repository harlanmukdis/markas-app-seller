# 🗺️ PETA ARSITEKTUR & GROUPING 44 LAYAR — XPEDIA PARTNERS SELLER APP

Dokumen panduan visual dan arsitektur pengelompokan (*grouping & cluster layout*) untuk seluruh 44 layar aplikasi seller **Xpedia Partners** pada Canvas.

---

## 🧭 Panduan Tata Letak Grid pada Canvas (13 Klaster Modul)

Untuk kemudahan navigasi, review tim produk, dan pembuatan prototype alur interaktif, susun seluruh layar ke dalam 13 blok klaster berikut:

```
┌────────────────────────────────────────────────────────────────────────┐
│ BARIS 1: ALUR PENDAFTARAN & IDENTITAS MITRA                            │
│ [Klaster 1: Onboarding (S-01 s/d S-07)]  →  [Klaster 2: Verifikasi (S-08 s/d S-10)]
├────────────────────────────────────────────────────────────────────────┤
│ BARIS 2: CORE OPERASIONAL HARIAN (TULANG PUNGGUNG APLIKASI)             │
│ [Klaster 3: Beranda (S-11, S-12)]  →  [Klaster 4: Pesanan (S-13, S-14, S-15, S-16, S-17, S-18, S-19, S-20)]
├────────────────────────────────────────────────────────────────────────┤
│ BARIS 3: LOGISTIK, KATALOG & KOMUNIKASI                                │
│ [Klaster 5: Logistik (S-21 s/d S-25)]  │  [Klaster 6: Produk (S-26 s/d S-28)]  │  [Klaster 7: Chat (S-29, S-30)]
├────────────────────────────────────────────────────────────────────────┤
│ BARIS 4: PERTUMBUHAN, KINERJA & STOREFRONT                             │
│ [Klaster 8: Growth & Promo (S-31, S-32)] │ [Klaster 9: Performa & Data (S-33, S-35)] │ [Klaster 10: Storefront & Live (S-34, S-36, S-37)]
├────────────────────────────────────────────────────────────────────────┤
│ BARIS 5: KEUANGAN, NOTIFIKASI & PUSAT DUKUNGAN                         │
│ [Klaster 11: Wallet & Payout (S-38, S-39)] │ [Klaster 12: Notifikasi & 911 (S-40 s/d S-42)] │ [Klaster 13: Akun & Keamanan (S-43, S-44)]
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Rincian 13 Klaster Modul

### 1️⃣ Klaster Onboarding & Registrasi Toko (`ONB`)
*Fokus: Akuisisi partner baru, validasi identitas, dan pencegahan duplikasi data.*
1. **S-01** — Masuk & Daftar Partner (Input HP & Email OTP)
2. **S-02** — Pilih Tipe Akun (Individual vs Company + Info 1 KTP 1 Akun)
3. **S-03** — Data Identitas Individual (Formulir KTP & Nama Lengkap)
4. **S-03b** — Data Badan Usaha & PIC (Khusus Akun Company & Dokumen Legal)
5. **S-04** — Rekening Bank Toko (Rekening Wajib Sama dengan Nama Terdaftar)
6. **S-05** — Profil Toko & Unggah Logo (Nama Toko & Watermark Policy)
7. **S-06** — Penolakan Duplikasi Identitas (Deteksi KTP/HP Terdaftar)
8. **S-07** — Ajukan Kapasitas Katalog (Permohonan Kuota SKU >500)

---

### 2️⃣ Klaster Verifikasi Toko & Kredensial Resmi (`VER`)
*Fokus: Kepatuhan merchant dan status legitimasi toko di platform.*
9. **S-08** — Unggah Dokumen Verifikasi KYC (Foto KTP, Selfie, NPWP)
10. **S-09** — Status Verifikasi Toko (Menunggu 2x24 Jam / Ditolak / Disetujui)
11. **S-10** — Primary Status & Signature (Verified Tier & Award Badge Xpedia Signature)

---

### 3️⃣ Klaster Beranda & Pencarian Terpadu (`HOM`)
*Fokus: Dashboard utama, pengumuman resmi marketplace, dan global search.*
12. **S-11** — Beranda / Dashboard Seller (Info Resmi, Perlu Tindakan, Ringkasan Toko, 5 Bottom Nav)
13. **S-12** — Global Search Terpadu (Pencarian Lintas Pesanan, Produk, Pembeli, dan Bantuan)

---

### 4️⃣ Klaster Manajemen Pesanan & Kasus Pengecualian (`ORD`)
*Fokus: Siklus transaksi, perlindungan privasi pembeli, dan penanganan dispute.*
14. **S-13** — Daftar Pesanan Toko (Semua, Processing, Kirim, Diterima, Selesai, Dibatalkan)
15. **S-14 / S05** — Detail Pesanan Lengkap (Timeline 5 Tahap, Masked Buyer, Breakdown Pendapatan Paten)
16. **S-15** — Tolak Pesanan Toko (Alasan Penolakan & Peringatan Reputasi Toko)
17. **S-16** — Custom Order Konfirmasi (Penetapan Lead Time & Spesifikasi Khusus 2x24 Jam)
18. **S-17** — Partial Fulfillment (Pemenuhan Sebagian Item & Persetujuan Pembeli)
19. **S-18** — Tanggapi Permintaan Pembatalan (Kasus Pembatalan Pasca Resi Terbit)
20. **S-19** — Komplain & Retur Pembeli (Foto Unboxing, Opsi Retur/Ganti/Tolak/Eskalasi)
21. **S-20** — Final Invoice Resmi (Dokumen Faktur Sah Pasca Transaksi Selesai)

---

### 5️⃣ Klaster Pengiriman, Logistik & Pergudangan (`SHP` & `STK`)
*Fokus: Pencetakan resi (commitment point), label pengiriman, kurir aktif, dan pergudangan.*
22. **S-21** — Atur Pengiriman & Cetak Resi (Pilihan Drop-off vs Pickup)
23. **S-22** — Pratinjau Label Pengiriman (Thermal Waybill dengan Penanda Privasi & Barcode)
24. **S-23** — Monitoring Pengiriman (Tracking Checkpoint Aktif & Kendala Rute Transit)
25. **S-24** — Pilih Kurir Aktif Toko (JNE, SiCepat, J&T, Instant/Sameday)
26. **S-25** — Coverage & Lokasi Gudang (Pengecualian Kota & Maksimal 3 Titik Gudang)

---

### 6️⃣ Klaster Katalog & Manajemen Produk (`PRD`)
*Fokus: Manajemen stok, varian harga grosir, dan transparansi kurasi.*
27. **S-26** — Daftar Produk & Etalase (Filter Status, Mode Stok Chip, Floating Add Button)
28. **S-27** — Tambah / Edit Produk (Multi-Section: Media, Mode Stok, Varian, Grosir, Compliance MSDS)
29. **S-28** — Status Moderasi Produk (Feedback Tim Kurasi: Penolakan Regulasi Baterai/HAKI)

---

### 7️⃣ Klaster Chat & Komunikasi Pelanggan (`CHT`)
*Fokus: Layanan pelanggan real-time, anti-bypass guard, dan referensi transaksi terintegrasi.*
30. **S-29** — Daftar Percakapan Chat (Status Belum Dibaca & Filter Pesanan)
31. **S-30** — Ruang Chat Interaktif (4 Status Pesan Centang, Product Card, Order Ref, Tanpa Lampiran File)

---

### 8️⃣ Klaster Promosi Mandiri & Xpedia Growth (`PRM` & `GRW`)
*Fokus: Pertumbuhan omzet berbasis komisi murni tanpa istilah iklan/ads.*
32. **S-31** — Campaign & Promo Seller (Diskon Toko, Ekstra Subsidi Ongkir, Simulasi Proteksi Margin HPP)
33. **S-32** — Xpedia Growth (Slider Ekstra Komisi 1%-15%, Syarat Skor Performa ≥60, Kunci 7x24 Jam)

---

### 9️⃣ Klaster Analisis Bisnis & Kinerja Kemitraan (`ANL` & `PRF`)
*Fokus: Metrik operasional 4 pilar dan corong konversi toko.*
34. **S-33** — Analytics & Corong Konversi (Kunjungan → Dilihat → Klik → Keranjang → Terjual)
35. **S-35** — Partners Performance (Rating Toko, Order Performance, Service SLA, Live Performance)

---

### 🔟 Klaster Storefront Toko, Live Streaming & Ulasan (`STF` & `REV`)
*Fokus: Tampilan toko publik, studio live selling, dan kredibilitas ulasan pelanggan.*
36. **S-34** — Kelola Storefront (Tata Letak Banner 1 Utama + 2 Panel Kecil, Susunan Etalase)
37. **S-36** — Live Selling Toko (Live Monitor Studio, Viewer Count, Pinned SKU, Flash Sale Kuota)
38. **S-37** — Ulasan Produk (Ulasan Berfoto, Filter Bintang, Balasan Penjual, Tanpa Opsi Hapus Ulasan)

---

### 1️⃣1️⃣ Klaster Finansial & Xpedia Wallet (`WLT`)
*Fokus: Transparansi saldo escrow dan pencairan dana aman.*
39. **S-38** — Xpedia Wallet (Saldo Tersedia, Saldo Ditahan, Buku Kas Ledger Transaksi)
40. **S-39** — Penarikan Dana Xpedia Wallet (Pilihan Rekening Terverifikasi, Bebas Biaya BI-FAST, Otorisasi PIN 6 Digit)

---

### 1️⃣2️⃣ Klaster Notifikasi & Dukungan Darurat 24 Jam (`NTF` & `SUP`)
*Fokus: Peringatan SLA mendesak dan tiket kendala operasional.*
41. **S-40** — Pusat Notifikasi Seller (Kategori Kritis: SLA Resi & Komplain; Operasional: Pesanan Masuk & Stok)
42. **S-41** — Xpedia 911 (Tepat 4 Kategori: Pesanan, Pengiriman, Wallet, Produk)
43. **S-42** — Detail Tiket Bantuan (Riwayat Chat Tiket dengan Tim Eskalasi 911)

---

### 1️⃣3️⃣ Klaster Pengaturan Profil & Keamanan Akun (`SET`)
*Fokus: Kredensial merchant, jam operasional, dan proteksi transaksi.*
44. **S-43** — Pengaturan Toko (Profil Toko, Jam Buka-Tutup Operasional, Preferensi Notifikasi)
45. **S-44** — Keamanan Akun (Kata Sandi, 2FA Autentikasi, Riwayat Sesi Perangkat, Pengaturan PIN Tarik Dana)

---

## 🔗 Rekomendasi 4 Alur Prototype Interaktif Utama

1. **Alur Pemrosesan Pesanan Harian (Golden Path):**
   `S-11 (Beranda)` ➔ `S-13 (Daftar Pesanan)` ➔ `S-14 / S05 (Detail Pesanan)` ➔ `S-21 (Atur Pengiriman)` ➔ `S-22 (Cetak Resi)` ➔ `S-23 (Monitoring Pengiriman)` ➔ `S-20 (Final Invoice)`

2. **Alur Pendaftaran Mitra Baru:**
   `S-01 (Daftar)` ➔ `S-02 (Pilih Tipe)` ➔ `S-03 / S-03b (Data Identitas)` ➔ `S-04 (Rekening)` ➔ `S-05 (Profil)` ➔ `S-08 (Unggah KYC)` ➔ `S-09 (Status)` ➔ `S-10 (Primary Status)`

3. **Alur Pengelolaan Katalog & Promosi:**
   `S-11 (Beranda)` ➔ `S-26 (Katalog Produk)` ➔ `S-27 (Tambah Produk)` ➔ `S-28 (Status Moderasi)` ➔ `S-31 (Campaign Promo)` / `S-32 (Xpedia Growth)`

4. **Alur Finansial & Pencairan Saldo:**
   `S-11 (Beranda)` ➔ `S-38 (Xpedia Wallet)` ➔ `S-39 (Tarik Dana & PIN 6 Digit)` ➔ `S-40 (Notifikasi Konfirmasi)`
