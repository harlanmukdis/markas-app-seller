# Brief FE — Markas App Seller (Toko)

**Dokumen tunggal & berdiri sendiri.** Menggantikan `API-SELLER-APP.md`, `SELLER-APP-FEATURE-MAP.md`, `PROMPT-PENYESUAIAN-v2.2.md`, dan `PROMPT-PENYESUAIAN-v2.4.md` untuk keperluan pengerjaan FE. Tidak perlu membaca dokumen lain.

**Kondisi backend:** 11 September 2026 · branch `wip-harlan` · 97 tabel, 341 stored procedure
**Diverifikasi:** seluruh endpoint di bawah diuji dengan request sungguhan ke server yang berjalan.

---

# BAGIAN 1 — Aplikasi ini sebenarnya apa

Ini **aplikasi kerja**, bukan aplikasi belanja. Penggunanya pemilik toko material yang sedang berdiri di gudang, atau sopir yang sedang di lokasi pengiriman. Tiga hal yang membentuk desainnya:

**a. Aplikasi ini menentukan berapa uang yang diterima toko.** Terlambat mengonfirmasi pesanan = order batal otomatis + skor turun 3. Terlambat menjawab retur 2×24 jam = **retur otomatis dianggap diterima**. Hitung mundur dan notifikasi di aplikasi ini bukan pemanis UX — itu uang nyata.

**b. Di rilis pertama, aplikasi seller merangkap aplikasi driver.** Aplikasi Driver baru ada di Fase 2, jadi POD (foto barang di lokasi + nama & tanda tangan penerima) diunggah lewat aplikasi ini. Harus enak dipakai **di lokasi, satu tangan, sinyal seadanya**.

**c. Toko tidak bisa berjualan sebelum lolos empat gerbang.** Sebelum keempatnya lengkap, produk tidak bisa tayang sama sekali.

**Dua tipe akun, satu aplikasi:** `TOKO` dan `DISTRIBUTOR`. Perbedaannya **murni label tampilan** — onboarding, katalog, order, pengiriman, dan pencairannya identik. **Jangan buat cabang kode terpisah.**

---

# BAGIAN 2 — Aturan teknis wajib

**Base URL:** `http://localhost/markas/api/v1` (port 80, **bukan** 8080)

### Format
- Body request **wajib JSON** + `Content-Type: application/json`. **`form-data` tidak terbaca backend sama sekali.**
- Semua respons `{success, data, error}` (+ `meta` di sebagian endpoint). Buat satu interceptor.
- Angka sering datang sebagai **string** (`"score": "100.00"`).

### Autentikasi & scoping
```
Authorization: Bearer <access_token>
```
| Token | Masa berlaku | Dari |
|---|---|---|
| `access_token` | **2 jam** | `register`, `login`, `refresh` |
| `refresh_token` | 30 hari | **hanya `login`** |

Respons login membawa `user_id`, `role` (`"SEL"`), `actor_type` (`"MERCHANT"`), dan **`seller_id`**.

🔴 **`seller_id` TIDAK PERNAH dikirim di body.** Backend selalu mengambilnya dari claim JWT. Endpoint berpola `/sellers/{id}/...` tetap memeriksa `{id}` cocok dengan token — kalau beda → `403`. Isi `{id}` dengan `seller_id` dari respons login.

Endpoint seperti `GET /offers`, `/sku-requests`, `/finance/ledger`, `/reports/*` **otomatis** ter-scope ke toko Anda saat dipanggil dengan token `SEL`.

### Nama field waktu
- Mayoritas: **`created_date`** / **`modified_date`**
- ⚠️ **Kecuali** `/chat/messages` dan `/payments/*` yang tetap **`created_at`**
- **Jangan find-replace buta.**

Field batas waktu **tidak berganti nama**: `seller_confirm_deadline`, `fleet_handover_warn_at`, `fleet_handover_cancel_at`, `hold_release_at`, `deadline_1x24`, `deadline_3x24`.

### Status
Pakai field `status` (string). Ada `status_id` numerik — abaikan.

### Uang & waktu
- **Aplikasi tidak menghitung uang sendiri.**
- **Jangan hitung deadline sendiri** — banyak batas waktu memakai "jam kerja" yang melewatkan akhir pekan & libur nasional. Pakai field deadline dari server.

### Kode error
| HTTP | `error.code` | Arti |
|---|---|---|
| 400 | `MALFORMED_JSON` | Body bukan JSON |
| 401 | `UNAUTHENTICATED` | Token tidak ada/kedaluwarsa |
| 403 | `FORBIDDEN` / `PERMISSION_DENIED` | Tidak berhak |
| 403 | `NO_SELLER_CONTEXT` | Akun tidak terhubung ke toko |
| 404 | `NOT_FOUND` | Tidak ada **atau bukan milik toko Anda** |
| 405 | `METHOD_NOT_ALLOWED` | Verb HTTP salah |
| 409 | `INVALID_TRANSITION` / `INVALID_STATE` | Transisi status tidak sah |
| 422 | `VALIDATION_ERROR` | Field wajib kosong |
| 422 | `GATES_NOT_PASSED` | Syarat aktivasi belum terpenuhi; `error.details` menyebut gate mana |

### Keanehan routing
`GET /returns/{id}/detail` dan `GET /disputes/{id}/detail` — **wajib pakai `/detail`**. Tanpa itu `404 Endpoint not found`.

---

# BAGIAN 3 — 🔴 BLOCKER AKTIF: baca sebelum menulis kode pengiriman

**Perhitungan berat total pada validasi kapasitas armada mengalikan qty DUA KALI.**

Diverifikasi live: pesanan **40 sak × 50 kg = 2.000 kg** terhitung **80.000 kg** dan ditolak bahkan oleh TRONTON (kapasitas 15.000 kg):

```
POST /shipments {fleet_type_code:"CDD", ...}
→ 422 FLEET_PAYLOAD_EXCEEDED
  "Total berat barang (80000 kg) melebihi kapasitas muatan CDD (5000.00 kg)"
```

Untuk kategori bahan bangunan yang qty-nya normal puluhan–ratusan, ini **mematikan pembuatan pengiriman untuk hampir semua pesanan nyata**.

**Mitigasi sementara:** **jangan kirim field `fleet_type_code`** pada `POST /shipments`. Tanpa field itu pengiriman berhasil dibuat (sudah diuji). Konsekuensinya validasi kapasitas & akses lokasi tidak dievaluasi — catat sebagai utang teknis, kirim ulang `fleet_type_code` begitu backend memperbaikinya.

**Penyebab (untuk tim backend):** `C_Checkout.php:106` menyimpan `weight_kg` per baris = berat_satuan × qty; `C_Shipments.php:77` mengalikannya lagi dengan qty. Perbaikan: `$total += $soi->weight_kg_snapshot * ($it['qty'] / $soi->qty);` atau simpan berat **satuan** di snapshot.

**Laporkan sebagai prioritas tertinggi.** Selama belum diperbaiki, fitur pemilihan armada tidak bisa dipakai.

---

# BAGIAN 4 — Onboarding: empat gerbang

Sumber kebenaran: `GET /sellers/{id}` → objek **`activation_gates`**

```json
{ "kyc_approved": false, "bank_verified": false,
  "has_shipping_rate": false, "agreement_signed": false, "all_passed": false }
```

| # | Gerbang | Siapa yang menyelesaikan | Saat menunggu |
|---|---|---|---|
| 1 | KYC disetujui | Toko unggah → **admin** menyetujui | "Menunggu verifikasi admin" |
| 2 | Rekening tervalidasi | Toko tambah → **admin finance** memverifikasi | "Menunggu verifikasi admin" |
| 3 | Tarif ongkir ≥1 zona | **Toko sendiri** | Tombol aksi langsung |
| 4 | Perjanjian ditandatangani | **Toko sendiri** | Tombol aksi langsung |

| Layar | Endpoint |
|---|---|
| Registrasi toko | `POST /auth/register` `{phone, password, full_name, role:"SEL", toko_name, seller_type}` |
| Checklist onboarding | `GET /sellers/{id}` |
| Unggah KYC | `POST /sellers/{id}/kyc_upload` `{doc_type, file_url}` |
| Tambah rekening | `POST /sellers/{id}/bank_account_add` `{bank_name, account_no, account_holder}` |
| Lihat rekening | `GET /sellers/{id}/bank_accounts` |
| Tanda tangan | `POST /sellers/{id}/sign_agreement` `{confirm:true}` |
| Gudang | `GET/POST /sellers/{id}/warehouses` `{name, address_id?}` |
| Tarif ongkir | `POST /shipping-rates` |
| Ubah profil | `PUT /sellers/{id}` — **hanya `name` dan `legal_name`** |

Dokumen KYC wajib: **KTP, NPWP, BUKU_REKENING, dan (NIB atau SIUP)**. `doc_type` sah: `KTP`, `NPWP`, `NIB`, `SIUP`, `BUKU_REKENING`, `SKB`, `SURAT_PERNYATAAN_BERMETERAI`, `PERJANJIAN_KERJASAMA`.

⚠️ **Urutan tersembunyi:** gerbang 2 hanya terbuka kalau **KYC sudah disetujui lebih dulu**. Tampilkan gerbang berurutan.

⚠️ **Gudang wajib tapi TIDAK masuk `activation_gates`.** Tanpa gudang, checkout pembeli gagal `NO_WAREHOUSE` walau status toko sudah `VERIFIED`. **Cek sendiri** lewat `GET /sellers/{id}/warehouses`.

**Layar perjanjian harus menampilkan isi perjanjiannya**, bukan sekadar checkbox — semua aturan penalti baru punya dasar hukum setelah ini ditandatangani.

---

# BAGIAN 5 — Peta layar → endpoint

## 5.1 Dashboard
Tidak ada endpoint ringkasan untuk toko (`/dashboard/summary` **admin-only**, toko dapat 403). Susun dari:

| Kartu | Endpoint |
|---|---|
| Saldo | `GET /finance/balance` → `{held, available}` |
| Pesanan perlu tindakan | `GET /orders` → lalu `GET /orders/{id}` (lihat §5.4) |
| Kinerja & skor | `GET /reports/seller_performance` |
| Retur perlu dijawab | `GET /returns` |
| Sengketa aktif | `GET /disputes` |
| Status onboarding | `GET /sellers/{id}` |

`seller_performance` → `sla_confirmation_rate`, `cancellation_ratio`, `dispute_loss_ratio` — bisa `null` kalau penyebutnya nol; tangani agar tidak muncul "NaN%".

## 5.2 Katalog
Dua jalur, ditentukan field `jalur` di kategori:
- **`MASTER`** (komoditas) — toko **tidak boleh** bikin produk baru; tempel penawaran ke SKU master, atau ajukan lewat `sku-requests`.
- **`BEBAS`** — toko bikin produk sendiri (`is_freeform`), validasi berat & dimensi ketat.

| Layar | Endpoint |
|---|---|
| Produk saya | `GET /offers` (otomatis ter-scope) |
| Cari SKU master | `GET /sku-master?q=` atau `?category_id=` |
| **Bulk nama SKU** | `GET /sku-master?ids=1,2,3` → `{"1":{id,name,base_unit,weight_kg},...}` |
| Detail SKU | `GET /sku-master/{id}` |
| **Merek** | `GET /brands` → `{id,name,slug,is_certified,logo_url,offer_count}` |
| Buat penawaran | `POST /offers` |
| Harga bertingkat | `POST /offers/{id}/price_tiers` |
| **Cek syarat tayang** | `GET /offers/{id}/gates` |
| Aktifkan | `POST /offers/{id}/activate` |
| Nonaktifkan | `POST /offers/{id}/deactivate` |
| **Bulk harga** | `GET /offers/prices?ids=1,2,3` |
| Ulasan produk saya | `GET /offers/{id}/reviews` |

**Empat syarat tayang** dari `GET /offers/{id}/gates`:
```json
{ "seller_verified": true, "has_shipping_rate": true,
  "has_retail_tier": false, "photos_ok": false, "all_passed": false }
```
Tampilkan sebagai checklist "kenapa produk saya belum tayang". Aktivasi gagal → `422 GATES_NOT_PASSED` dengan `error.details` berisi gate mana yang gagal.

**Body `POST /offers`** jalur MASTER: `{category_id, sku_id, min_order_qty, description, photos_json, handling_class, is_sample?, sample_of_offer_id?}`
Jalur BEBAS: ganti `sku_id` dengan `is_freeform:true`, `freeform_name`, `freeform_weight_kg` (wajib > 0), + dimensi opsional.

> **Berat & dimensi SKU master read-only.** Toko tidak bisa mengubahnya.
> Untuk kategori berisiko (besi, semen, kabel), toko wajib mencantumkan merek bersertifikat — ambil dari `GET /brands` (`is_certified`).

## 5.3 Permintaan SKU baru
| Layar | Endpoint |
|---|---|
| Daftar | `GET /sku-requests?status=` |
| Ajukan | `POST /sku-requests` `{category_id, proposed_name, proposed_brand?, proposed_weight_kg?, proposed_dimensions_json?, force?}` |
| Batalkan | `POST /sku-requests/{id}/withdraw` |
| Tetap ajukan | `POST /sku-requests/{id}/resubmit` |

Status: `DIAJUKAN` · `DUPLIKAT_DISARANKAN` · `DISETUJUI` · `DITOLAK` · `DITARIK` · `LISTING_SEMENTARA` · `DIGABUNG`.

**Jelaskan pengaman `LISTING_SEMENTARA` ke toko:** kalau tim katalog tidak menjawab dalam 3×24 jam, produk tayang otomatis. Toko tidak tersandera antrean — poin kepercayaan yang layak ditampilkan.

## 5.4 Pesanan masuk — layar terpenting
| Aksi | Endpoint |
|---|---|
| Daftar | `GET /orders` |
| Detail | `GET /orders/{id}` |
| Detail sub-order | `GET /sub-orders/{id}` |
| **Konfirmasi** | `POST /sub-orders/{id}/confirm` |
| **Tolak** | `POST /sub-orders/{id}/reject` `{reason}` |
| **Siap kirim** | `POST /sub-orders/{id}/ready_to_ship` |

**Yang dikerjakan toko adalah sub-order, bukan order.**

Tiga batas waktu wajib jadi hitung mundur:

| Field | Arti | Kalau lewat |
|---|---|---|
| `seller_confirm_deadline` | Konfirmasi (1×24 jam kerja) | Auto-batal + refund + **skor −3** |
| `fleet_handover_warn_at` | Peringatan serah armada (2×24 jam kerja) | Peringatan |
| `fleet_handover_cancel_at` | Batas serah armada (4×24 jam kerja) | Auto-batal + **skor −3** |

**Alasan penolakan wajib dari daftar tertutup** — buat sebagai pilihan, bukan teks bebas:
`STOK_HABIS` · `HARGA_SALAH` · `TIDAK_SANGGUP_KIRIM` · `BARANG_RUSAK_GUDANG`

Menolak = **skor −2**. Tampilkan konsekuensinya sebelum tombol ditekan. Barang custom yang sudah `DIKONFIRMASI` → `409 CUSTOM_ITEM_LOCKED`.

⚠️ `GET /orders` untuk toko mengembalikan **baris order saja** — tanpa `sub_orders` bersarang dan **tanpa filter status** (`?status=` diabaikan, selalu 50 terbaru). Layar "Pesanan Masuk" perlu **N+1 panggilan**. Cache agresif, dan mintakan endpoint `GET /sub-orders?status=` ke tim backend.

⚠️ **Paginasi `GET /offers` tidak berlaku untuk toko.** Cabang `SEL` tidak dipaginasi dan **tidak membawa `meta`** — jangan kirim `?page=`/`?per_page=`, jangan baca `meta.total_pages`.

## 5.5 Pengiriman — termasuk peran driver
| Aksi | Endpoint | Status |
|---|---|---|
| Buat | `POST /shipments` | → `SIAP` |
| Siapkan | `POST /shipments/{id}/process` | `SIAP` → `DIPROSES` |
| Serah armada | `POST /shipments/{id}/ship` | → `DIKIRIM`, **surat jalan terbit, stok terpotong** |
| **POD** | `POST /shipments/{id}/pod` | `DIKIRIM` → `SAMPAI` |
| Gagal kirim | `POST /shipments/{id}/fail_delivery` `{reason_code}` | 3× → `GAGAL_KIRIM` |
| Barang balik | `POST /shipments/{id}/return_to_seller` | → `BALIK_KE_TOKO` |
| **Restock** | `POST /shipments/{id}/restock` | Kembalikan jadi stok jual |
| **Lepas deposit kemasan** | `POST /shipments/{id}/confirm_packaging_returned` | |
| Daftar | `GET /shipments` (ter-scope untuk toko) | |

**Body `POST /shipments`:** `{sub_order_id, shipping_method, items:[{sub_order_item_id, qty}], zone_id?, shipping_cost?, surcharge_json?, is_scheduled?, scheduled_date?, batch_id?}`
`shipping_method`: `ARMADA_TOKO` | `KURIR_3PL`. **`fleet_type_code` sementara jangan dikirim** — lihat BAGIAN 3.

**Satu sub-order boleh dipecah jadi beberapa pengiriman** — kirim sebagian `items[]` saja. Ini yang membuat toko bisa melayani kontraktor kirim bertahap, **dan uangnya cair bertahap juga**.

**`POST /shipments/{id}/pod`** — `{photo_url, receiver_name, signature_url?}` plus opsional:
```
pod_items: [{shipment_item_id, actual_qty_received}, ...]
```
Untuk kategori curah (pasir/split/batu), kalau jumlah aktual < pesanan dan selisihnya masih dalam toleransi (default 5%), sistem **otomatis me-refund proporsional**. Respons membawa `bulk_tolerance_refund`. Di layar POD lapangan, tampilkan input "jumlah aktual diterima" per baris untuk pesanan curah — ini melindungi toko dari sengketa "kurang kirim".

**`reason_code` gagal kirim** (daftar tertutup):
`KENDALA_AKSES_LINGKUNGAN` (pungli/kuli liar/dihalangi warga) · `ALAMAT_TIDAK_DITEMUKAN` · `BUYER_TIDAK_ADA` · `BARANG_RUSAK_DI_PERJALANAN` · `LAINNYA`

**`restock`** error: `409 INVALID_STATE` · `409 RESTOCK_WINDOW_NOT_REACHED` (pesan menyebut berapa hari lagi).
**`confirm_packaging_returned`** error: `409 NO_PACKAGING_DEPOSIT` · `409 ALREADY_CONFIRMED`.

**Layar POD adalah layar lapangan:** kamera langsung, input nama penerima, tanda tangan di layar, idealnya antrean offline. Tanpa POD, pengiriman tidak boleh dinyatakan sampai.

> Barang `BERBAHAYA` **diblokir** dari `KURIR_3PL` → `422 HANDLING_CLASS_BLOCKED`.

## 5.6 Stok
| Layar | Endpoint |
|---|---|
| Stok masuk | `POST /inventory/stock_in` `{offer_id, warehouse_id, qty, note?}` |
| Penyesuaian / opname | `POST /inventory/adjust` `{offer_id, warehouse_id, qty_delta, reason}` |
| Riwayat | `GET /inventory/ledger?offer_id=` |
| Stok tersedia | `GET /inventory/available?offer_id=` |

`qty_delta` boleh negatif. **`reason` wajib.** Respons `adjust` membawa `flagged_for_review` kalau melebihi ambang — saat ini hanya penanda, belum ada alur persetujuan.

> **Stok tersedia = fisik − direservasi.** Kalau turun tanpa ada pengiriman, itu karena ada pesanan belum dibayar yang mengunci stok. Jelaskan di UI.

## 5.7 Keuangan
| Layar | Endpoint |
|---|---|
| Saldo | `GET /finance/balance` → `{held, available}` |
| Riwayat mutasi | `GET /finance/ledger?limit=&offset=` |
| Tarik dana | `POST /finance/withdraw` `{amount, bank_account_id}` |
| Invoice | `GET /finance/invoices?shipment_id=` |
| Faktur pajak | `GET /finance/tax_invoices?shipment_id=` |
| Unggah e-Faktur | `POST /finance/tax_invoice_upload_efaktur/{id}` `{efaktur_reference}` |
| **Tarif komisi** | `GET /commission-rates` |

**Rumus pencairan per pengiriman:**
```
bruto          = nilai barang setelah diskon toko
komisi         = MIN(bruto × tarif kategori, batas atas)
pph22          = bruto × 0,5%
diterima toko  = bruto − komisi − pph22 − beban voucher toko + ongkir (100% milik toko)
```
Objek payout memuat tiap komponen terpisah: `bruto`, `komisi`, `pph22`, `voucher_seller_burden`, `ongkir`, `netto`, `status`, `hold_release_at`, `frozen_at`, `frozen_reason`, `released_at`. **Tampilkan rincian apa adanya** — transparansi potongan adalah alasan utama toko bertahan.

`POST /finance/withdraw` error: `403 FORBIDDEN` (rekening bukan milik toko) · `409 CONFLICT` (rekening belum `VERIFIED`) · `422 VALIDATION_ERROR` (di bawah minimum) · `422 INSUFFICIENT_BALANCE`.

**`GET /commission-rates`** → `rate_percent`, `cap_amount`, `effective_from` per kategori. **Sangat layak ditampilkan** — toko bisa melihat komisi sebelum memasang harga.

> **Uang cair per PENGIRIMAN, bukan per order.** Ongkir **100% milik toko**. Pembekuan dana berlaku **per pengiriman**.
> Toko **tidak bisa memicu pencairannya sendiri** (`recognize`/`release` admin-only) — aplikasi hanya memantau.
> ⚠️ Toko **tidak bisa melihat riwayat penarikannya** (`GET /finance/withdrawals` admin-only). Simpan `request_id` di aplikasi setelah pengajuan.

## 5.8 Retur & sengketa
| Aksi | Endpoint |
|---|---|
| Daftar retur | `GET /returns?limit=&offset=` |
| Detail | `GET /returns/{id}/detail` |
| **Jawab retur** | `POST /returns/{id}/respond` `{decision, note?, refund_route?, fault?}` |
| **Periksa barang** | `POST /returns/{id}/inspect` `{result, fault?, note?}` |
| Sengketa | `GET /disputes` · `GET /disputes/{id}/detail` |
| Tambah bukti | `POST /disputes/{id}/evidence` `{evidence_type, file_url?, text_content?}` |

`decision`: `APPROVE`/`REJECT` · `refund_route`: `DIKIRIM_BALIK`/`REFUND_TANPA_KEMBALI` · `result`: `SESUAI`/`BEDA_KONDISI`.

🔴 **Dua batas waktu yang berarti kehilangan uang:**
- **Jawab retur 2×24 jam** — diam = **dianggap menerima**
- **Periksa barang retur 2×24 jam** — diam = **dianggap sesuai**, refund diproses

Keduanya wajib jadi notifikasi paling menonjol dengan hitung mundur.

**Dua alasan retur yang SELALU beban toko:** `SHADING_MISMATCH` (beda shading/batch keramik-granit) dan `SNI_TOLERANCE_MISMATCH`. Backend **memaksa `fault=SELLER`** — parameter `fault:"BUYER"` diabaikan. **Jangan tampilkan pilihan "kesalahan pembeli"** untuk dua alasan itu.

Kalau rute `JEMPUT_TOKO` (barang berat), **toko harus menjemput dalam 3×24 jam**. Kalau tidak, retur sah, refund diproses, **dan barang jadi milik pembeli**.

🛡️ **Foto pengemasan melindungi toko.** Untuk barang pecah-belah, tanpa foto pengemasan klaim "sudah pecah saat sampai" hampir selalu dimenangkan pembeli. **Jadikan pemotretan pengemasan bagian dari alur `ship`**, bukan fitur terpisah yang baru diingat saat sengketa terjadi.

Bukti sengketa **hanya bisa ditambah, tidak bisa dihapus**.

## 5.9 Chat — ⚠️ bisa men-suspend akun toko
| Aksi | Endpoint |
|---|---|
| Daftar | `GET /chat/threads` |
| Buat | `POST /chat/threads` `{channel, context_type, context_id, counterparty_buyer_id}` |
| Baca | `GET /chat/messages?thread_id=` |
| Kirim | `POST /chat/messages` `{thread_id, text, attachment_url?}` |
| Tingkat respons | `GET /chat/seller_response_rate` |

Channel toko: `BUYER_SELLER`, `SELLER_CS`.

🔴 **RISIKO SERIUS.** Setiap pesan yang memicu penyaringan kontak — nomor HP, rekening, **tautan/URL**, ajakan transaksi di luar platform — dicatat sebagai pelanggaran. Setelah **5 pelanggaran**, status toko langsung **`SUSPENDED`**: tidak bisa login, tidak bisa berjualan.

Ini risiko nyata karena pegawai toko biasa mengirim nomor HP sopir untuk koordinasi. Yang harus dilakukan:
- **Peringatkan SEBELUM kirim** dengan konfirmasi eksplisit.
- Bandingkan teks balasan server dengan yang dikirim; kalau berbeda, beri tahu bahwa itu tercatat sebagai pelanggaran.
- Sediakan jalur sah untuk koordinasi: **nomor HP penerima sudah tersedia di data pesanan setelah dibayar**, jadi pegawai tidak perlu menempel nomor di chat.

**SLA balasan toko 1 jam pada jam kerja**, dan tingkat responsnya tampil di halaman toko yang dilihat pembeli.

## 5.10 Voucher toko
| Aksi | Endpoint |
|---|---|
| Buat | `POST /vouchers` |
| Daftar | `GET /vouchers?seller_id={id}` |
| Ubah | `PUT /vouchers/{id}` |
| Nonaktifkan | `DELETE /vouchers/{id}` (soft delete) |

Body: `{code, discount_type:"NOMINAL"|"PERCENT", discount_value, quota_total, valid_from, valid_to, max_discount_amount?, min_spend?, quota_per_user?}`. `funded_by` **dipaksa `SELLER`** untuk role `SEL`.

⚠️ **Voucher toko sekarang benar-benar dipakai.** Pembeli menempelkannya di keranjang lewat `POST /cart/voucher` dan potongannya nyata di checkout. **Bebannya dipotong dari pencairan toko** (muncul sebagai `voucher_seller_burden` di payout). Fitur yang dulu nyaris tanpa efek kini berdampak ke uang toko — **tampilkan simulasi dampaknya** saat toko membuat voucher.

Maksimal 1 voucher platform + 1 voucher toko per sub-order.

## 5.11 RFQ (kontraktor)
| Aksi | Endpoint |
|---|---|
| RFQ masuk | `GET /rfq` · `GET /rfq/{id}` |
| Penawaran saya | `GET /rfq/{id}/offers` |
| Kirim penawaran | `POST /rfq/{id}/offers` `{price, qty, valid_until?, terms_json?, parent_offer_id?}` |
| Batch kontrak | `GET /rfq/{contract_id}/batches` |
| Ajukan penyesuaian harga | `POST /rfq/{contract_id}/request_adjustment` |

- **Batas jawab 2×24 jam kerja** (`deadline_toko_jawab`); lewat itu toko **gugur dari daftar penawar**.
- **Revisi = versi baru** — kirim `parent_offer_id`; penawaran lama jadi `SUPERSEDED`. Tampilkan sebagai rangkaian versi.
- **Selalu isi `terms_json.sku_id`** — nilai itulah yang dipakai menghitung harga acuan median saat penyesuaian harga.
- Mengajukan penyesuaian harga **berisiko**: pembeli boleh membatalkan sisa kontrak, dan **diam berarti dibatalkan**. Jelaskan risikonya sebelum toko mengajukan.
- Pembeli bisa **reschedule batch** dengan penalti — toko perlu melihat perubahan jadwalnya.

## 5.12 Ongkir & laporan
| Layar | Endpoint |
|---|---|
| Tarif saya | `GET /shipping-rates` |
| Tambah/ubah tarif | `POST /shipping-rates` (upsert pada `seller_id`+`zone_id`+`fleet_type_code`) |
| Hapus tarif | `DELETE /shipping-rates/{id}` |
| Zona | `GET /zones` |
| Armada | `GET /fleet-types` |
| Laporan | `GET /reports/sales` · `/stock` · `/finance_summary` · `/seller_performance` · `/pph22` |

Body tarif: `{zone_id, fleet_type_code, base_rate, mode?, kuli_bongkar_fee?, lantai_atas_fee?, akses_sulit_fee?}`. Upsert: **201** kalau baru, **200** kalau menimpa. Menambah tarif pertama bisa langsung melengkapi gerbang ke-4 dan membuat toko `VERIFIED`.

`GET /fleet-types` kini membawa `max_payload_kg` dan `size_rank`:

| Kode | `max_payload_kg` | `size_rank` |
|---|---|---|
| `MOTOR` | 20 | 1 |
| `PICKUP` | 1.000 | 2 |
| `CDE` | 2.500 | 3 |
| `CDD` | 5.000 | 4 |
| `FUSO` | 8.000 | 5 |
| `TRONTON` | 15.000 | 6 |

**Jangan hardcode** angka ini — masih DRAFT, ambil dari endpoint.

Laporan otomatis ter-scope ke toko sendiri; parameter `seller_id` diabaikan. `from`/`to` default 30 hari terakhir.

> 🔴 **Aturan yang tidak bisa ditawar:** semua biaya wajib dideklarasikan di sistem. **Biaya yang tidak dideklarasikan dilarang ditagih di lokasi** — melanggar berarti ditanggung toko + penalti skor. Jelaskan ini saat toko mengatur tarif; inilah yang membedakan platform dari beli langsung di toko material.

---

# BAGIAN 6 — Enam jebakan teknis yang pasti ditemui

### 6.1 🔴 Format `photos_json`
Validasi membaca `width`/`height` dari **tiap elemen array**. Array string URL → `width` terbaca 0 → gate `photos_ok` **selalu gagal**.
```jsonc
// ❌ SALAH
["https://a.jpg","https://b.jpg","https://c.jpg"]
// ✅ BENAR — minimal 3 foto, masing-masing ≥800×800
[{"url":"https://a.jpg","width":1200,"height":1200},
 {"url":"https://b.jpg","width":1000,"height":1000},
 {"url":"https://c.jpg","width":900,"height":900}]
```
Server **tidak** membuka berkas gambarnya — **aplikasi wajib mengukur sendiri**.

### 6.2 🔴 `price_tiers` adalah REPLACE, bukan APPEND
`POST /offers/{id}/price_tiers` **menghapus seluruh tier lama**. Untuk mengubah satu harga: ambil `GET /offers/{id}` → `price_tiers`, ubah di aplikasi, kirim balik **daftar lengkap**. Wajib ada minimal satu tier `RETAIL` → kalau tidak, `422 MISSING_RETAIL_TIER`.

### 6.3 🔴 `POST /sku-requests` dua langkah
Kalau ada SKU serupa, respons pertama **HTTP 200** berisi `similar_found: true` + daftar — **tidak ada yang tersimpan**. Kirim ulang dengan `"force": true` → **201**. **Bedakan lewat `data.similar_found`, bukan kode HTTP.**

### 6.4 🟠 `strikethrough_price` dibuang diam-diam
Kalau harga coret tidak terbukti berlaku ≥14 hari, nilainya **hilang tanpa error**. Bandingkan respons dengan yang dikirim, beri tahu toko.

### 6.5 🟠 Daftar pesanan butuh N+1
`GET /orders` mengembalikan baris order saja, tanpa `sub_orders` bersarang dan tanpa filter status. Cache agresif; mintakan endpoint `GET /sub-orders?status=` ke backend.

### 6.6 🟠 Toko tidak bisa lihat riwayat penarikan
Simpan `request_id` di aplikasi setelah pengajuan.

---

# BAGIAN 7 — Bug backend aktif

| # | Masalah | Mitigasi FE |
|---|---|---|
| 1 | 🔴 **Berat armada dihitung qty²** (BAGIAN 3) | Jangan kirim `fleet_type_code` |
| 2 | 🔴 **Jam PHP vs MySQL beda 5 jam** — batas konfirmasi 48 jam tersimpan 43 jam. **Order bisa auto-batal + skor toko turun 3 padahal bukan salah toko** | **JANGAN tambal dengan offset di FE.** Tampilkan tanggal/jam absolut dari server; jangan buat countdown yang seolah presisi |
| 3 | 🔴 **Menolak sub-order bisa melepas reservasi stok pesanan pembeli LAIN** → berpotensi oversell | Tidak ada aksi FE; jangan heran kalau angka stok bergerak aneh setelah penolakan |
| 4 | 🟠 **`GET /shipments` tidak ter-scope untuk pembeli** — data pengiriman toko bisa dibaca pembeli mana pun | Risiko, bukan pekerjaan FE |
| 5 | 🟠 **`POST /vouchers/apply` tanpa autentikasi** — bebannya mengurangi pencairan toko | Jangan dipanggil |

---

# BAGIAN 8 — Yang belum ada API-nya

**Jangan dibangun, jangan mengarang endpoint.**

**upload file** (semua endpoint hanya menerima URL — aplikasi wajib punya storage sendiri; ini prasyarat untuk KYC, foto produk, dan POD) · **notifikasi push/in-app** (paling mendesak untuk dimintakan — aplikasi ini sepenuhnya bergantung pada batas waktu) · import massal produk · mode libur/tutup toko · logout · ubah profil · ganti password · lupa password · OTP · riwayat penarikan dana · filter & paginasi daftar pesanan · PDF surat jalan/faktur · chat realtime · modul jasa.

Endpoint yang **bukan** untuk toko (403): `/dashboard/summary` · `/menus` · `/user-groups` · `/permissions` · `/shipments/0/storage_fee_sweep` · `/config/archive_sweep` · `/finance/ledger_integrity_check` · `/finance/tax_invoices_overdue_efaktur` · `/finance/withdrawals`.

---

# BAGIAN 9 — Akun & data uji

**Password semua akun: `password123`**

| Peran | Login | `seller_id` | Status |
|---|---|---|---|
| **Toko** | `081100000003` | **1** | `VERIFIED`, gudang 1 |
| **Distributor** | `081100000004` | **2** | `VERIFIED` — "Distributor Resmi Semen Gresik" |
| **Toko baru** | `081100000005` | **3** | `DRAFT` — untuk uji wizard onboarding dari nol |

Admin (**login pakai EMAIL**, bukan nomor HP): `ops@markas.test` · `cat@markas.test` · `fin@markas.test` · `fin2@markas.test` · `cs@markas.test` · `sys@markas.test`

Data: **81 SKU master · 188 penawaran aktif (semuanya berstok) · 23 merek · 24 toko VERIFIED · 57 ulasan · 8 pesanan** dengan status berbeda (2 `SELESAI` + payout, 1 pengiriman `SAMPAI`, 1 `SIAP`, 3 menunggu konfirmasi toko, 2 `MENUNGGU_BAYAR`).

---

# BAGIAN 10 — Urutan pengerjaan

| Tahap | Isi |
|---|---|
| 1 | Fondasi: klien HTTP + interceptor amplop, token & auto-refresh, error terpusat |
| 2 | **Onboarding**: registrasi, checklist 4 gerbang, KYC, rekening, perjanjian, gudang, tarif ongkir |
| 3 | Katalog: daftar produk, cari SKU master, buat penawaran, harga tier, foto, checklist syarat tayang, aktivasi |
| 4 | Stok: masuk, penyesuaian, ledger |
| 5 | **Pesanan**: daftar, detail, konfirmasi/tolak, hitung mundur |
| 6 | **Pengiriman + POD lapangan** |
| 7 | Keuangan: saldo, ledger, rincian pencairan, tarik dana, tarif komisi |
| 8 | Purna jual: retur (+ hitung mundur), sengketa, chat (+ peringatan anti-suspend) |
| 9 | Voucher, RFQ, laporan |

Tahap 2 dan 5–6 adalah inti nilai aplikasi ini. Kalau waktu terbatas, itu yang diprioritaskan.

---

*Disusun dari pembacaan kode + pengujian live terhadap backend pada branch `wip-harlan`, 11 September 2026.*

---

# LAMPIRAN A — Koreksi & temuan dari pengujian FE (11 September 2026)

Diuji ulang terhadap backend yang sama dengan akun `081100000003`. Tiga hal di bawah tidak cocok dengan isi brief dan perlu masuk BAGIAN 7.

### A.1 🔴 `GET /offers` dibatasi 50 baris — bukan "tidak dipaginasi"

§5.4 menyatakan cabang `SEL` "tidak dipaginasi", yang terbaca sebagai "mengembalikan semua". Yang terjadi: dua endpoint ter-scope toko dari backend yang sama saling bertentangan.

| Sumber | Jumlah penawaran milik `seller_id=1` |
|---|---|
| `GET /reports/stock` | **124** |
| `GET /offers` | **50** |

79 produk tidak terjangkau. `page`, `per_page`, `limit`, `offset`, `status` semuanya diabaikan, dan tidak ada `meta`. Yang dikembalikan adalah **50 id terbesar**, jadi produk terlama toko yang hilang — dan membuat produk baru mendorong satu produk lama keluar dari daftar.

**Mitigasi FE:** peringatan di header tab Produk saat daftar pas 50. Tidak ada yang bisa FE lakukan selain itu. **Minta paginasi pada cabang `SEL`.**

### A.2 🔴 `pod_items` diterima lalu dibuang diam-diam

§5.5 menyebut `pod_items` sebagai perlindungan toko dari sengketa "kurang kirim". Diuji dengan `curl` langsung (tanpa aplikasi) pada dua pengiriman berbeda:

```
POST /shipments/5/pod
  {"photo_url":"...","receiver_name":"Uji Kontrak",
   "pod_items":[{"shipment_item_id":5,"actual_qty_received":28}]}
→ 200 {"status":"SAMPAI","bulk_tolerance_refund":null}

GET /shipments/5 → items[0].actual_qty_received = null
```

Nilainya tidak tersimpan, tanpa error. Dua-duanya barang non-curah (semen kategori 1, keramik) — mungkin fitur ini memang di-gate ke kategori `is_bulk_material` (hanya kategori 4 di seed), tapi **kalau begitu penolakannya harus eksplisit**, bukan 200 diam-diam.

Ini berbahaya karena persis membalik tujuan fiturnya: toko mengira sudah mencatat kekurangan, padahal tidak ada catatan apa pun saat sengketa datang.

**Mitigasi FE:** setelah POD sukses, aplikasi membaca ulang pengiriman dan membandingkan jumlah yang dideklarasikan dengan yang tersimpan. Kalau tidak cocok, toko diberi tahu bahwa hitungannya **tidak** tersimpan.

### A.3 🟠 `GET /shipments` tidak membawa `items[]`

Hanya `GET /shipments/{id}` yang membawanya. Akibatnya layar detail sub-pesanan mengira belum ada barang yang dikirim, lalu menawarkan mengirim ulang barang yang sama — "sisa 40 dari 40" padahal 40-nya sudah berangkat.

**Mitigasi FE:** setelah memuat daftar, aplikasi membaca ulang tiap pengiriman milik sub-pesanan itu untuk mendapatkan barisnya.

### A.4 Catatan kecil

- `POST /offers` hampir tidak memvalidasi: menerima penawaran ganda untuk SKU yang sama, produk bebas di kategori `MASTER`, dan SKU master di kategori `BEBAS`. `DELETE /offers/{id}` → `METHOD_NOT_ALLOWED`, dan `PUT` mengabaikan `status`. Aturan `jalur` sepenuhnya jadi tanggung jawab FE, dan salah input tidak bisa dibatalkan.
- `PUT /offers/{id}` adalah update parsial sungguhan — field yang tidak dikirim tidak ikut terhapus.
- `GET /categories`, `GET /sku-master`, `GET /brands`, `GET /commission-rates` mengembalikan **array telanjang** di `data`, bukan objek berkunci.
