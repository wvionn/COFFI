-- ========================================================================
-- CAFEKU POS & KITCHEN MANAGEMENT SYSTEM
-- PostgreSQL Schema for Supabase
-- Version: 1.0.0 (MVP)
-- ========================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUM TYPES
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'kasir', 'dapur');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('pending', 'diproses', 'siap', 'selesai', 'dibatalkan');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_type AS ENUM ('dine_in', 'takeaway');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_method AS ENUM ('cash', 'qris', 'transfer');
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

-- 3. PROFILES (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'kasir',
    pin_code VARCHAR(6), -- Quick switch user via 4-6 digit PIN
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CAFE TABLES (Meja Cafe)
CREATE TABLE IF NOT EXISTS public.cafe_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_number VARCHAR(20) UNIQUE NOT NULL, -- e.g. "Meja 01", "Outdoor 02"
    area VARCHAR(50) DEFAULT 'Indoor', -- "Indoor", "Outdoor", "VIP"
    capacity INT DEFAULT 4,
    status table_status DEFAULT 'available',
    current_order_id UUID, -- NULL jika meja kosong
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CATEGORIES
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50) DEFAULT 'coffee',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. PRODUCTS (Menu Cafe)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(12,2) NOT NULL DEFAULT 0.00, -- HPP
    stock INT DEFAULT 0,
    min_stock INT DEFAULT 5,
    track_stock BOOLEAN DEFAULT TRUE, -- False untuk produk racikan tanpa stok langsung
    is_active BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ORDERS (Pesanan)
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- e.g. "INV/20261005/0001"
    order_type order_type NOT NULL DEFAULT 'dine_in',
    table_id UUID REFERENCES public.cafe_tables(id) ON DELETE SET NULL,
    table_number VARCHAR(20), -- Denormalized for fast receipt printing
    customer_name VARCHAR(50), -- Mandatory if Takeaway
    cashier_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    cashier_name VARCHAR(100),
    status order_status NOT NULL DEFAULT 'pending',
    subtotal_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00, -- PB1 10%
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_hpp NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    notes TEXT, -- Catatan umum pesanan
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. ORDER ITEMS (Detail Menu per Pesanan)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name VARCHAR(100) NOT NULL, -- Snapshot nama produk saat transaksi
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL,
    hpp NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    subtotal NUMERIC(12,2) NOT NULL,
    notes VARCHAR(255), -- Catatan spesifik item (e.g. "Less Sugar, Less Ice")
    is_completed BOOLEAN DEFAULT FALSE, -- Checklist item staff dapur
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
    reference_number VARCHAR(100), -- No referensi QRIS / Transfer
    paid_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. STOCK MOVEMENTS (Mutasi Stok)
CREATE TABLE IF NOT EXISTS public.stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    product_name VARCHAR(100),
    type stock_movement_type NOT NULL,
    quantity INT NOT NULL,
    stock_before INT NOT NULL,
    stock_after INT NOT NULL,
    reference_id UUID, -- order_id or manual adjustment ID
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ORDER STATUS LOGS (Audit Trail Perubahan Status Dapur/Kasir)
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
-- FUNCTIONS & TRIGGERS
-- ========================================================================

-- A. Auto create profile when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role, pin_code, is_active)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', new.email),
        COALESCE((new.raw_user_meta_data->>'role')::user_role, 'kasir'),
        COALESCE(new.raw_user_meta_data->>'pin_code', '1234'),
        TRUE
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- B. Auto update updated_at timestamp
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

-- C. Trigger to sync Cafe Table status with Orders
CREATE OR REPLACE FUNCTION public.sync_order_table_status()
RETURNS TRIGGER AS $$
BEGIN
    -- If order is Dine-In and has a table assigned
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

-- D. Trigger to deduct stock when order items are created
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

    IF v_track_stock = TRUE THEN
        v_new_stock := GREATEST(0, v_current_stock - NEW.quantity);
        UPDATE public.products
        SET stock = v_new_stock
        WHERE id = NEW.product_id;

        INSERT INTO public.stock_movements (
            product_id, product_name, type, quantity, stock_before, stock_after, reference_id, notes
        ) VALUES (
            NEW.product_id, v_product_name, 'out', NEW.quantity, v_current_stock, v_new_stock, NEW.order_id, 'Pengurangan pesanan kasir'
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

-- Allow authenticated users to perform operations
CREATE POLICY "Allow authenticated read profiles" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);
CREATE POLICY "Allow public read profiles for login" ON public.profiles FOR SELECT TO anon USING (true);

CREATE POLICY "Allow public read cafe_tables" ON public.cafe_tables FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage cafe_tables" ON public.cafe_tables FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage categories" ON public.categories FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read products" ON public.products FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage products" ON public.products FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read orders" ON public.orders FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage orders" ON public.orders FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read order_items" ON public.order_items FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage order_items" ON public.order_items FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read payments" ON public.payments FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage payments" ON public.payments FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read stock_movements" ON public.stock_movements FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage stock_movements" ON public.stock_movements FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow public read order_status_logs" ON public.order_status_logs FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow authenticated manage order_status_logs" ON public.order_status_logs FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ========================================================================
-- REALTIME SUBSCRIPTION ENABLING
-- ========================================================================

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.order_items;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.cafe_tables;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ========================================================================
-- STORAGE BUCKET SETUP (For Product Images)
-- ========================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public read of product images
CREATE POLICY "Public Read Product Images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- Policy to allow authenticated uploads to product images
CREATE POLICY "Authenticated Upload Product Images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Authenticated Update Product Images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images');

CREATE POLICY "Authenticated Delete Product Images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'product-images');
