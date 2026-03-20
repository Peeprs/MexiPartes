-- 1. Create the bucket 'products'
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do nothing;

-- NOTE: We removed the 'ALTER TABLE' command causing the permissions error.
-- RLS is already enabled by default on Supabase Storage.

-- 2. Create Policy: Public Read Access
-- This allows anyone (with the link) to see the image.
create policy "Public Access Products"
on storage.objects for select
using ( bucket_id = 'products' );

-- 3. Create Policy: Authenticated Uploads
-- This allows any logged-in user to upload a file.
create policy "Authenticated Upload Products"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'products' );
