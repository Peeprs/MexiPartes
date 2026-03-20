-- Script para eliminar productos de prueba
-- Ejecuta este código en Supabase > SQL Editor

-- Eliminar productos que contengan estos nombres:
DELETE FROM products 
WHERE 
  nombre ILIKE '%aceite%' OR
  nombre ILIKE '%sintetico%' OR
  nombre ILIKE '%sintético%' OR
  nombre ILIKE '%bujia%' OR
  nombre ILIKE '%bujía%' OR
  nombre ILIKE '%freno%' OR
  nombre ILIKE '%bateria%' OR
  nombre ILIKE '%batería%' OR
  nombre ILIKE '%llanta%' OR
  nombre ILIKE '%faro%' OR
  nombre ILIKE '%radiador%' OR
  nombre ILIKE '%suspensión%' OR
  nombre ILIKE '%retrovisor%' OR
  nombre ILIKE '%filtro%';

-- Ver cuántos productos quedan
SELECT COUNT(*) as productos_restantes FROM products;

-- Ver los productos restantes
SELECT id, nombre, stock, precio FROM products ORDER BY created_at DESC;
