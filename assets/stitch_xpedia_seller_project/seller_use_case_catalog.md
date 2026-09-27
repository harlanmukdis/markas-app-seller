# KATALOG USE CASE & INVENTARIS LAYAR — XPEDIA PARTNERS (SELLER APP)

| Field | Value |
|---|---|
| Document ID | MPE-UC-SELLER-001 |
| Sumber | Xpedia Seller Blueprint v1.1 (24 Sep 2026, bab 1–12 DIKUNCI, 13–17 PENDING) + Seller Blueprint v2.0 (22 Sep) untuk modul yang tidak dibahas ulang di v1.1 |
| Tujuan | Menjawab satu pertanyaan: **di aplikasi seller, seller bisa melakukan apa saja** — lengkap, tanpa ada modul blueprint yang hilang |
| Turunannya | Inventaris layar → prompt Stitch |
| Target | Flutter mobile, 390×844 dp |

**Cara baca status:**
`🔒 DIKUNCI` aturannya sudah final di blueprint · `⏳ PENDING` sengaja dikosongkan sampai keputusan owner · `➕ TURUNAN` tidak disebut eksplisit tapi wajib ada agar alur jalan · `⚠️ TIDAK ADA MOCKUP` belum pernah digambar

---

# BAGIAN 1 — PETA MODUL

Blueprint desktop memakai 12 menu sidebar. Itu tidak muat di mobile. Usulan pemetaan:

| Bottom nav (5) | Isi |
|---|---|
| **Beranda** | Info & Update Xpedia, Perlu Tindakan, Ringkasan Toko, shortcut |
| **Pesanan** | Seluruh siklus order, pembatalan, komplain, retur, Custom Order |
| **Produk** | Katalog, stok, varian, harga, promo produk, coverage |
| **Chat** | Percakapan buyer |
| **Akun** | Hub untuk 8 modul sisanya |

Di dalam **Akun** (hub, bukan menu utama): Xpedia Wallet · Xpedia Growth · Campaign · Partners Performance · Analytics · Pengiriman · Storefront & Live · Xpedia 911 · Pengaturan.

⚠️ Ini keputusan desain saya, bukan aturan blueprint — v1.1 tidak mengunci navigasi mobile. Kalau owner ingin struktur lain, ini titik yang harus dikoreksi lebih dulu sebelum layar digambar.

| Kode | Modul | Bab blueprint | Status |
|---|---|---|---|
| ONB | Onboarding & Tipe Akun | v1.1 bab 1 | 🔒 |
| VER | Verifikasi, Primary Status, Signature | v1.1 bab 2 | 🔒 |
| HOM | Beranda / Dashboard | v2.0 §4 | 🔒 |
| ORD | Pesanan & Fulfillment | v1.1 bab 8, 9 | 🔒 |
| SHP | Pengiriman, Resi & Handover | v1.1 bab 8, 11 · v2.0 §8 | 🔒 |
| PRD | Produk & Katalog | v1.1 bab 3 | 🔒 |
| STK | Stok, Mode Fulfillment, Multi-Location | v1.1 bab 3, 4 | 🔒 |
| PRM | Harga, Promo, Coverage, Campaign | v1.1 bab 4 · v2.0 §10 | 🔒 |
| GRW | Xpedia Growth | v1.1 bab 7 | 🔒 |
| STF | Storefront & Live | v1.1 bab 5 | 🔒 |
| REV | Ulasan | v1.1 bab 5 | 🔒 |
| CHT | Chat & Anti-Bypass | v1.1 bab 12 | 🔒 |
| WLT | Xpedia Wallet | v1.1 bab 15 · v2.0 §13 | ⏳ sebagian |
| FIN | Pendapatan & Komisi | v1.1 bab 10 | 🔒 |
| PRF | Partners Performance | v1.1 bab 6 | 🔒 |
| ANL | Analytics | v2.0 §14 | 🔒 |
| SUP | Xpedia 911 | v2.0 §16 | 🔒 |
| SET | Pengaturan & Keamanan | v1.1 bab 16 · v2.0 §17 | ⏳ sebagian |
| NTF | Notifikasi | v2.0 §19 | 🔒 |
| SEC | Secure+ | v2.0 §7 | ⚠️ hilang di v1.1 |

---

# BAGIAN 2 — KATALOG USE CASE

## ONB — Onboarding & Tipe Akun

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-ONB-01 | Daftar akun seller dengan nomor HP + email | 🔒 | S-01 |
| UC-ONB-02 | Pilih tipe akun: Individual atau Company | 🔒 | S-02 |
| UC-ONB-03 | Isi data identitas (Individual: KTP, nama, HP, email) | 🔒 | S-03 |
| UC-ONB-04 | Isi data badan usaha + identitas PIC (Company) | 🔒 | S-03b |
| UC-ONB-05 | Daftarkan rekening bank atas nama identitas yang sama | 🔒 | S-04 |
| UC-ONB-06 | Unggah logo toko (wajib, direview) | 🔒 | S-05 |
| UC-ONB-07 | Tetapkan nama toko | 🔒 | S-05 |
| UC-ONB-08 | Lihat penolakan karena duplikasi identitas | 🔒 | S-06 |
| UC-ONB-09 | Ajukan penambahan kapasitas katalog di atas 500 SKU | 🔒 | S-07 |
| UC-ONB-10 | Login di beberapa perangkat/operator sekaligus | 🔒 | — |

**Aturan yang harus terlihat di UI:** 1 KTP + 1 nomor HP + 1 email = 1 akun seller. Toko publik terpisah berarti registrasi seller baru dengan identitas berbeda seluruhnya.

## VER — Verifikasi, Primary Status & Signature

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-VER-01 | Unggah dokumen verifikasi sesuai tipe akun | 🔒 | S-08 |
| UC-VER-02 | Pantau status verifikasi (menunggu/disetujui/ditolak) | 🔒 | S-09 |
| UC-VER-03 | Lihat alasan penolakan terstruktur dan kirim ulang | 🔒 | S-09 |
| UC-VER-04 | Lihat Primary Status toko (Verified Individual / Verified Company / Official Store / Managed by Xpedia) | 🔒 | S-10 |
| UC-VER-05 | Lihat badge Xpedia Signature bila diberikan | 🔒 | S-10 |
| UC-VER-06 | Memahami bahwa Signature tidak bisa dibeli | 🔒 | S-10 |

**Gerbang keras:** tanpa status approved, seller tidak bisa listing maupun menjual. Semua menu Produk dan Pesanan harus terkunci dengan alasan yang jelas, bukan sekadar kosong.

## HOM — Beranda

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-HOM-01 | Baca Info & Update resmi Xpedia | 🔒 | S-11 |
| UC-HOM-02 | Lihat daftar Perlu Tindakan dengan badge actionable | 🔒 | S-11 |
| UC-HOM-03 | Lihat Ringkasan Toko harian | 🔒 | S-11 |
| UC-HOM-04 | Lompat ke modul lewat shortcut | 🔒 | S-11 |
| UC-HOM-05 | Cari order, produk, atau topik bantuan lewat global search | 🔒 | S-12 |

**Larangan:** jangan memakai label "Insight" sebagai nama kartu. Banner utama dicadangkan untuk informasi resmi Xpedia, bukan promosi seller.

## ORD — Pesanan & Fulfillment

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-ORD-01 | Lihat daftar pesanan per status | 🔒 | S-13 |
| UC-ORD-02 | Filter pesanan per tanggal, kurir, mode stok | ➕ | S-13 |
| UC-ORD-03 | Buka detail pesanan | 🔒 | S-14 |
| UC-ORD-04 | Lihat data pembeli yang dimasking | 🔒 | S-14 |
| UC-ORD-05 | Baca catatan pembeli | 🔒 | S-14 |
| UC-ORD-06 | Lihat timeline 5 tahap pesanan | 🔒 | S-14 |
| UC-ORD-07 | Lihat countdown SLA cetak resi | 🔒 | S-14 |
| UC-ORD-08 | Lihat countdown SLA handover | 🔒 | S-14 |
| UC-ORD-09 | Tolak pesanan dengan alasan | 🔒 | S-15 |
| UC-ORD-10 | Konfirmasi Custom Order dalam 2×24 jam kerja | 🔒 | S-16 |
| UC-ORD-11 | Tetapkan lead time dan spesifikasi Custom Order | 🔒 | S-16 |
| UC-ORD-12 | Ajukan partial fulfillment saat sebagian item tidak tersedia | 🔒 | S-17 |
| UC-ORD-13 | Lihat keputusan buyer atas proposal partial fulfillment | 🔒 | S-17 |
| UC-ORD-14 | Tangani pesanan campuran Ready + Pre-Order | 🔒 | S-14 |
| UC-ORD-15 | Tangani pesanan campuran Ready + Custom | 🔒 | S-16 |
| UC-ORD-16 | Tanggapi permohonan pembatalan buyer setelah resi | 🔒 | S-18 |
| UC-ORD-17 | Lihat pembatalan langsung buyer sebelum resi | 🔒 | S-18 |
| UC-ORD-18 | Tanggapi komplain buyer setelah Diterima | 🔒 | S-19 |
| UC-ORD-19 | Setujui retur / replacement / tolak dengan bukti | 🔒 | S-19 |
| UC-ORD-20 | Eskalasi kasus ke tim Xpedia | 🔒 | S-19 |
| UC-ORD-21 | Cetak/unduh Final Invoice setelah Completed | 🔒 | S-20 |
| UC-ORD-22 | Chat pembeli dari konteks pesanan | 🔒 | S-30 |

## SHP — Pengiriman, Resi & Handover

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-SHP-01 | Pilih metode: drop-off ke kurir atau pickup di lokasi | 🔒 | S-21 |
| UC-SHP-02 | Generate / cetak resi (commitment trigger) | 🔒 | S-21 |
| UC-SHP-03 | Masukkan atau pindai nomor resi | 🔒 | S-21 |
| UC-SHP-04 | Cetak label pengiriman dengan masking privasi | 🔒 | S-22 |
| UC-SHP-05 | Pantau daftar pengiriman aktif | 🔒 | S-23 |
| UC-SHP-06 | Lihat riwayat scan/tracking per paket | 🔒 | S-23 |
| UC-SHP-07 | Tandai masalah pengiriman dan buka tiket | 🔒 | S-23 |
| UC-SHP-08 | Pilih kurir yang diaktifkan untuk toko | 🔒 | S-24 |
| UC-SHP-09 | Atur coverage pengiriman dan kecualikan kota | 🔒 | S-25 |
| UC-SHP-10 | Atur subsidi/support ongkir seller | 🔒 | S-25 |

## PRD — Produk & Katalog

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-PRD-01 | Lihat katalog produk dengan filter status | 🔒 | S-26 |
| UC-PRD-02 | Tambah produk baru | 🔒 | S-27 ⚠️ |
| UC-PRD-03 | Unggah foto produk (watermark otomatis) | 🔒 | S-27 |
| UC-PRD-04 | Tetapkan kategori dan atribut wajib | 🔒 | S-27 |
| UC-PRD-05 | Buat varian dengan harga dan stok masing-masing | 🔒 | S-27 |
| UC-PRD-06 | Tetapkan minimum order | 🔒 | S-27 |
| UC-PRD-07 | Tetapkan harga grosir bertingkat | 🔒 | S-27 |
| UC-PRD-08 | Isi berat dan dimensi | 🔒 | S-27 |
| UC-PRD-09 | Edit produk | 🔒 | S-27 |
| UC-PRD-10 | Ubah status: Active / Out of Stock / Discontinued / Delete | 🔒 | S-26 |
| UC-PRD-11 | Lihat status moderasi dan alasan penolakan | 🔒 | S-28 |
| UC-PRD-12 | Tandai produk kimia/berbahaya + unggah dokumen | 🔒 | S-27 |
| UC-PRD-13 | Duplikasi produk | ➕ | S-26 |
| UC-PRD-14 | Edit massal harga atau stok | ➕ | S-29 ⚠️ |

## STK — Stok & Mode Fulfillment

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-STK-01 | Pilih mode: Infinite / Ready Stock / Low Stock / Pre-Order / Custom Order | 🔒 | S-27 |
| UC-STK-02 | Tetapkan lead time Pre-Order | 🔒 | S-27 |
| UC-STK-03 | Perbarui jumlah stok per varian | 🔒 | S-26 |
| UC-STK-04 | Terima notifikasi stok menipis | 🔒 | S-40 |
| UC-STK-05 | Kelola maksimal 3 lokasi gudang/cabang | 🔒 | S-25 |
| UC-STK-06 | Lihat dampak akurasi stok ke performa | 🔒 | S-35 |

## PRM — Harga, Promo & Campaign

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-PRM-01 | Tetapkan harga produk sendiri | 🔒 | S-27 |
| UC-PRM-02 | Buat diskon/promo yang ditanggung seller, berbasis waktu atau item | 🔒 | S-31 |
| UC-PRM-03 | Buat campaign untuk semua atau sebagian produk | 🔒 | S-31 |
| UC-PRM-04 | Jadwalkan periode campaign | 🔒 | S-31 |
| UC-PRM-05 | Atur bundling | 🔒 | S-31 |
| UC-PRM-06 | Atur support ongkir per campaign | 🔒 | S-31 |
| UC-PRM-07 | Lihat proyeksi harga akhir sebelum aktivasi (proteksi margin) | 🔒 | S-31 |
| UC-PRM-08 | Lihat daftar campaign aktif, terjadwal, berakhir | 🔒 | S-31 |

## GRW — Xpedia Growth

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-GRW-01 | Lihat skor Natural Performance dan eligibility | 🔒 | S-32 |
| UC-GRW-02 | Pilih extra commission 1%–15% per produk | 🔒 | S-32 |
| UC-GRW-03 | Lihat poin Growth yang dihasilkan (0–50) | 🔒 | S-32 |
| UC-GRW-04 | Pilih mode Aktif 7 Hari atau Aktif Terus | 🔒 | S-32 |
| UC-GRW-05 | Lihat sisa waktu lock 7×24 jam | 🔒 | S-32 |
| UC-GRW-06 | Bandingkan performa sebelum vs sesudah Growth | 🔒 | S-33 |
| UC-GRW-07 | Matikan Growth (set 0%) | 🔒 | S-32 |

**Larangan bahasa:** tidak boleh ada kata iklan, ads, CPC, atau budget di modul ini.

## STF — Storefront & Live

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-STF-01 | Atur banner header toko (1 panel utama + 2 kecil) | 🔒 | S-34 |
| UC-STF-02 | Kelola etalase dan urutannya | 🔒 | S-34 |
| UC-STF-03 | Atur konten tab Beranda toko | 🔒 | S-34 |
| UC-STF-04 | Pratinjau storefront seperti dilihat buyer | 🔒 | S-34 |
| UC-STF-05 | Mulai sesi Live | 🔒 | S-36 |
| UC-STF-06 | Pin produk saat Live | 🔒 | S-36 |
| UC-STF-07 | Lihat statistik Live (jam, penonton, checkout) | 🔒 | S-36 |
| UC-STF-08 | Jadwalkan sesi Live berikutnya | 🔒 | S-36 |

## REV — Ulasan

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-REV-01 | Lihat ulasan produk dengan referensi produk yang dibeli | 🔒 | S-37 |
| UC-REV-02 | Balas ulasan | 🔒 | S-37 |
| UC-REV-03 | Filter ulasan per bintang / berfoto | 🔒 | S-37 |
| UC-REV-04 | Laporkan ulasan yang melanggar | ➕ | S-37 |

**Aturan keras:** seller tidak bisa menghapus ulasan buyer. Tidak ada form rating toko terpisah.

## CHT — Chat & Anti-Bypass

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-CHT-01 | Lihat daftar percakapan urut aktivitas terbaru | 🔒 | S-29 |
| UC-CHT-02 | Kirim teks dan foto | 🔒 | S-30 |
| UC-CHT-03 | Kirim Product Card | 🔒 | S-30 |
| UC-CHT-04 | Kirim referensi pesanan | 🔒 | S-30 |
| UC-CHT-05 | Kirim shortcut Return/Refund | 🔒 | S-30 |
| UC-CHT-06 | Kirim voucher sistem | 🔒 | S-30 |
| UC-CHT-07 | Lihat 4 status pesan dan indikator mengetik | 🔒 | S-30 |
| UC-CHT-08 | Menerima blokir otomatis saat mencoba kirim kontak/URL/QR | 🔒 | S-30 |

**Aturan keras:** pesan terkirim tidak bisa diedit atau dihapus. Dokumen sembarang tidak diperbolehkan.

## WLT + FIN — Wallet, Pendapatan & Komisi

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-FIN-01 | Lihat Rincian Pendapatan Seller per pesanan | 🔒 | S-14 |
| UC-FIN-02 | Memahami komisi dasar 5% | 🔒 | S-14 |
| UC-FIN-03 | Melihat potongan Growth bila aktif | 🔒 | S-14 |
| UC-WLT-01 | Lihat Saldo Tersedia dan Saldo Ditahan | 🔒 | S-38 |
| UC-WLT-02 | Lihat ledger transaksi dengan referensi yang bisa dibuka | 🔒 | S-38 |
| UC-WLT-03 | Kelola maksimal 3 rekening terverifikasi | ⏳ | S-39 |
| UC-WLT-04 | Ajukan penarikan dana dengan PIN 6 digit | ⏳ | S-39 |
| UC-WLT-05 | Belanja memakai saldo di dalam Xpedia | 🔒 | — |

⏳ Limit penarikan, biaya transfer, dan cadence settlement **belum dikunci** (v1.1 bab 15). Layar boleh dirancang, tapi angka dan aturannya jangan di-hardcode.

## PRF + ANL — Performa & Analytics

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-PRF-01 | Lihat Rating Toko & Customer Satisfaction | 🔒 | S-35 |
| UC-PRF-02 | Lihat Order Performance (successful, cancellation, failure) | 🔒 | S-35 |
| UC-PRF-03 | Lihat Service Performance (response rate, balas chat, jam operasional) | 🔒 | S-35 |
| UC-PRF-04 | Lihat Live Performance | 🔒 | S-35 |
| UC-PRF-05 | Lihat rincian skor Natural Performance 4 komponen | 🔒 | S-35 |
| UC-PRF-06 | Bandingkan dengan bulan kalender sebelumnya | 🔒 | S-35 |
| UC-ANL-01 | Lihat penjualan bulan berjalan | 🔒 | S-33 |
| UC-ANL-02 | Lihat funnel: kunjungan → dilihat → klik → wishlist → terjual | 🔒 | S-33 |
| UC-ANL-03 | Lihat sumber trafik | 🔒 | S-33 |
| UC-ANL-04 | Lihat pembeli baru vs pembeli setia | 🔒 | S-33 |
| UC-ANL-05 | Lihat produk terbaik | 🔒 | S-33 |

## SUP — Xpedia 911

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-SUP-01 | Pilih kategori: Pesanan / Pengiriman / Wallet / Produk | 🔒 | S-41 |
| UC-SUP-02 | Pilih record terkait tanpa mengetik manual | 🔒 | S-41 |
| UC-SUP-03 | Buat tiket dengan lampiran foto | 🔒 | S-42 |
| UC-SUP-04 | Pantau status dan riwayat percakapan tiket | 🔒 | S-42 |
| UC-SUP-05 | Lanjut ke agen manusia | 🔒 | S-42 |

## SET + NTF — Pengaturan, Keamanan & Notifikasi

| ID | Use case | Status | Layar |
|---|---|---|---|
| UC-SET-01 | Edit profil toko dan deskripsi | 🔒 | S-43 |
| UC-SET-02 | Ganti password, nomor HP, email dengan verifikasi | 🔒 | S-44 |
| UC-SET-03 | Atur 2FA | ⏳ | S-44 |
| UC-SET-04 | Lihat riwayat perangkat dan logout perangkat lain | ⏳ | S-44 |
| UC-SET-05 | Atur atau ganti PIN penarikan 6 digit | 🔒 | S-44 |
| UC-SET-06 | Atur jam operasional toko | 🔒 | S-43 |
| UC-SET-07 | Ganti bahasa ID/EN | 🔒 | S-43 |
| UC-NTF-01 | Lihat pusat notifikasi | 🔒 | S-40 |
| UC-NTF-02 | Atur preferensi notifikasi per kategori | 🔒 | S-43 |

## SEC — Secure+ ⚠️

| ID | Use case | Status |
|---|---|---|
| UC-SEC-01 | Lihat pesanan ber-Secure+ dan kewajibannya | ⚠️ hilang di v1.1 |
| UC-SEC-02 | Unggah bukti foto + video packing sebelum handover | ⚠️ |
| UC-SEC-03 | Scan/asosiasikan seal QR Secure+ ke order | ⚠️ |
| UC-SEC-04 | Lihat status klaim Secure+ | ⚠️ |

**Ini blok terbesar yang belum jelas.** v2.0 mewajibkan bukti foto+video, seal QR, dan hard gate "no scan no delivery". v1.1 hanya menyebut Secure+ sebagai penanda di resi. Kalau aturan v2.0 masih berlaku, ini menambah minimal 4 layar dan mengubah alur handover. **Harus dikonfirmasi sebelum layar handover digambar.**

---

# BAGIAN 3 — INVENTARIS LAYAR

44 layar. Kolom P = prioritas build.

| ID | Layar | Modul | P | Catatan |
|---|---|---|---|---|
| S-01 | Daftar / Masuk | ONB | 2 | |
| S-02 | Pilih tipe akun | ONB | 2 | Ada mockup |
| S-03 | Data identitas Individual | ONB | 2 | ⚠️ |
| S-03b | Data badan usaha + PIC | ONB | 3 | ⚠️ |
| S-04 | Rekening bank | ONB | 2 | ⚠️ |
| S-05 | Profil toko & logo | ONB | 2 | ⚠️ |
| S-06 | Penolakan duplikasi identitas | ONB | 3 | ⚠️ |
| S-07 | Ajukan kapasitas katalog | ONB | 4 | ⚠️ |
| S-08 | Unggah dokumen verifikasi | VER | 2 | ⚠️ |
| S-09 | Status verifikasi | VER | 2 | ⚠️ |
| S-10 | Primary Status & Signature | VER | 3 | Ada aset badge |
| S-11 | **Beranda** | HOM | **1** | Ada mockup |
| S-12 | Global search | HOM | 3 | |
| S-13 | **Daftar pesanan** | ORD | **1** | Ada mockup |
| S-14 | **Detail pesanan** | ORD | **1** | Ada mockup, layar terpadat |
| S-15 | Tolak pesanan | ORD | 2 | |
| S-16 | Custom Order — konfirmasi | ORD | 2 | ⚠️ |
| S-17 | Partial fulfillment | ORD | 2 | ⚠️ |
| S-18 | Permintaan pembatalan | ORD | 2 | Ada mockup |
| S-19 | Komplain & retur | ORD | 2 | Ada mockup |
| S-20 | Final Invoice | ORD | 3 | Ada mockup |
| S-21 | Atur pengiriman & cetak resi | SHP | **1** | Bagian dari S-14 |
| S-22 | Pratinjau label / resi | SHP | 2 | Ada mockup |
| S-23 | Monitoring pengiriman | SHP | 2 | Ada mockup |
| S-24 | Pilih kurir aktif | SHP | 3 | |
| S-25 | Coverage & lokasi gudang | SHP | 3 | |
| S-26 | **Daftar produk** | PRD | **1** | Ada mockup |
| S-27 | Tambah / edit produk | PRD | **1** | ⚠️ tidak ada mockup, form terpanjang |
| S-28 | Status moderasi produk | PRD | 3 | ⚠️ |
| S-29 | **Daftar chat** | CHT | 2 | Ada mockup |
| S-30 | **Ruang chat** | CHT | **1** | Ada mockup |
| S-31 | Campaign & promo | PRM | 2 | Ada mockup |
| S-32 | **Xpedia Growth** | GRW | 2 | Ada mockup |
| S-33 | Analytics | ANL | 3 | Ada mockup |
| S-34 | Kelola storefront | STF | 3 | Ada mockup |
| S-35 | **Partners Performance** | PRF | 2 | Ada mockup |
| S-36 | Live selling | STF | 4 | Ada mockup |
| S-37 | Ulasan | REV | 3 | Ada mockup |
| S-38 | **Xpedia Wallet** | WLT | 2 | Ada mockup |
| S-39 | Penarikan dana | WLT | 3 | ⏳ aturan belum final |
| S-40 | Pusat notifikasi | NTF | 3 | |
| S-41 | Xpedia 911 — kategori | SUP | 3 | Ada mockup |
| S-42 | Detail tiket | SUP | 3 | |
| S-43 | Pengaturan toko | SET | 3 | Ada mockup |
| S-44 | Keamanan akun | SET | 3 | ⏳ biometrik belum final |

**Prioritas 1 (8 layar)** adalah tulang punggung: Beranda, Daftar Pesanan, Detail Pesanan, Atur Pengiriman, Daftar Produk, Tambah Produk, Ruang Chat. Kalau delapan ini benar, 36 sisanya mewarisi polanya.

---

# BAGIAN 4 — YANG HARUS DIPUTUSKAN SEBELUM DIGAMBAR

| # | Pertanyaan | Dampak |
|---|---|---|
| 1 | Struktur navigasi mobile — apakah usulan 5 bottom nav + hub Akun diterima? | Menentukan seluruh 44 layar |
| 2 | Secure+ — aturan v2.0 masih berlaku? | Menambah 4 layar + mengubah alur handover |
| 3 | Kapan Diterima → Selesai? | Tanpa ini layar Pesanan tidak punya tahap akhir |
| 4 | "Managed by Xpedia" itu apa | Bisa menambah modul fulfillment platform |
| 5 | Wallet: layar penarikan digambar sekarang atau ditunda? | v1.1 bab 15 PENDING |

---

# BAGIAN 5 — ALUR KE STITCH

1. `DESIGN.md` masuk sekali sebagai project rules.
2. Generate **8 layar prioritas 1** dulu, urut: S-14 → S-11 → S-13 → S-26 → S-30 → S-27 → S-21 → S-13.
3. Setiap layar dicek terhadap use case ID-nya di dokumen ini. Kalau ada use case yang tidak punya tempat di layar itu, layarnya belum selesai — bukan karena jelek, tapi karena bolong.
4. Baru lanjut prioritas 2, 3, 4.

Checklist verifikasi per layar: buka bagian use case modulnya, pastikan **setiap baris** punya tempat di UI atau punya alasan tertulis kenapa tidak ada di layar itu.
