-- Create addresses table
create table if not exists public.addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  last_name_paternal text not null,
  last_name_maternal text,
  street text not null,
  postal_code text not null,
  ext_num text not null,
  int_num text,
  colony text not null,
  phone text not null,
  between_streets text,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.addresses enable row level security;

-- Policies
create policy "Users can view their own addresses"
on public.addresses for select
to authenticated
using ( auth.uid() = user_id );

create policy "Users can insert their own addresses"
on public.addresses for insert
to authenticated
with check ( auth.uid() = user_id );

create policy "Users can update their own addresses"
on public.addresses for update
to authenticated
using ( auth.uid() = user_id );

create policy "Users can delete their own addresses"
on public.addresses for delete
to authenticated
using ( auth.uid() = user_id );
