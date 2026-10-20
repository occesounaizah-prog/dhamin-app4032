/*
# Add archived column to conversations

1. Modified tables
- conversations: add `archived` (boolean, default false) — when true, the conversation is moved to archive and hidden from the active conversations list.

2. Security
- No policy changes — existing RLS on conversations already allows full CRUD. New column inherits table-level RLS.

3. Important notes
- Idempotent: uses DO $$ ... IF NOT EXISTS ... END $$.
- Non-destructive: no columns dropped or renamed.
- Existing conversations get archived = false (active).
*/

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'conversations' AND column_name = 'archived') THEN
    ALTER TABLE public.conversations ADD COLUMN archived boolean NOT NULL DEFAULT false;
  END IF;
END $$;
