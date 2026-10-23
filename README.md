# ☕ Cafeku - Modern Cafe Point of Sale, Kitchen Management & Self-Ordering System

**Cafeku (COFFI)** adalah ekosistem aplikasi kasir pintar (Point of Sale), sistem display dapur (Kitchen Display System - KDS), dan pemesanan mandiri pelanggan (*Customer Self-Ordering & Delivery*) terintegrasi berbasis Flutter dan backend Supabase (PostgreSQL, Supabase Auth, Realtime, dan Storage).

Aplikasi ini menghubungkan 4 peran (*Role-Based Access Control*): **Admin (Owner)**, **Kasir (POS & Validator)**, **Dapur (KDS Barista)**, dan **Pelanggan (User)** dalam satu siklus operasional kafe yang utuh dan *real-time*.

---

## 🚀 Fitur Unggulan Sistem (4 Role Terintegrasi)

### 1. 👤 Pelanggan / User (Customer Self-Ordering & Live Tracking)
- **Katalog Menu Digital**:
  - Filter kategori horizontal swipeable (*Coffee, Non-Coffee, Food & Meal, Snacks, Pastry*).
  - Pencarian menu instan dengan indikator ketersediaan stok (*In Stock* vs *Habis*).
- **Sticky Bottom Cart Bar**:
  - Menampilkan ringkasan jumlah menu dan total tagihan secara interaktif.
- **3 Mode Pemesanan Fleksibel**:
  - 🍽️ **Dine-In (Makan di Tempat)**: Pemilihan nomor meja kafe yang terintegrasi langsung dengan denah meja.
  - 🛍️ **Takeaway (Bawa Pulang)**: Pesan bawa pulang untuk diambil sendiri tanpa perlu antre di kafe.
  - 🛵 **Delivery (Pesan Antar)**: Input alamat lengkap pengantaran dan nomor WhatsApp penerima.
- **Metode Pembayaran Sederhana**:
  - 📱 **QRIS Instan**: Tampilan kode QR pop-up responsif dengan tombol konfirmasi pembayaran.
  - 💵 **Bayar di Kasir / Tunai (COD)**: Pembayaran tunai saat tiba di kafe atau saat kurir mengantar pesanan.
- **Pelacakan Status Pesanan Realtime (*Live Step Progress Tracker*)**:
  - Status pesanan terupdate otomatis mengikuti alur kerja kasir dan dapur:
    $$\text{Menunggu Validasi} \longrightarrow \text{Sedang Diracik Dapur} \longrightarrow \text{Siap Ambil / Siap Antar} \longrightarrow \text{Sedang Diantar Kurir} \longrightarrow \text{Selesai}$$

---

### 2. 💵 Kasir POS & Validation Hub
- **POS Kasir Cepat (Fast Counter Checkout)**:
  - Grid pemilihan meja visual (🟢 Tersedia, 🔴 Terisi, 🔵 Terpilih).
  - Kustomisasi item (*Hot/Iced, Sweetness Level, Catatan Barista*).
  - Perhitungan pajak restoran otomatis (**PB1 10%**).
  - Kalkulator uang pas, pecahan rupiah cepat, dan kembalian tunai.
  - Cetak struk belanja thermal simulasi (Bluetooth 58mm/80mm) dan kirim struk via WhatsApp.
- **Pusat Validasi Pesanan Online (*Live Order Tracking & Validator*)**:
  - Tab filter khusus **`⚡ Perlu Validasi`** dengan badge peringatan merah untuk pesanan online baru dari aplikasi pelanggan.
  - **Tombol Satu Ketukan**:
    - **`[✅ Terima & Masuk Dapur]`**: Memvalidasi pesanan dan mengubah status menjadi `pending`, otomatis membunyikan lonceng pesanan baru dan memunculkan tiket di KDS Dapur.
    - **`[❌ Tolak]`**: Membatalkan pesanan fiktif atau jika meja/stok habis.
  - **Manajemen Pengantaran Delivery**:
    - Tombol **`[🛵 Mulai Antar (Ke Kurir)]`** untuk menandai pesanan keluar kafe (status `dikirim`).
    - Tombol **`[Konfirmasi Pesanan Sampai]`** untuk menyelesaikan transaksi delivery (status `selesai`).

---

### 3. 🍳 Kitchen Display System (KDS Layar Dapur & Barista)
- **High Readability Dark UI**: Kontras tinggi khusus lingkungan dapur dan barista bar.
- **Sinkronisasi Supabase Realtime**:
  - Tiket baru kasir/validasi otomatis masuk tanpa refresh manual.
  - **Audio-Visual Chime Alert**: Bunyi lonceng dan banner getar saat pesanan baru tiba.
- **Tiket Pesanan Digital (FIFO Sorted)**:
  - Badge jenis pesanan kontras tinggi: `[🍽️ DINE-IN - MEJA 03]`, `[🛍️ TAKEAWAY]`, atau `[🛵 DELIVERY]`.
  - **Penghitung Waktu Masak (Elapsed Timer)** dengan indikator warna dinamis:
    - 🟢 Hijau: 0 - 7 menit (Aman).
    - 🟡 Kuning: 8 - 14 menit (Peringatan).
    - 🔴 Merah Berkedip: $\ge$ 15 menit (Pesanan Terlambat / Overdue).
  - **Highlight Catatan Khusus**: Teks kustomisasi dicetak tebal dengan latar belakang kuning terang agar barista tidak salah racik.
  - **Checklist Item**: Centang menu satu per satu yang telah selesai dibuat.
- **Tombol Aksi Satu Ketukan ($\ge$ 48x48dp)**:
  - Tab `[🔥 BARU]` ➔ `[ 🍳 TERIMA & MULAI PROSES ]`
  - Tab `[🍳 PROSES]` ➔ `[ ✅ PESANAN SIAP SAJI ]`
  - Tab `[✅ SIAP]` ➔ `[ 🍽️ TANDAI SELESAI / AMBIL ]` (Otomatis mengubah status meja menjadi kosong/tersedia).
- **Mode 86 (Sold-Out Quick Toggle)**:
  - Tombol cepat bagi koki/barista untuk mematikan menu jika bahan baku habis mendadak.

---

### 4. 🛡️ Dashboard Admin & Pengaturan Bisnis
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
- **Kelola Staf & Akun**:
  - Pengaturan multi-akun (Admin, Kasir, Dapur, Pelanggan).
- **Konfigurasi Supabase**:
  - Pengaturan URL & Anon Key langsung di aplikasi dengan indikator status koneksi live.

---

## 🛠️ Arsitektur Teknologi

- **Frontend**: Flutter 3.41+ (Dart 3.11+)
- **Design System**: "Warm Coffee Brown" (Google Fonts Plus Jakarta Sans, Custom Color Tokens: Espresso Dark `#38220F`, Roasted Coffee `#4A2E1B`, Warm Caramel `#8C5535`, Cream Latte `#EDE0D4`, Oat Milk Foam `#FAF7F2`)
- **State Management**: Provider Architecture
- **Backend**: Supabase
- **Database**: PostgreSQL (UUID, Relational Tables, Custom ENUMs, Triggers, RLS Policies)
- **Authentication**: Supabase Auth + Fast PIN & Demo Quick Accounts Switcher
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
│   │   ├── profile_model.dart         # User roles (admin, kasir, dapur, user)
│   │   ├── table_model.dart           # Meja cafe, area & status ketersediaan
│   │   ├── category_model.dart        # Kategori menu
│   │   ├── product_model.dart         # Produk, HPP, margin, stok
│   │   ├── order_model.dart           # Pesanan, invoice, timer, delivery & status
│   │   ├── order_item_model.dart      # Item transaksi & catatan modifier
│   │   ├── payment_model.dart         # Pembayaran Tunai, QRIS, Transfer
│   │   └── stock_movement_model.dart  # Audit mutasi stok barang
│   ├── services/
│   │   ├── supabase_service.dart      # Supabase client, queries, realtime & demo fallback
│   │   └── auth_service.dart          # Auth email & demo accounts
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── table_provider.dart
│   │   ├── menu_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── order_provider.dart
│   │   └── admin_dashboard_provider.dart
│   ├── views/
│   │   ├── auth/
│   │   │   └── login_screen.dart      # Login dengan Demo Quick Accounts
│   │   ├── customer/
│   │   │   └── customer_main_screen.dart # Self-Ordering, Menu, Cart & Live Tracker
│   │   ├── kasir/
│   │   │   ├── kasir_main_screen.dart # Katalog POS & Floating Cart Bar
│   │   │   ├── cart_checkout_screen.dart
│   │   │   ├── payment_screen.dart
│   │   │   ├── kasir_orders_tracking_screen.dart # Pelacakan & Validasi Pesanan Online
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
│   │   ├── 20261005000000_init_cafeku_schema.sql # DDL, Triggers, RLS & Storage
│   │   └── 20261022000000_add_user_role_and_delivery.sql # Migrasi role user & delivery
│   ├── seed.sql                       # Data awal kategori, meja & menu
│   └── README.md                      # Panduan setup Supabase live
└── wireframes/
    ├── PRD_CAFEKU.md                  # PRD lengkap
    └── ...
```

---

## 🔑 Akun Demo Cepat (Quick Access)

Untuk memudahkan demo dan pengujian tanpa perlu mendaftar manual:

| Role | Nama Akun | Email Demo | Halaman Tujuan |
|---|---|---|---|
| **Admin / Owner** | Ronald (Owner) | `admin@coffi.com` | Dashboard Admin, Stok, Laporan & Pengaturan |
| **Kasir** | Siti Rahma | `kasir@coffi.com` | POS Kasir & Validasi Pesanan Online Masuk |
| **Dapur / Barista** | Budi Santoso | `dapur@coffi.com` | KDS Layar Dapur Realtime |
| **Pelanggan / User** | Aviona (Pelanggan) | `user@coffi.com` | Self-Ordering (Dine-in, Takeaway, Delivery) & Live Status |

*(Password default: `123456`, atau cukup klik tombol chip cepat di bagian bawah layar Login)*.

---

## 💻 Cara Menjalankan Aplikasi

1. **Jalankan Aplikasi Flutter**:
   ```bash
   flutter run
   ```
   *(Dapat dijalankan di Android Device/Emulator, Chrome Web, atau Windows Desktop)*.

2. **Menghubungkan ke Supabase Live (Opsional)**:
   - Buat project baru di [supabase.com](https://supabase.com).
   - Eksekusi file SQL `supabase/migrations/20261005000000_init_cafeku_schema.sql` dan `supabase/migrations/20261022000000_add_user_role_and_delivery.sql` di SQL Editor Supabase.
   - Eksekusi file `supabase/seed.sql` untuk mengisi data menu dan meja.
   - Salin **Project URL** dan **Anon Key** ke menu **Admin ➔ Pengaturan ➔ Supabase** di dalam aplikasi.
