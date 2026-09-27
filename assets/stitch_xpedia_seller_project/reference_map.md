# REFERENCE MAP — Mockup PDF → Prompt Stitch

52 gambar mockup berhasil diekstrak dari tiga PDF blueprint sebagai PNG resolusi asli
(1448×1086 sampai 1672×941), bukan hasil screenshot halaman. Lihat
`reference/00-CONTACT-SHEET.png` untuk melihat semuanya sekaligus.

**Kenapa ini penting:** `DESIGN.md` mengunci token dan aturan produk, tapi **tidak** mengunci
hirarki visual. Mockup yang sudah disetujui ada di PDF, dan tanpa gambar itu Stitch akan
mengarang tata letaknya sendiri. Stitch menerima gambar sebagai referensi — jadi setiap
prompt sebaiknya disertai satu gambar.

---

## ⚠️ Masalah utama: mockup yang disetujui itu DESKTOP

Hampir semua mockup di blueprint adalah web/desktop seller portal, sementara target kamu
Flutter mobile. Ini bukan sekadar mengecilkan layar — sidebar 12 menu tidak muat di mobile,
tabel rincian pendapatan harus jadi list, dan dashboard 3 kolom harus jadi tumpukan vertikal.

Artinya gambar-gambar ini adalah referensi **hirarki informasi dan gaya visual**, bukan
referensi layout. Prompt Stitch harus menyebut itu secara eksplisit, kalau tidak Stitch akan
mencoba menirukan layout desktop ke dalam frame 390dp dan hasilnya sempit dan padat.

Kalimat yang saya sarankan ditempel di setiap prompt yang memakai referensi desktop:

> Use the attached image as a reference for information hierarchy, terminology, and visual
> tone only. Do NOT copy the desktop layout. Redesign it as a native mobile screen at
> 390x844 with a single-column stack, per the rules in DESIGN.md.

**Pengecualian:** satu gambar di blueprint buyer (`buy-010`) sudah berupa mockup mobile —
tiga layar ponsel berdampingan. Itu satu-satunya referensi mobile asli yang kita punya, dan
paling berguna untuk menetapkan bahasa visual mobile sebelum layar lain digenerate.

---

## Pemetaan gambar → prompt

Nama file mengikuti hasil ekstraksi. Sumber: `v2` = Seller Blueprint v2.0 (English),
`v11` = Seller Blueprint v1.1 (Bahasa), `buy` = Buyer Blueprint v1.1.

| Prompt | Gambar referensi | Isi mockup | Jenis |
|---|---|---|---|
| S01 Onboarding | `v11-006` | Join Xpedia Partners — pilih Individual/Company | Desktop |
| S02 Verifikasi KYC | — | Tidak ada mockup; ikuti pola S01 | — |
| S03 Home / Dashboard | `v2-020`, `v11-008` | Home seller dengan Info & Update, Ringkasan Toko | Desktop |
| S04 Daftar Pesanan | `v2-000`, `v11-007` | Orders dashboard, tab status, Urgent Actions | Desktop |
| S05 Detail Pesanan | `v11-000`, `v11-001` | Detail Pesanan lengkap + Rincian Pendapatan Seller | Desktop |
| S05b Pembatalan | `v2-001`, `v11-010` | Cancellation Request + detail panel | Desktop |
| S05c Komplain & Retur | `v2-002`(?) | Complaint & Return, bukti foto, aksi seller | Desktop |
| S06 Daftar Produk | `v2-007` | Products — katalog, status, mode stok | Desktop |
| S07 Tambah Produk | — | Tidak ada mockup | — |
| S08 Partners Performance | `v2-013`, `v11-004` | Performance 4 blok + Partners Performance storefront | Desktop |
| S09 Xpedia Growth | `v2-009` | Growth — slider komisi, mode lock, tabel perbandingan | Desktop |
| S10 Chat | `v2-010`, `v11-009` | Chat Center, product card, order reference | Desktop |
| S11 Xpedia Wallet | `v2-011` | Wallet — saldo, rekening, riwayat | Desktop |
| S12 Xpedia 911 | `v2-014` | 911 — 4 kategori + daftar tiket | Desktop |
| Settings | `v2-015` | Settings — profil, keamanan, rekening, PIN | Desktop |
| Shipping | `v2-005`, `v2-006` | Shipping + Shipping Management | Desktop |
| Secure+ | `v2-003`, `v2-004` | Secure+ cases, packing evidence, stiker seal | Desktop |
| Invoice | `v11-002`, `buy-011` | Final Invoice yang disetujui | Dokumen |
| Resi / Label | `v11-003`, `buy-012` | Shipping label dengan penanda Secure+ | Dokumen |
| Storefront | `v11-005`, `buy-016` | Header toko 1+2 panel, tab, metrik publik | Desktop |
| Live | `buy-017` | Live selling dengan produk ter-pin | Desktop |
| Ulasan | `buy-018` | Ulasan produk dengan foto | Desktop |
| Signature badge | `buy-015` | Badge hitam-gold + contoh pemakaian | Aset |
| **Mobile buyer** | **`buy-010`** | **Tiga layar ponsel — satu-satunya referensi mobile** | **Mobile** |

Beberapa nomor bisa bergeser satu posisi karena urutan ekstraksi mengikuti urutan objek di
PDF, bukan urutan halaman. Buka contact sheet untuk memastikan sebelum mengunggah.

---

## Alur yang saya sarankan di Stitch

1. Unggah `DESIGN.md` sebagai design-system rules project.
2. Generate **`buy-010`** dulu sebagai kalibrasi bahasa visual mobile — walau itu layar buyer.
   Tujuannya menetapkan gaya kartu, tinggi baris, dan bobot teks di frame mobile.
3. Baru masuk S05 Detail Pesanan dengan `v11-000` + kalimat penolakan layout desktop di atas.
4. Setelah S05 disetujui, layar lain memakai S05 sebagai acuan konsistensi, bukan mockup desktop-nya.

## Yang tidak punya mockup sama sekali

Verifikasi KYC, Tambah/Edit Produk, dan seluruh alur Custom Order belum pernah digambar.
Untuk ketiganya, Stitch bekerja murni dari prompt — jadi hasilnya akan lebih bervariasi dan
butuh lebih banyak iterasi. Kalau ada budget waktu desain, tiga layar inilah yang paling
layak digambar manual lebih dulu.
