# ☕ Cafeku - Modern Cafe Point of Sale & Kitchen Management System

**Cafeku** adalah aplikasi kasir pintar (Point of Sale) dan sistem display dapur (Kitchen Display System - KDS) terintegrasi berbasis Flutter dan backend Supabase (PostgreSQL, Supabase Auth, Realtime, dan Storage).

Aplikasi ini diimplementasikan secara komprehensif mengikuti spesifikasi pada [PRD_CAFEKU.md](wireframes/PRD_CAFEKU.md) dan wireframe desain mobile yang telah disepakati.

---

## 🚀 Fitur Unggulan Sistem

### 1. 💵 Kasir POS (Fast Counter Checkout)
- **Mode Pesanan Fleksibel**:
  - **Dine-In**: Pemilihan visual meja cafe (Grid Meja dengan indikator status: 🟢 Kosong, 🔴 Terisi, 🔵 Terpilih).
  - **Takeaway**: Input nama pelanggan atau nomor antrean tanpa memilih meja.
- **Katalog & Pencarian Instan**:
  - Filter kategori horizontal swipeable (*Coffee, Non-Coffee, Food & Meal, Snacks, Pastry*).
  - Pencarian real-time nama menu.
- **Kustomisasi & Item Modifier**:
  - Pilihan suhu (*Dingin / Iced* vs *Panas / Hot*).
  - Level kemanisan (*Normal, Less Sugar, No Sugar*).
  - Catatan khusus dapur (e.g. *Oat milk, es sedikit, saus sambal pisah*).
- **Sticky Bottom Cart Bar**:
  - Menampilkan ringkasan total item & total nominal rupiah.
- **Pembayaran Model Pay-First**:
  - **Tunai (Cash)**: Tombol cepat nominal (*Uang Pas, 50.000, 100.000, 200.000*) + kalkulasi kembalian otomatis.
  - **QRIS Dinamis**: Tampilan kode QR responsif sesuai nominal tagihan.
  - **Transfer Bank**: Nomor rekening resmi cafe & input nomor referensi.
  - Perhitungan pajak resto otomatis (**PB1 10%**).
- **Struk Transaksi**:
  - Desain struk thermal realistis dengan rincian item, catatan racikan, subtotal, pajak, dan kembalian.
  - Opsi simulasi cetak struk Bluetooth Thermal printer 58mm/80mm & kirim via WhatsApp.
- **Kasir Live Order Tracking**:
  - Memantau proses masak di dapur secara langsung (*Menunggu Antrean*, *Sedang Dimasak*, *Siap Disajikan*).
  - Tombol aksi *"Tandai Sudah Diantar Pelanggan"* untuk menyelesaikan pesanan dan otomatis mengosongkan meja.

### 2. 🍳 Kitchen Display System (KDS Layar Dapur & Barista)
- **High Readability Dark UI**: Dirancang dengan kontras tinggi untuk visibilitas optimal di lingkungan dapur/barista.
- **Sinkronisasi Supabase Realtime**:
  - Pesanan baru kasir otomatis masuk ke layar dapur tanpa refresh manual.
  - **Audio-Visual Chime Alert**: Bunyi lonceng dan banner getar saat pesanan baru tiba.
- **Tiket Pesanan Digital (FIFO Sorted)**:
  - Badge meja/antrean kontras tinggi (`[🍽️ DINE IN - MEJA 03]` atau `[🛍️ TAKEAWAY - BPK HENDRA]`).
  - **Penghitung Waktu Masak (Elapsed Timer)** dengan indikator warna dinamis:
    - 🟢 Hijau: 0 - 7 menit (Aman).
    - 🟡 Kuning: 8 - 14 menit (Peringatan).
    - 🔴 Merah Berkedip: $\ge$ 15 menit (Pesanan Terlambat / Overdue).
  - **Highlight Catatan Khusus**: Teks kustomisasi dicetak tebal dengan latar belakang kuning terang agar barista tidak salah racik.
  - **Checklist Item**: Centang menu satu per satu yang telah selesai dibuat.
- **Tombol Aksi Ergonomis Satu Ketukan ($\ge$ 48x48dp)**:
  - Tab `[🔥 BARU]` ➔ `[ 🍳 TERIMA & MULAI PROSES ]`
  - Tab `[🍳 PROSES]` ➔ `[ ✅ PESANAN SIAP SAJI ]`
  - Tab `[✅ SIAP]` ➔ `[ 🍽️ TANDAI SELESAI / AMBIL ]` (Otomatis mengubah status meja menjadi kosong/tersedia).
- **Mode 86 (Sold-Out Quick Toggle)**:
  - Tombol cepat bagi koki/barista untuk mematikan menu jika bahan baku habis mendadak.

### 3. 🛡️ Dashboard Admin & Pengaturan
- **Dashboard Omset Realtime**:
  - Metrik finansial: Total Omset Kotor, Total HPP (Modal), Laba Bersih, Estimasi Margin (%), dan Total Transaksi.
  - Ringkasan operasional: Meja terisi live, pesanan aktif di dapur, stok menipis, dan staf aktif.
  - Peringatan stok kritis dengan tombol cepat *"Restock Sekarang"*.
- **Kelola Menu & HPP**:
  - Tambah & Edit menu dengan foto, kategori, harga jual, dan HPP modal.
  - Kalkulator otomatis margin keuntungan (%).
  - Toggle pelacakan stok (*track_stock*).
- **Manajemen Stok & Mutasi**:
  - Fitur Restock stok masuk dengan pencatatan biaya beli modal supplier.
  - Fitur Stock Opname (penyesuaian fisik vs sistem) dengan alasan audit trail.
  - Log riwayat mutasi stok (tipe IN, OUT, ADJUSTMENT).
- **Laporan & Analitik**:
  - Filter periode: Hari Ini, Kemarin, 7 Hari Terakhir, Bulan Ini.
  - Top 5 Menu Terlaris (*Best-Selling Items*).
  - Riwayat lengkap transaksi kasir.
- **Manajemen Meja Cafe**:
  - Daftar meja dengan area (Indoor, Outdoor, VIP) dan kapasitas kursi.
  - Tombol darurat *"Paksa Kosongkan Meja"*.
  - Fitur **Batch Auto-Generate Meja (1..N)** untuk setup cepat meja cafe.
- **Kelola Staf & PIN**:
  - Pengaturan multi-akun (Admin, Kasir, Dapur) dan PIN masuk cepat.
- **Konfigurasi Supabase**:
  - Pengaturan URL & Anon Key langsung di aplikasi dengan indikator status koneksi live.

---

## 🛠️ Arsitektur Teknologi

- **Frontend**: Flutter 3.41+ (Dart 3.11+)
- **Design System**: "Warm Coffee Brown" (Google Fonts Plus Jakarta Sans, Custom Color Tokens: Espresso Dark `#38220F`, Roasted Coffee `#4A2E1B`, Warm Caramel `#8C5535`, Cream Latte `#EDE0D4`, Oat Milk Foam `#FAF7F2`)
- **State Management**: Provider Architecture
- **Backend**: Supabase
- **Database**: PostgreSQL (UUID, Relational Tables, Custom ENUMs, Triggers, RLS Policies)
- **Authentication**: Supabase Auth + Fast 4-Digit Staff PIN Login
- **Realtime**: Supabase Realtime WebSocket Channels (`orders`, `order_items`, `cafe_tables`, `products`)
- **Storage**: Supabase Storage (`product-images` public bucket)
- **Offline / Presentation Resilience**: Built-in Mock Fallback Engine sehingga aplikasi tetap dapat diuji 100% tanpa kendala jaringan.

---

## 📁 Struktur Direktori

```
Cafeku/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # Palet warna Warm Coffee Brown
│   │   │   └── supabase_config.dart   # Konfigurasi kredensial Supabase
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Material 3 Theme & Google Fonts
│   │   └── utils/
│   │       ├── currency_formatter.dart# Format Rupiah (Rp 25.000)
│   │       └── sound_service.dart     # Audio & haptic chime alert
│   ├── models/
│   │   ├── profile_model.dart         # User roles (admin, kasir, dapur) & PIN
│   │   ├── table_model.dart           # Meja cafe, area & status ketersediaan
│   │   ├── category_model.dart        # Kategori menu
│   │   ├── product_model.dart         # Produk, HPP, margin, stok
│   │   ├── order_model.dart           # Pesanan, invoice, timer, status
│   │   ├── order_item_model.dart      # Item transaksi & catatan modifier
│   │   ├── payment_model.dart         # Pembayaran Tunai, QRIS, Transfer
│   │   └── stock_movement_model.dart  # Audit mutasi stok barang
│   ├── services/
│   │   ├── supabase_service.dart      # Supabase client, queries, realtime & demo fallback
│   │   └── auth_service.dart          # Auth email & Fast PIN login
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── table_provider.dart
│   │   ├── menu_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── order_provider.dart
│   │   └── admin_dashboard_provider.dart
│   ├── views/
│   │   ├── auth/
│   │   │   └── login_screen.dart      # Login PIN & Email dengan Demo Accounts
│   │   ├── kasir/
│   │   │   ├── kasir_main_screen.dart # Katalog POS & Floating Cart Bar
│   │   │   ├── cart_checkout_screen.dart
│   │   │   ├── payment_screen.dart
│   │   │   ├── kasir_orders_tracking_screen.dart
│   │   │   └── widgets/
│   │   │       ├── table_selector_sheet.dart
│   │   │       ├── item_modifier_sheet.dart
│   │   │       └── receipt_dialog.dart
│   │   ├── dapur/
│   │   │   ├── dapur_kds_screen.dart  # Layar Dapur KDS Realtime
│   │   │   └── dapur_sold_out_screen.dart # Mode 86 Menu Habis
│   │   └── admin/
│   │       ├── admin_main_screen.dart # 5 Tab Bottom Navigation
│   │       └── tabs/
│   │           ├── admin_dashboard_tab.dart
│   │           ├── admin_menu_tab.dart
│   │           ├── admin_stock_tab.dart
│   │           ├── admin_reports_tab.dart
│   │           └── admin_settings_tab.dart
│   └── main.dart
├── supabase/
│   ├── migrations/
│   │   └── 20261005000000_init_cafeku_schema.sql # DDL, Triggers, RLS & Storage
│   ├── seed.sql                       # Data awal kategori, meja & menu
│   └── README.md                      # Panduan setup Supabase live
└── wireframes/
    ├── PRD_CAFEKU.md                  # PRD lengkap
    └── ...
```

---

## 🔑 Akun Demo Cepat (Quick Access)

Untuk memudahkan demo dan pengujian tanpa perlu mendaftar:

| Role | Nama Pengguna | PIN Cepat | Halaman Tujuan |
|---|---|---|---|
| **Admin / Owner** | Ronald | `1234` | Dashboard Admin & Laporan Finansial |
| **Kasir** | Siti Rahma | `1111` | POS Kasir & Pemilihan Meja |
| **Dapur / Barista** | Budi Santoso | `2222` | KDS Layar Dapur Realtime |

*(Atau klik langsung chip avatar akun demo yang tersedia di bagian bawah layar Login)*.

---

## 💻 Cara Menjalankan Aplikasi

1. **Jalankan Aplikasi Flutter**:
   ```bash
   flutter run
   ```
   *(Pilih perangkat: Android Emulator, Chrome Web, atau Windows Desktop)*.

2. **Menghubungkan ke Supabase Live (Opsional)**:
   - Buat project baru di [supabase.com](https://supabase.com).
   - Eksekusi file SQL `supabase/migrations/20261005000000_init_cafeku_schema.sql` di SQL Editor Supabase.
   - Eksekusi file `supabase/seed.sql` untuk mengisi data menu dan meja.
   - Salin **Project URL** dan **Anon Key** ke menu **Admin ➔ Pengaturan ➔ Supabase** di dalam aplikasi.
