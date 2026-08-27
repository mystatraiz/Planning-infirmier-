-- Relève : stockage du planning partagé.
-- À exécuter une fois dans le SQL Editor de votre projet Supabase.

create table if not exists public.planning (
  id text primary key,
  rev bigint not null default 0,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.planning enable row level security;

-- Toute personne disposant du lien du site peut lire et modifier le planning
-- (même modèle de confiance qu'un tableur partagé par lien).
create policy "lecture publique" on public.planning
  for select using (true);
create policy "creation publique" on public.planning
  for insert with check (true);
create policy "mise a jour publique" on public.planning
  for update using (true);
