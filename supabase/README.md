# Panduan Lengkap Setup & Sinkronisasi Supabase Cafeku

Dokumen ini memandu langkah-langkah aktivasi database Supabase untuk aplikasi **Cafeku (POS, Kitchen KDS, & Customer Self-Order)**.

---

## Langkah 1: Buat Project Baru di Supabase
1. Buka [https://supabase.com/dashboard](https://supabase.com/dashboard) dan login.
2. Klik **New Project**.
3. Masukkan:
   - **Name**: `Cafeku POS`
   - **Database Password**: Buat password yang kuat dan catat.
   - **Region**: Pilih yang terdekat (misal: Singapore `ap-southeast-1`).
4. Tunggu beberapa saat sampai project selesai di-provisioning.

---

## Langkah 2: Eksekusi Script SQL Master All-in-One
File master SQL sudah disiapkan secara lengkap dan menyeluruh pada:
`supabase/cafeku_all_in_one.sql`

1. Buka menu **SQL Editor** pada sidebar kiri dashboard Supabase Anda.
2. Klik **+ New query**.
3. Buka file [cafeku_all_in_one.sql](file:///c:/Users/Aviona/Praktikum%20Kampus/Pemrograman%20Mobile/Cafeku/supabase/cafeku_all_in_one.sql), salin (Copy) seluruh kodenya.
4. Tempel (Paste) di editor Supabase, lalu tekan tombol **Run** (tombol hijau di pojok kanan bawah editor).
5. Pastikan muncul pesan **"Success. No rows returned"**.

Script ini secara otomatis membuat:
- **Enum Types**: `user_role` (`admin`, `kasir`, `dapur`, `user`), `order_status`, `order_type`, `payment_method`, dll.
- **Tabel Utama**: `profiles`, `cafe_tables`, `categories`, `products`, `orders`, `order_items`, `payments`, `stock_movements`, `order_status_logs`.
- **Triggers**:
  - Auto-generate profil pengguna saat mendaftar lewat Auth (`handle_new_user`).
  - Auto-update status ketersediaan meja cafe saat pesanan Dine-In dibuat/selesai (`sync_order_table_status`).
  - Auto-deduct pengurangan stok produk saat pesanan diproses (`deduct_product_stock`).
- **Row Level Security (RLS)**: Kebijakan akses lengkap dan terbuka untuk anon & authenticated agar tidak terjadi error 403 / permission denied saat sinkronisasi di aplikasi.
- **Supabase Realtime**: Otomatis berlangganan perubahan tabel `orders`, `order_items`, `cafe_tables`, `products`, dll.
- **Supabase Storage**: Bucket `product-images` publik siap pakai untuk upload gambar produk.
- **Seed Data Awal**: 7 kategori, 10 meja cafe (Indoor, Outdoor, VIP), dan 11 produk menu lengkap dengan foto HD, HPP, serta stok awal.

---

## Langkah 3: Ambil URL & Kunci API (Anon Key)
1. Di dashboard Supabase, buka menu **Project Settings** (ikon gear di pojok kiri bawah) -> **API**.
2. Salin nilai berikut:
   - **Project URL** (misal: `https://abcdefghijkl.supabase.co`)
   - **Project API Keys** -> bagian **`anon` `public`** (kunci panjang berawalan `eyJhbGciOi...`).

---

## Langkah 4: Masukkan Kredensial ke Aplikasi Cafeku
Anda memiliki dua cara mudah:

### Opsi A (Melalui File Dart):
Buka file `lib/core/constants/supabase_config.dart`, lalu ganti:
```dart
static String supabaseUrl = 'https://abcdefghijkl.supabase.co'; // Ganti dengan URL Supabase Anda
static String supabaseAnonKey = 'eyJhbGciOi...'; // Ganti dengan anon key Anda
```

### Opsi B (Langsung dari Dalam Aplikasi):
1. Jalankan aplikasi Cafeku di emulator / perangkat.
2. Masuk sebagai **Admin** (atau login demo).
3. Buka tab **Pengaturan** (Settings).
4. Masukkan **Supabase URL** dan **Anon Key**, lalu klik **Simpan & Uji Koneksi**.

---

> **Mode Offline / Demo Fallback**:
> Jika Supabase belum terhubung atau saat offline tanpa internet, aplikasi Cafeku tetap 100% fungsional dengan in-memory demo engine bawaan untuk keperluan presentasi dan penilaian praktikum kampus!
