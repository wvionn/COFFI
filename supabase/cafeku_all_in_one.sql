-- ========================================================================
-- CAFEKU POS, KITCHEN & CUSTOMER SELF-ORDER SYSTEM
-- ALL-IN-ONE SUPABASE DATABASE SETUP & SEED SCRIPT
-- Version: 2.0.0 (Unified, Complete & Idempotent)
-- ========================================================================
-- Petunjuk Penggunaan:
-- 1. Buka dashboard Supabase (https://supabase.com/dashboard)
-- 2. Pilih Project Anda -> Buka menu "SQL Editor" di bilah kiri
-- 3. Klik tombol "New query", paste SELURUH isi script ini, lalu tekan tombol "Run" (hijau)
-- 4. Semua tabel, relasi, trigger, RLS, storage bucket, dan menu awal otomatis siap!
-- ========================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUM TYPES
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'kasir', 'dapur', 'user');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('menunggu_validasi', 'pending', 'diproses', 'siap', 'dikirim', 'selesai', 'dibatalkan');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_type AS ENUM ('dine_in', 'takeaway', 'delivery');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_method AS ENUM ('cash', 'qris', 'transfer', 'cashless');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE stock_movement_type AS ENUM ('in', 'out', 'adjustment');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE table_status AS ENUM ('available', 'occupied', 'reserved');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Update ENUMs jika sebelumnya sudah terbuat dengan versi lama
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'user';
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'menunggu_validasi';
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'dikirim';
ALTER TYPE order_type ADD VALUE IF NOT EXISTS 'delivery';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'cashless';

-- 3. PROFILES (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    role user_role NOT NULL DEFAULT 'user',
    pin_code VARCHAR(6) DEFAULT '1234',
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Backward-compatibility: pastikan kolom email & phone ada jika profiles sudah dibuat sebelumnya
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email VARCHAR(255);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS pin_code VARCHAR(6) DEFAULT '1234';

-- 4. CAFE TABLES (Meja Cafe)
CREATE TABLE IF NOT EXISTS public.cafe_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_number VARCHAR(20) UNIQUE NOT NULL,
    area VARCHAR(50) DEFAULT 'Indoor',
    capacity INT DEFAULT 4,
    status table_status DEFAULT 'available',
    current_order_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CATEGORIES (Kategori Menu)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50) DEFAULT 'coffee',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. PRODUCTS (Menu Makanan & Minuman)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    stock INT DEFAULT 0,
    min_stock INT DEFAULT 5,
    track_stock BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ORDERS (Pesanan)
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    order_type order_type NOT NULL DEFAULT 'dine_in',
    table_id UUID REFERENCES public.cafe_tables(id) ON DELETE SET NULL,
    table_number VARCHAR(20),
    customer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_name VARCHAR(100),
    customer_phone VARCHAR(20),
    delivery_address TEXT,
    cashier_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    cashier_name VARCHAR(100),
    status order_status NOT NULL DEFAULT 'pending',
    subtotal_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_hpp NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Backward-compatibility untuk kolom customer & delivery pada orders
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS total_hpp NUMERIC(12,2) DEFAULT 0.00;

-- 8. ORDER ITEMS (Detail Pesanan)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL,
    hpp NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    subtotal NUMERIC(12,2) NOT NULL,
    notes VARCHAR(255),
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PAYMENTS (Pembayaran)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    payment_method payment_method NOT NULL DEFAULT 'cash',
    amount_paid NUMERIC(12,2) NOT NULL,
    change_amount NUMERIC(12,2) DEFAULT 0.00,
    payment_status payment_status NOT NULL DEFAULT 'paid',
    reference_number VARCHAR(100),
    paid_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. STOCK MOVEMENTS (Riwayat Mutasi Stok)
CREATE TABLE IF NOT EXISTS public.stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    product_name VARCHAR(100),
    type stock_movement_type NOT NULL,
    quantity INT NOT NULL,
    stock_before INT NOT NULL,
    stock_after INT NOT NULL,
    reference_id UUID,
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ORDER STATUS LOGS (Audit Trail Perubahan Status Pesanan)
CREATE TABLE IF NOT EXISTS public.order_status_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    from_status order_status,
    to_status order_status NOT NULL,
    changed_by UUID REFERENCES public.profiles(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================================================
-- INDEXES UNTUK PERFORMA CEPAT
-- ========================================================================
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON public.stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON public.payments(order_id);

-- ========================================================================
-- FUNCTIONS & TRIGGERS
-- ========================================================================

-- A. Otomatis buat profil saat akun baru mendaftar di Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role, pin_code, is_active)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.email,
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'user'),
        COALESCE(NEW.raw_user_meta_data->>'pin_code', '1234'),
        TRUE
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
        role = COALESCE(EXCLUDED.role, public.profiles.role);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- B. Otomatis perbarui updated_at timestamp
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS set_cafe_tables_updated_at ON public.cafe_tables;
CREATE TRIGGER set_cafe_tables_updated_at BEFORE UPDATE ON public.cafe_tables FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS set_products_updated_at ON public.products;
CREATE TRIGGER set_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS set_orders_updated_at ON public.orders;
CREATE TRIGGER set_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- C. Trigger sinkronisasi status meja cafe dengan pesanan Dine-In
CREATE OR REPLACE FUNCTION public.sync_order_table_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_type = 'dine_in' AND NEW.table_id IS NOT NULL THEN
        IF NEW.status IN ('pending', 'diproses', 'siap') THEN
            UPDATE public.cafe_tables
            SET status = 'occupied', current_order_id = NEW.id
            WHERE id = NEW.table_id;
        ELSIF NEW.status IN ('selesai', 'dibatalkan') THEN
            UPDATE public.cafe_tables
            SET status = 'available', current_order_id = NULL
            WHERE id = NEW.table_id AND (current_order_id = NEW.id OR current_order_id IS NULL);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_order_status_change ON public.orders;
CREATE TRIGGER on_order_status_change
    AFTER INSERT OR UPDATE OF status, table_id ON public.orders
    FOR EACH ROW EXECUTE PROCEDURE public.sync_order_table_status();

-- D. Trigger otomatis memotong stok saat item pesanan dibuat
CREATE OR REPLACE FUNCTION public.deduct_product_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_track_stock BOOLEAN;
    v_current_stock INT;
    v_new_stock INT;
    v_product_name VARCHAR(100);
BEGIN
    SELECT track_stock, stock, name INTO v_track_stock, v_current_stock, v_product_name
    FROM public.products WHERE id = NEW.product_id;

    IF v_track_stock = TRUE AND v_current_stock IS NOT NULL THEN
        v_new_stock := GREATEST(0, v_current_stock - NEW.quantity);
        UPDATE public.products
        SET stock = v_new_stock
        WHERE id = NEW.product_id;

        INSERT INTO public.stock_movements (
            product_id, product_name, type, quantity, stock_before, stock_after, reference_id, notes
        ) VALUES (
            NEW.product_id, v_product_name, 'out', NEW.quantity, v_current_stock, v_new_stock, NEW.order_id, 'Pengurangan otomatis dari pesanan'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_order_item_inserted ON public.order_items;
CREATE TRIGGER on_order_item_inserted
    AFTER INSERT ON public.order_items
    FOR EACH ROW EXECUTE PROCEDURE public.deduct_product_stock();

-- ========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cafe_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_logs ENABLE ROW LEVEL SECURITY;

-- Hapus policy lama dengan aman agar script dapat dijalankan berulang kali
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname, tablename 
        FROM pg_policies 
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, r.tablename);
    END LOOP;
END $$;

-- Kebijakan Akses Lengkap (Anon & Authenticated untuk kemudahan sinkronisasi POS & Self-Order)
CREATE POLICY "Allow public read profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Allow public insert profiles" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update profiles" ON public.profiles FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete profiles" ON public.profiles FOR DELETE USING (true);

CREATE POLICY "Allow public read cafe_tables" ON public.cafe_tables FOR SELECT USING (true);
CREATE POLICY "Allow public insert cafe_tables" ON public.cafe_tables FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update cafe_tables" ON public.cafe_tables FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete cafe_tables" ON public.cafe_tables FOR DELETE USING (true);

CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Allow public insert categories" ON public.categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update categories" ON public.categories FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete categories" ON public.categories FOR DELETE USING (true);

CREATE POLICY "Allow public read products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Allow public insert products" ON public.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update products" ON public.products FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete products" ON public.products FOR DELETE USING (true);

CREATE POLICY "Allow public read orders" ON public.orders FOR SELECT USING (true);
CREATE POLICY "Allow public insert orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update orders" ON public.orders FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete orders" ON public.orders FOR DELETE USING (true);

CREATE POLICY "Allow public read order_items" ON public.order_items FOR SELECT USING (true);
CREATE POLICY "Allow public insert order_items" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update order_items" ON public.order_items FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete order_items" ON public.order_items FOR DELETE USING (true);

CREATE POLICY "Allow public read payments" ON public.payments FOR SELECT USING (true);
CREATE POLICY "Allow public insert payments" ON public.payments FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update payments" ON public.payments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete payments" ON public.payments FOR DELETE USING (true);

CREATE POLICY "Allow public read stock_movements" ON public.stock_movements FOR SELECT USING (true);
CREATE POLICY "Allow public insert stock_movements" ON public.stock_movements FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update stock_movements" ON public.stock_movements FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete stock_movements" ON public.stock_movements FOR DELETE USING (true);

CREATE POLICY "Allow public read order_status_logs" ON public.order_status_logs FOR SELECT USING (true);
CREATE POLICY "Allow public insert order_status_logs" ON public.order_status_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update order_status_logs" ON public.order_status_logs FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow public delete order_status_logs" ON public.order_status_logs FOR DELETE USING (true);

-- ========================================================================
-- REALTIME SUBSCRIPTION ENABLING
-- ========================================================================

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
EXCEPTION WHEN duplicate_object THEN null; WHEN undefined_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.order_items;
EXCEPTION WHEN duplicate_object THEN null; WHEN undefined_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.cafe_tables;
EXCEPTION WHEN duplicate_object THEN null; WHEN undefined_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
EXCEPTION WHEN duplicate_object THEN null; WHEN undefined_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.stock_movements;
EXCEPTION WHEN duplicate_object THEN null; WHEN undefined_object THEN null;
END $$;

-- ========================================================================
-- STORAGE BUCKET SETUP (For Product Images)
-- ========================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Public Read Product Images" ON storage.objects;
    DROP POLICY IF EXISTS "Public Upload Product Images" ON storage.objects;
    DROP POLICY IF EXISTS "Public Update Product Images" ON storage.objects;
    DROP POLICY IF EXISTS "Public Delete Product Images" ON storage.objects;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY "Public Read Product Images" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
CREATE POLICY "Public Upload Product Images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-images');
CREATE POLICY "Public Update Product Images" ON storage.objects FOR UPDATE USING (bucket_id = 'product-images');
CREATE POLICY "Public Delete Product Images" ON storage.objects FOR DELETE USING (bucket_id = 'product-images');

-- ========================================================================
-- SEED DATA (Categories, Tables, Products)
-- ========================================================================

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, name, icon, sort_order, is_active) VALUES
('c0000000-0000-0000-0000-000000000001', 'Coffee', 'coffee', 1, true),
('c0000000-0000-0000-0000-000000000002', 'Non-Coffee', 'local_drink', 2, true),
('c0000000-0000-0000-0000-000000000003', 'Food & Meal', 'restaurant', 3, true),
('c0000000-0000-0000-0000-000000000004', 'Snacks', 'fastfood', 4, true),
('c0000000-0000-0000-0000-000000000005', 'Pastry & Dessert', 'cake', 5, true),
('c0000000-0000-0000-0000-000000000006', 'Manual Brew', 'coffee_maker', 6, true),
('c0000000-0000-0000-0000-000000000007', 'Beans', 'grain', 7, true)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name, 
    icon = EXCLUDED.icon, 
    sort_order = EXCLUDED.sort_order, 
    is_active = EXCLUDED.is_active;

-- 2. SEED CAFE TABLES (Indoor 1..6, Outdoor 1..3, VIP 1)
INSERT INTO public.cafe_tables (id, table_number, area, capacity, status) VALUES
('t0000000-0000-0000-0000-000000000001', 'Meja 01', 'Indoor', 4, 'available'),
('t0000000-0000-0000-0000-000000000002', 'Meja 02', 'Indoor', 2, 'available'),
('t0000000-0000-0000-0000-000000000003', 'Meja 03', 'Indoor', 4, 'available'),
('t0000000-0000-0000-0000-000000000004', 'Meja 04', 'Indoor', 4, 'available'),
('t0000000-0000-0000-0000-000000000005', 'Meja 05', 'Indoor', 6, 'available'),
('t0000000-0000-0000-0000-000000000006', 'Meja 06', 'Indoor', 2, 'available'),
('t0000000-0000-0000-0000-000000000007', 'Outdoor 01', 'Outdoor', 4, 'available'),
('t0000000-0000-0000-0000-000000000008', 'Outdoor 02', 'Outdoor', 4, 'available'),
('t0000000-0000-0000-0000-000000000009', 'Outdoor 03', 'Outdoor', 6, 'available'),
('t0000000-0000-0000-0000-000000000010', 'VIP Lounge', 'VIP', 8, 'available')
ON CONFLICT (table_number) DO UPDATE SET
    area = EXCLUDED.area,
    capacity = EXCLUDED.capacity,
    status = EXCLUDED.status;

-- 3. SEED PRODUCTS (Menu Lengkap Kafe dengan Foto HD)
INSERT INTO public.products (id, category_id, name, description, price, cost_price, stock, min_stock, track_stock, is_active, image_url) VALUES
('p0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'COFFI Aren Signature', 'Signature double espresso dengan susu segar dan sirup gula aren murni', 22000.00, 8500.00, 45, 10, true, true, 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Iced Americano', 'Double shot premium arabica espresso dengan air dingin segar', 18000.00, 4200.00, 60, 10, true, true, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'Caramel Macchiato', 'Espresso creamy dipadukan sirup vanilla manis dan drizzle saus karamel lezat', 28000.00, 11000.00, 30, 8, true, true, 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001', 'Cafe Latte', 'Espresso klasik dengan steamed milk lembut dan foam halus', 25000.00, 9000.00, 35, 8, true, true, 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', 'Matcha Zen Latte', 'Matcha impor dari Uji Kyoto dengan fresh milk gurih dan madu', 24000.00, 9500.00, 25, 5, true, true, 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', 'Dark Choco Blast', 'Cokelat hitam Belgia 70% dengan krim kental dan taburan cocoa nibs', 23000.00, 9000.00, 35, 5, true, true, 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000002', 'Royal Thai Tea', 'Seduhan daun teh hitam Thailand otentik dengan racikan condensed milk', 20000.00, 7000.00, 30, 5, true, true, 'https://images.unsplash.com/photo-1558857563-b37cfb8cb83a?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000003', 'Nasi Goreng Spesial', 'Nasi goreng harum rempah cafe dengan telur mata sapi, ayam suwir & kerupuk udang', 32000.00, 14000.00, 20, 5, true, true, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000004', 'French Fries BBQ', 'Kentang goreng impor renyah keemasan dengan taburan bumbu BBQ gurih', 18000.00, 7000.00, 18, 5, true, true, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000004', 'Roti Bakar Coklat Keju', 'Roti panggang mentega wangi isi meses coklat melimpah dan taburan cheddar gurih', 20000.00, 8000.00, 15, 4, true, true, 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000011', 'c0000000-0000-0000-0000-000000000005', 'Butter Croissant', 'Croissant mentega Prancis berlapis renyah dipanggang segar setiap pagi', 25000.00, 11500.00, 12, 3, true, true, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&auto=format&fit=crop&q=60')
ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    price = EXCLUDED.price,
    cost_price = EXCLUDED.cost_price,
    stock = EXCLUDED.stock,
    min_stock = EXCLUDED.min_stock,
    track_stock = EXCLUDED.track_stock,
    is_active = EXCLUDED.is_active,
    image_url = EXCLUDED.image_url;
