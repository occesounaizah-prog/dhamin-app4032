/*
# Add read receipts, offer status, and message notification support

1. Modified tables
- messages: add `read_at` (timestamptz, nullable) — when the recipient opens the message. NULL = delivered but not read yet.
- offers: add `status` (text, default 'pending') — 'pending' (awaiting client acceptance) or 'accepted' (converted to conversation). Tracks whether the client has approved the muqeeb's offer.

2. New columns
- messages.read_at: nullable timestamp, set when recipient reads the message.
- offers.status: text, 'pending' or 'accepted'.

3. Security
- No policy changes — existing anon, authenticated policies on messages and offers already allow full CRUD.
- New columns inherit existing table-level RLS.

4. Important notes
- Idempotent: uses DO $$ ... IF NOT EXISTS ... END $$ to add columns only if absent.
- Non-destructive: no columns dropped or renamed, no type changes.
- Existing messages get read_at = NULL (delivered, not read).
- Existing offers get status = 'pending' by default.
*/

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'messages' AND column_name = 'read_at') THEN
    ALTER TABLE public.messages ADD COLUMN read_at timestamptz;
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'offers' AND column_name = 'status') THEN
    ALTER TABLE public.offers ADD COLUMN status text NOT NULL DEFAULT 'pending';
  END IF;
END $$;
