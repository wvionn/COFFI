-- ========================================================================
-- MIGRATION: ADD USER ROLE & DELIVERY SUPPORT (MVP)
-- ========================================================================

-- 1. Extend user_role ENUM with 'user'
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'user';

-- 2. Extend order_status ENUM with 'menunggu_validasi' and 'dikirim'
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'menunggu_validasi';
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'dikirim';

-- 3. Extend order_type ENUM with 'delivery'
ALTER TYPE order_type ADD VALUE IF NOT EXISTS 'delivery';

-- 4. Add delivery and customer relations to orders table
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS delivery_address TEXT;
