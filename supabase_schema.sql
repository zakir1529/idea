-- =========================================================================
-- SUPABASE POSTGRESQL SCHEMA FOR ZYRO CLOTHING BRAND INVENTORY SYSTEM
-- =========================================================================

-- 1. Create the organized inventory table
CREATE TABLE IF NOT EXISTS public.inventory (
    id TEXT PRIMARY KEY,                       -- Alphanumeric key (e.g. drop_needle_button_shirt_black_s_v1)
    name TEXT NOT NULL,                        -- Product name
    type TEXT NOT NULL,                        -- Category (e.g. Shirt, Polo, Trouser, Tank Top, Shorts)
    style TEXT DEFAULT 'Plain',                -- Style classification
    size TEXT NOT NULL,                        -- Size (S, M, L, XL)
    color TEXT NOT NULL,                       -- Display color name
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    price NUMERIC(10, 2) NOT NULL,             -- Selling price
    cost_price NUMERIC(10, 2) DEFAULT 0.00,    -- Unit cost price
    low_stock INTEGER NOT NULL DEFAULT 5,       -- Alert threshold level
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create performance search indexes for fast POS loading and filters
CREATE INDEX IF NOT EXISTS idx_inventory_type ON public.inventory(type);
CREATE INDEX IF NOT EXISTS idx_inventory_color_size ON public.inventory(color, size);
CREATE INDEX IF NOT EXISTS idx_inventory_quantity ON public.inventory(quantity);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

-- 4. Enable Public CRUD Access Policies for POS Terminal
DROP POLICY IF EXISTS "Allow public read access" ON public.inventory;
CREATE POLICY "Allow public read access" ON public.inventory FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert access" ON public.inventory;
CREATE POLICY "Allow public insert access" ON public.inventory FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update access" ON public.inventory;
CREATE POLICY "Allow public update access" ON public.inventory FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete access" ON public.inventory;
CREATE POLICY "Allow public delete access" ON public.inventory FOR DELETE USING (true);


-- =========================================================================
-- ACCESSORIES DATABASE TABLE
-- =========================================================================

-- Create the organized accessories table
CREATE TABLE IF NOT EXISTS public.accessories (
    id TEXT PRIMARY KEY,                       -- Alphanumeric key (e.g. watch_premium_v1)
    name TEXT NOT NULL,                        -- Product name
    type TEXT NOT NULL,                        -- Category (e.g. Watches, Belt, Chains, Bracelett, Socks, Arms Sleves, Underwears, Wallet)
    style TEXT DEFAULT 'Plain',                -- Style classification
    size TEXT NOT NULL DEFAULT 'N/A',          -- Size (or N/A)
    color TEXT NOT NULL,                       -- Display color name
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    price NUMERIC(10, 2) NOT NULL,             -- Selling price
    cost_price NUMERIC(10, 2) DEFAULT 0.00,    -- Unit cost price
    low_stock INTEGER NOT NULL DEFAULT 5,       -- Alert threshold level
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Performance search indexes for accessories
CREATE INDEX IF NOT EXISTS idx_accessories_type ON public.accessories(type);
CREATE INDEX IF NOT EXISTS idx_accessories_quantity ON public.accessories(quantity);

-- Enable Row Level Security (RLS) for accessories
ALTER TABLE public.accessories ENABLE ROW LEVEL SECURITY;

-- Enable Public CRUD Access Policies for Accessories
DROP POLICY IF EXISTS "Allow public read access" ON public.accessories;
CREATE POLICY "Allow public read access" ON public.accessories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert access" ON public.accessories;
CREATE POLICY "Allow public insert access" ON public.accessories FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update access" ON public.accessories;
CREATE POLICY "Allow public update access" ON public.accessories FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete access" ON public.accessories;
CREATE POLICY "Allow public delete access" ON public.accessories FOR DELETE USING (true);


-- =========================================================================
-- SALES / RECEIPTS DATABASE TABLES
-- =========================================================================

-- One row per completed checkout receipt.
CREATE TABLE IF NOT EXISTS public.sales (
    id TEXT PRIMARY KEY,                       -- Invoice id (e.g. INV-123456)
    subtotal NUMERIC(10, 2) NOT NULL DEFAULT 0,
    discount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    discount_percent NUMERIC(5, 2) NOT NULL DEFAULT 0,
    total NUMERIC(10, 2) NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    sold_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Individual products/accessories inside each receipt.
CREATE TABLE IF NOT EXISTS public.sale_items (
    id TEXT PRIMARY KEY,                       -- Deterministic key: sale_id + item index
    sale_id TEXT NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
    product_id TEXT,
    name TEXT NOT NULL,
    type TEXT,
    style TEXT,
    size TEXT,
    color TEXT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price NUMERIC(10, 2) NOT NULL DEFAULT 0,
    cost_price NUMERIC(10, 2) NOT NULL DEFAULT 0,
    line_total NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_sales_sold_at ON public.sales(sold_at DESC);
CREATE INDEX IF NOT EXISTS idx_sales_payment_method ON public.sales(payment_method);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON public.sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON public.sale_items(product_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_name ON public.sale_items(name);

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access" ON public.sales;
CREATE POLICY "Allow public read access" ON public.sales FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert access" ON public.sales;
CREATE POLICY "Allow public insert access" ON public.sales FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update access" ON public.sales;
CREATE POLICY "Allow public update access" ON public.sales FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete access" ON public.sales;
CREATE POLICY "Allow public delete access" ON public.sales FOR DELETE USING (true);

DROP POLICY IF EXISTS "Allow public read access" ON public.sale_items;
CREATE POLICY "Allow public read access" ON public.sale_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert access" ON public.sale_items;
CREATE POLICY "Allow public insert access" ON public.sale_items FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update access" ON public.sale_items;
CREATE POLICY "Allow public update access" ON public.sale_items FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete access" ON public.sale_items;
CREATE POLICY "Allow public delete access" ON public.sale_items FOR DELETE USING (true);

-- Optional convenience view for analytics/reporting in Supabase.
CREATE OR REPLACE VIEW public.sales_analytics_daily AS
SELECT
    date_trunc('day', sold_at) AS sales_day,
    COUNT(*) AS order_count,
    COALESCE(SUM(total), 0) AS total_sales,
    COALESCE(SUM(discount), 0) AS total_discount
FROM public.sales
GROUP BY date_trunc('day', sold_at)
ORDER BY sales_day DESC;