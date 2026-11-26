-- Conferes: tabela de sincronização (rodar uma vez no SQL Editor do Supabase)
create table if not exists public.conferes (
  user_id    uuid        not null default auth.uid() references auth.users on delete cascade,
  k          text        not null,              -- 'AAAA-MM-DD' (um dia) ou '_ult' (datas dos conversores)
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, k)
);

alter table public.conferes enable row level security;

drop policy if exists "conferes: só o dono" on public.conferes;
create policy "conferes: só o dono" on public.conferes
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- tempo real (o que muda no PC aparece no tablet na hora)
do $$ begin
  alter publication supabase_realtime add table public.conferes;
exception when duplicate_object then null; end $$;
