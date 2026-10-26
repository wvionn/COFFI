-- ========================================================================
-- CAFEKU SEED DATA (Categories, Products, Tables, Initial Setup)
-- ========================================================================

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, name, icon, sort_order, is_active) VALUES
('c0000000-0000-0000-0000-000000000001', 'Coffee', 'coffee', 1, true),
('c0000000-0000-0000-0000-000000000002', 'Non-Coffee', 'local_drink', 2, true),
('c0000000-0000-0000-0000-000000000003', 'Food & Meal', 'restaurant', 3, true),
('c0000000-0000-0000-0000-000000000004', 'Snacks', 'fastfood', 4, true),
('c0000000-0000-0000-0000-000000000005', 'Pastry & Dessert', 'cake', 5, true)
ON CONFLICT (id) DO NOTHING;

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
ON CONFLICT (table_number) DO NOTHING;

-- 3. SEED PRODUCTS
INSERT INTO public.products (id, category_id, name, description, price, cost_price, stock, min_stock, track_stock, is_active, image_url) VALUES
('p0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Kopi Susu Aren', 'Signature espresso dengan susu segar dan gula aren asli', 22000.00, 8500.00, 45, 10, true, true, 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Americano Iced', 'Double shot espresso dengan air dingin segar', 18000.00, 4200.00, 60, 10, true, true, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'Caramel Macchiato', 'Espresso creamy dengan sirup vanilla dan saus karamel lezat', 28000.00, 11000.00, 30, 8, true, true, 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'Matcha Latte', 'Green tea murni dari Uji dengan susu gurih', 24000.00, 9500.00, 25, 5, true, true, 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', 'Chocolate Signature', 'Cokelat Belgia leleh dipadukan dengan fresh milk', 23000.00, 9000.00, 35, 5, true, true, 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'Nasi Goreng Spesial', 'Nasi goreng racikan dapur dengan telur, ayam suwir & kerupuk', 32000.00, 14000.00, 20, 5, true, true, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000004', 'French Fries BBQ', 'Kentang goreng renyah dengan taburan bumbu BBQ gurih', 18000.00, 7000.00, 18, 5, true, true, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000004', 'Roti Bakar Coklat Keju', 'Roti panggang mentega dengan meses coklat dan keju cheddar tebal', 20000.00, 8000.00, 15, 4, true, true, 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=500&auto=format&fit=crop&q=60'),
('p0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000005', 'Croissant Butter', 'Freshly baked croissant Prancis berlapis mentega lembut', 25000.00, 11500.00, 12, 3, true, true, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&auto=format&fit=crop&q=60')
ON CONFLICT (id) DO NOTHING;
