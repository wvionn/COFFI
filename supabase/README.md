# Setup Panduan Supabase Backend Cafeku

Dokumen ini memandu langkah-langkah aktivasi database Supabase untuk aplikasi **Cafeku**.

## Langkah 1: Buat Project Baru di Supabase
1. Buka [https://supabase.com](https://supabase.com) dan login.
2. Klik **New Project**, beri nama `Cafeku POS`, masukkan database password, dan pilih region terdekat (misal: Singapore `ap-southeast-1`).

## Langkah 2: Jalankan Script SQL Migration & Seed
1. Buka menu **SQL Editor** di dashboard Supabase.
2. Buka file `supabase/migrations/20261005000000_init_cafeku_schema.sql`, salin seluruh kodenya, lalu tempel di SQL Editor dan tekan **Run**.
3. Buka file `supabase/seed.sql`, salin isinya, tempel di SQL Editor dan tekan **Run** untuk mengisi kategori awal, meja, dan menu cafe.

## Langkah 3: Periksa Supabase Storage Bucket
1. Script SQL otomatis membuat bucket bernama `product-images` dengan status Public.
2. Anda dapat melihatnya di menu **Storage** -> `product-images`.

## Langkah 4: Dapatkan URL & Anon Key
1. Buka menu **Project Settings** -> **API**.
2. Salin:
   - **Project URL** (misal: `https://xyzcompany.supabase.co`)
   - **Project API Anon Key** (kunci publik `eyJhbG...`)
3. Masukkan ke file Flutter di `lib/core/constants/supabase_config.dart` atau atur langsung di halaman **Pengaturan Admin** di dalam aplikasi Cafeku.

> **Catatan Pengujian Cepat / Offline**:
> Aplikasi Cafeku juga dilengkapi dengan **Demo Mode & Local Fallback Engine**. Jika kredensial Supabase belum diisi, aplikasi tetap dapat dijalankan 100% secara interaktif dengan data demo bawaan untuk keperluan presentasi, testing, dan praktikum kampus!
