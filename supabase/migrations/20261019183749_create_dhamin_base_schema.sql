/*
# Create base schema for Dhamin prototype

1. New Tables
- `requests`: posted service requests (id text PK, title, sector, description, bids int, budget text, created_at)
- `offers`: bids submitted by muqeebs on requests (id text PK, request_id -> requests, muqeeb, rating numeric, price numeric, days int, note text, created_at)
- `conversations`: one per accepted offer (id text PK, request_id -> requests, title, client_name, provider_name, last_message, last_message_time, created_at)
- `messages`: chat messages inside a conversation (id text PK, conversation_id -> conversations, sender, text, taameed_id, display_time, created_at)
- `taameeds`: financial escrow agreements (id text PK, conversation_id -> conversations, title, terms, amount numeric, date, status, created_at)
- `disputes`: raised disputes on a conversation (conversation_id PK -> conversations, created_at)

2. Security
- RLS enabled on every table.
- Prototype is no-auth (the login screen is a UI mock). All policies TO anon, authenticated WITH (true) so the shared prototype data is readable/writable by the anon-key client.
- This matches the existing `conversation-attachments` storage policies already scoped to anon, authenticated.

3. Important notes
- Idempotent: uses IF NOT EXISTS for tables; DROP POLICY IF EXISTS before CREATE POLICY.
- No user_id columns (no real auth users). No destructive changes to existing objects.
- Seeds a few sample rows so the app renders content on first load.
*/

CREATE TABLE IF NOT EXISTS public.requests (
  id text PRIMARY KEY,
  title text NOT NULL,
  sector text NOT NULL DEFAULT 'أخرى',
  description text NOT NULL DEFAULT '',
  bids integer NOT NULL DEFAULT 0,
  budget text NOT NULL DEFAULT 'مفتوح',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.offers (
  id text PRIMARY KEY,
  request_id text NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  muqeeb text NOT NULL,
  rating numeric NOT NULL DEFAULT 5,
  price numeric NOT NULL DEFAULT 0,
  days integer NOT NULL DEFAULT 1,
  note text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.conversations (
  id text PRIMARY KEY,
  request_id text NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  title text NOT NULL,
  client_name text NOT NULL DEFAULT '',
  provider_name text NOT NULL DEFAULT '',
  last_message text NOT NULL DEFAULT '',
  last_message_time text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.messages (
  id text PRIMARY KEY,
  conversation_id text NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender text NOT NULL,
  text text,
  taameed_id text,
  display_time text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  attachment_path text,
  attachment_name text,
  attachment_mimetype text,
  attachment_size bigint
);

CREATE TABLE IF NOT EXISTS public.taameeds (
  id text PRIMARY KEY,
  conversation_id text NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  title text NOT NULL,
  terms text NOT NULL DEFAULT '',
  amount numeric NOT NULL DEFAULT 0,
  date text NOT NULL,
  status text NOT NULL DEFAULT 'pending_payment',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.disputes (
  conversation_id text PRIMARY KEY REFERENCES public.conversations(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taameeds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_requests" ON public.requests;
CREATE POLICY "anon_select_requests" ON public.requests FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_requests" ON public.requests;
CREATE POLICY "anon_insert_requests" ON public.requests FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_requests" ON public.requests;
CREATE POLICY "anon_update_requests" ON public.requests FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_requests" ON public.requests;
CREATE POLICY "anon_delete_requests" ON public.requests FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_offers" ON public.offers;
CREATE POLICY "anon_select_offers" ON public.offers FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_offers" ON public.offers;
CREATE POLICY "anon_insert_offers" ON public.offers FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_offers" ON public.offers;
CREATE POLICY "anon_update_offers" ON public.offers FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_offers" ON public.offers;
CREATE POLICY "anon_delete_offers" ON public.offers FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_conversations" ON public.conversations;
CREATE POLICY "anon_select_conversations" ON public.conversations FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_conversations" ON public.conversations;
CREATE POLICY "anon_insert_conversations" ON public.conversations FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_conversations" ON public.conversations;
CREATE POLICY "anon_update_conversations" ON public.conversations FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_conversations" ON public.conversations;
CREATE POLICY "anon_delete_conversations" ON public.conversations FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_messages" ON public.messages;
CREATE POLICY "anon_select_messages" ON public.messages FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_messages" ON public.messages;
CREATE POLICY "anon_insert_messages" ON public.messages FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_messages" ON public.messages;
CREATE POLICY "anon_update_messages" ON public.messages FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_messages" ON public.messages;
CREATE POLICY "anon_delete_messages" ON public.messages FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_taameeds" ON public.taameeds;
CREATE POLICY "anon_select_taameeds" ON public.taameeds FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_taameeds" ON public.taameeds;
CREATE POLICY "anon_insert_taameeds" ON public.taameeds FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_taameeds" ON public.taameeds;
CREATE POLICY "anon_update_taameeds" ON public.taameeds FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_taameeds" ON public.taameeds;
CREATE POLICY "anon_delete_taameeds" ON public.taameeds FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_disputes" ON public.disputes;
CREATE POLICY "anon_select_disputes" ON public.disputes FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_disputes" ON public.disputes;
CREATE POLICY "anon_insert_disputes" ON public.disputes FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_disputes" ON public.disputes;
CREATE POLICY "anon_update_disputes" ON public.disputes FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_disputes" ON public.disputes;
CREATE POLICY "anon_delete_disputes" ON public.disputes FOR DELETE TO anon, authenticated USING (true);

ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.taameeds;
ALTER PUBLICATION supabase_realtime ADD TABLE public.requests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.offers;

INSERT INTO public.requests (id, title, sector, description, bids, budget) VALUES
  ('R1', 'تجديد السجل التجاري', 'وزارة التجارة', 'تجديد سجل تجاري منتهي وإصدار وكالة جديدة', 3, '800 - 1,200 ر.س'),
  ('R2', 'استخراج تصريح بلدي', 'بلدي', 'تصريح مؤقت لمظلة خارجية لمحل تجاري', 2, '500 ر.س'),
  ('R3', 'تقديم اعتماد أبشر', 'أبشر', 'إصدار هوية وطنية جديدة عبر أبشر', 5, 'مفتوح')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.offers (id, request_id, muqeeb, rating, price, days, note) VALUES
  ('O1', 'R1', 'مكتب الرياض للتعقيب', 4.9, 850, 3, 'يشمل جميع الرسوم الحكومية والتوصيل'),
  ('O2', 'R1', 'معقب جدة السريع', 4.7, 920, 2, 'خدمة عاجلة خلال 48 ساعة'),
  ('O3', 'R2', 'مكتب مكة للخدمات', 4.8, 480, 2, 'تجربة سابقة في نفس الحي')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.conversations (id, request_id, title, client_name, provider_name, last_message, last_message_time) VALUES
  ('conv-trade-renewal', 'R1', 'تجديد السجل التجاري', 'أبو يزن', 'مكتب الرياض للتعقيب', 'تم قبول العرض وبدأ التوافق.', '10:25 ص')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.messages (id, conversation_id, sender, text, display_time) VALUES
  ('m1', 'conv-trade-renewal', 'system', 'تم قبول عرض مكتب الرياض للتعقيب. بدأت المحادثة للتوافق على التفاصيل قبل إنشاء التعميد.', '10:20 ص'),
  ('m2', 'conv-trade-renewal', 'muqeeb', 'أهلاً أبو يزن، سأبدأ بالمعاملة فور تأكيدكم للتفاصيل.', '10:25 ص')
ON CONFLICT (id) DO NOTHING;
