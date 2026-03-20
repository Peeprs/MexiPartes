import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address_model.dart';

import '../models/usuario_model.dart';

import '../models/product_model.dart';
import '../models/order_model.dart'; // <--- NUEVO MODELO DE ORDEN

import '../models/cart_item_model.dart'; // <--- Importar CartItem

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ... (otros métodos) ...

  // ---------------------------------------------------------
  // 8. PEDIDOS (MOTOR DE VENTAS)
  // ---------------------------------------------------------
  Future<bool> createOrder(
    String userId,
    List<CartItem> cartItems,
    Address shippingAddress,
  ) async {
    try {
      // 0. Validar IDs para evitar error de UUID
      for (var item in cartItems) {
        if (item.id == '0' || item.id == '' || item.id == 'null') {
          throw Exception("Tu carrito contiene productos corruptos (IDs antiguos). Por favor, ve al carrito y elimínalos.");
        }
      }

      double calculatedTotal = 0.0;
      List<Map<String, dynamic>> orderItemsData = [];

      // 1 y 2. Validar precios reales y Decrementar Stock Atómicamente
      for (var item in cartItems) {
        // Consultar el precio real y existencia
        final productResponse = await _supabase
            .from('products')
            .select('precio')
            .eq('id', item.id)
            .maybeSingle();

        if (productResponse == null) {
          throw Exception("El producto '${item.name}' ya no existe en el catálogo.");
        }

        final realPrice = (productResponse['precio'] as num).toDouble();
        
        // Ejecutar decremento atómico de stock vía RPC
        final rowsAffected = await _supabase.rpc('decrement_stock', params: {
          'product_id': item.id,
          'quantity': item.quantity
        });

        if (rowsAffected == null || rowsAffected == 0) {
          throw Exception("Stock insuficiente o producto inexistente para '${item.name}'.");
        }

        calculatedTotal += (realPrice * item.quantity);

        orderItemsData.add({
          'product_id': item.id,
          'product_name': item.name,
          'price': realPrice, // USAR PRECIO REAL
          'quantity': item.quantity,
          'image_url': item.imageUrl ?? '',
          'seller_id': item.sellerId,
        });
      }

      final orderData = {
        'buyer_id': userId,
        'total': calculatedTotal, // TOTAL CALCULADO SEGÚN BD
        'status': 'processing',
        'items': orderItemsData,
        'shipping_address': shippingAddress.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Guardar Orden
      await _supabase.from('orders').insert(orderData);

      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error creating order');
      rethrow; // Relanzar para que la UI se entere
    }
  }

  // ---------------------------------------------------------
  // 8b. ACTUALIZAR ESTADO DE ORDEN (VENDEDOR)
  // ---------------------------------------------------------
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error updating order status');
      return false;
    }
  }

  // ---------------------------------------------------------
  Future<List<Address>> getAddresses(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId) // RLS también filtra, pero esto es explícito
          .order('created_at', ascending: false);
      return data.map((e) => Address.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error fetching addresses');
      return [];
    }
  }

  Future<bool> saveAddress(Address address, String userId) async {
    try {
      final data = address.toJson();
      data['user_id'] = userId;

      // Si el ID parece ser temporal (timestamp) o vacío, lo removemos para que la DB genere un UUID real.
      // Los ID de timestamp (millisecondsSinceEpoch) son numéricos y cortos (< 20 chars).
      // Los UUID son de 36 chars.
      if (address.id.isEmpty || address.id.length < 20) {
        data.remove('id');
      }

      await _supabase.from('addresses').upsert(data);
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error saving address');
      rethrow; // Relanzar para manejar en UI
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error deleting address');
      return false;
    }
  }

  // ---------------------------------------------------------
  // 1. LOGIN (Supabase Auth)
  // ---------------------------------------------------------
  Future<Usuario?> validateUsuario(String correo, String pwd) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: correo,
        password: pwd,
      );

      if (response.user != null) {
        // Fetch extra profile data from 'profiles' table
        var profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        // AUTOREPARACIÓN: Si no existe perfil pero sí Auth, intentamos crearlo
        // usando los metadatos guardados en auth.users
        if (profile == null) {
          final metadata = response.user!.userMetadata;
          final displayName = metadata?['display_name'] ?? 'Usuario';

          try {
            // Intentamos insertar el perfil faltante
            await _supabase.from('profiles').upsert({
              'id': response.user!.id,
              'email': response.user!.email,
              'display_name': displayName,
              'is_seller': false, // Por defecto false si recuperamos
            });

            // Volvemos a consultar
            profile = await _supabase
                .from('profiles')
                .select()
                .eq('id', response.user!.id)
                .maybeSingle();
          } catch (e) {
            FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Auto-repair profile failed');
          }
        }

        // Si aún así es nulo (falló reparación), usamos datos de Auth
        final metadata = response.user!.userMetadata;
        final nameFromMeta = metadata?['display_name'] as String?;

        return Usuario(
          id: response.user!.id,
          strCorreo: response.user!.email ?? '',
          // Prioridad: Profile DB > Auth Metadata > "Usuario"
          strNombre: profile?['display_name'] ?? nameFromMeta ?? 'Usuario',
          strApellidoPaterno: '',
          strFotoUrl: profile?['avatar_url'],
          bitCorreoVerificado: true,
          bitEsVendedor: profile?['is_seller'] ?? false,
        );
      }
      return null;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error Login');
      return null;
    }
  }

  // ---------------------------------------------------------
  // 3. REGISTRAR USUARIO (Supabase Auth)
  // ---------------------------------------------------------
  Future<Usuario?> createUsuario(Usuario usuario) async {
    try {
      // 1. Crear Auth User
      final response = await _supabase.auth.signUp(
        email: usuario.strCorreo,
        password: usuario.strPassword!,
        data: {
          'display_name': '${usuario.strNombre} ${usuario.strApellidoPaterno}',
        },
      );

      if (response.user != null) {
        // 2. Insertar en tabla custom 'profiles' si se requiere mas data
        // La tabla profiles deberia tener trigger on auth.users o insertarse manual
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'email': usuario.strCorreo,
          'display_name': '${usuario.strNombre} ${usuario.strApellidoPaterno}',
          'is_seller': usuario.bitEsVendedor,
          'avatar_url': usuario.strFotoUrl, // <--- Guardar URL
        });

        // Retornamos el usuario con el ID real asignado por Supabase
        return Usuario(
          id: response.user!.id,
          strNombre: usuario.strNombre,
          strApellidoPaterno: usuario.strApellidoPaterno,
          strCorreo: usuario.strCorreo,
          bitEsVendedor: usuario.bitEsVendedor,
          strFotoUrl: usuario.strFotoUrl,
          bitCorreoVerificado:
              true, // Supabase por defecto requiere confirmación pero asumimos ok por ahora
        );
      }
      return null;
    } on AuthException catch (e) {
      // Manejar error especifico (ej: usuario ya existe)
      throw e.message;
    } catch (e) {
      throw 'Error al crear usuario: $e';
    }
  }

  // ---------------------------------------------------------
  // 4. STORAGE (IMÁGENES)
  // ---------------------------------------------------------
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error uploading image');
      return null;
    }
  }

  Future<String> uploadProductImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      try {
        await _supabase.storage
            .from('products')
            .upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
      } on StorageException catch (e) {
        if (e.message.contains('Bucket not found') || e.statusCode == '404') {
          // Intentar crear el bucket si no existe
          try {
            await _supabase.storage.createBucket(
              'products',
              const BucketOptions(public: true),
            );
            // Reintentar subida
            await _supabase.storage
                .from('products')
                .upload(
                  fileName,
                  imageFile,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );
          } catch (createError) {
            // Si falla la creación automática (403 Forbidden es común si no eres admin)
            throw "Error automatizado: No se pudo crear el bucket 'products'.\n"
                "Por favor, ve a Supabase > SQL Editor y ejecuta el script 'sql/storage_setup.sql' que he creado en tu proyecto.\n"
                "Detalle: $createError";
          }
        } else {
          rethrow;
        }
      }

      final imageUrl = _supabase.storage
          .from('products')
          .getPublicUrl(fileName);
      return imageUrl;
    } on StorageException catch (e) {
      // Capturar errores específicos de Supabase Storage (Permisos, Bucket no existe, etc.)
      throw "Error de Servidor (Storage): ${e.message}";
    } catch (e) {
      throw "Error subiendo imagen: $e";
    }
  }

  // ---------------------------------------------------------
  // CONSULTAS GENÉRICAS
  // ---------------------------------------------------------
  Future<Usuario?> getUsuarioById(String id) async {
    try {
      var data = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      // AUTOREPARACIÓN (Similar a Login): Si no hay perfil, intentamos recuperarlo
      if (data == null) {
        try {
          final user = _supabase.auth.currentUser;
          if (user != null && user.id == id) {
            final metadata = user.userMetadata;
            final displayName = metadata?['display_name'] ?? 'Usuario';

            await _supabase.from('profiles').upsert({
              'id': id,
              'email': user.email,
              'display_name': displayName,
              'is_seller': false,
            });

            data = await _supabase
                .from('profiles')
                .select()
                .eq('id', id)
                .maybeSingle();
          }
        } catch (e) {
          FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Auto-repair in getUsuarioById failed');
        }
      }

      if (data != null) {
        return Usuario(
          id: data['id'],
          strNombre: data['display_name'] ?? '',
          strCorreo: data['email'] ?? '',
          strApellidoPaterno: '', // Supabase profile simple
          strFotoUrl: data['avatar_url'], // <--- Mapear
          bitEsVendedor: data['is_seller'] ?? false,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------
  // 6. PRODUCTOS (CATÁLOGO DINÁMICO)
  // ---------------------------------------------------------
  Future<List<Product>> getProducts({bool includeHidden = false}) async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .order('id', ascending: false) // Mostrar más recientes primero
          .limit(20); // <-- OPTIMIZACIÓN: Solo traer los últimos 20 productos

      final List<Product> products = data
          .map((e) => Product.fromJson(e))
          .toList();

      if (includeHidden) return products; // El vendedor ve todo

      // FILTRO DE NEGOCIO:
      // Si stock es 0 Y pasaron más de 5 minutos desde la última actualización,
      // el producto se considera "baja del catálogo" y no se muestra.
      final now = DateTime.now();
      return products.where((p) {
        if (p.stock > 0) return true; // Mostrar si hay stock

        // Si stock es 0, verificar tiempo
        final diff = now.difference(p.updatedAt).inMinutes;
        if (diff >= 5) {
          return false; // Ocultar después de 5 min
        }
        return true; // Mostrar como 'Agotado' dentro de los 5 min
      }).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error fetching products');
      return [];
    }
  }

  /// Elimina físicamente los productos de prueba de la BD
  Future<void> cleanupTestProducts() async {
    try {
      await _supabase
          .from('products')
          .delete()
          .or(
            'imagen_url.ilike.%via.placeholder%,imagen_url.ilike.%google.com%',
          );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error cleaning test products');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .ilike('nombre', '%$query%'); // Búsqueda insensible a mayúsculas
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error searching products');
      return [];
    }
  }

  Future<List<Product>> getProductsByVehicle(String vehicleModel) async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .ilike('descripcion', '%$vehicleModel%'); // Simple ilike fallback
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error filtering products');
      return [];
    }
  }

  Future<String?> createProduct(Product product, String userId) async {
    try {
      final productData = {
        'nombre': product.nombre,
        'descripcion': product.descripcion,
        'precio': product.precio,
        'imagen_url': product.imagenUrl,
        'categoria': product.categoria,
        'stock': product.stock,
        'seller_id': userId,
      };
      await _supabase.from('products').insert(productData);
      return null; // Success
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error creating product');
      return e.toString(); // Return error message
    }
  }

  Future<bool> updateProductStock(String productId, int newStock) async {
    try {
      await _supabase
          .from('products')
          .update({'stock': newStock})
          .eq('id', productId);
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error updating stock with timestamp. Retrying...');
      try {
        // Fallback: Intentar solo stock si no existe columna updated_at
        await _supabase
            .from('products')
            .update({'stock': newStock})
            .eq('id', productId);
        return true;
      } catch (e2) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error updating stock critical2');
        return false;
      }
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error deleting product');
      return false;
    }
  }

  Future<List<Usuario>> getUsuarios() async {
    try {
      final List<dynamic> data = await _supabase.from('profiles').select();
      return data
          .map(
            (e) => Usuario(
              id: e['id'],
              strNombre: e['display_name'] ?? '',
              strCorreo: e['email'] ?? '',
              strApellidoPaterno: '',
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------------------
  // MÉTODOS DE SOPORTE PARA AUTH PROVIDER
  // ---------------------------------------------------------

  Future<bool> checkUsuarioExists({required String correo}) async {
    // Supabase no expone "checkUserExists" directamente por seguridad.
    // Intentamos buscar en la tabla 'profiles' (publica)
    try {
      final data = await _supabase
          .from('profiles')
          .select('email')
          .eq('email', correo)
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  Future<Usuario?> updateUsuario(Usuario usuario) async {
    try {
      // Actualizamos solo los datos del perfil
      await _supabase
          .from('profiles')
          .update({
            'display_name':
                '${usuario.strNombre} ${usuario.strApellidoPaterno}',
            'is_seller': usuario.bitEsVendedor,
            'avatar_url': usuario.strFotoUrl, // <--- Actualizar URL
          })
          .eq('id', usuario.id);

      return usuario;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error update');
      return null;
    }
  }

  Future<bool> deleteAccount(String userId, String password) async {
    try {
      await _supabase.rpc('delete_user');

      // 3. Cerrar sesión localmente
      await _supabase.auth.signOut();

      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error deleting account');
      try {
        await _supabase.from('profiles').delete().eq('id', userId);
        return true; // "Falso positivo" parcial, pero limpia datos públicos
      } catch (e2) {
        return false;
      }
    }
  }

  Future<bool> deleteUsuario(String id) async => true; // Deprecated
  Future<bool> recoverPassword(String email, String newPassword) async {
    await _supabase.auth.resetPasswordForEmail(email);
    return true;
  }

  // ---------------------------------------------------------
  // 8. PEDIDOS (MOTOR DE VENTAS)
  // ---------------------------------------------------------
  Future<List<OrderModel>> getMyOrders(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('orders')
          .select()
          .eq('buyer_id', userId)
          .order('created_at', ascending: false);

      return data.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error fetching orders');
      return [];
    }
  }

  Future<List<OrderModel>> getMySales(String sellerId) async {
    // Esta función es compleja porque los items están en JSONB.
    // Por ahora, traemos TODAS las órdenes y filtramos en memoria (no es ideal para prod masiva, pero ok para MVP).
    // OJO: Requiere RLS permisivo 'select *' o política especial.
    try {
      // Nota: Esto solo funciona si el usuario tiene permiso de ver orders globales O
      // si ajustamos la RLS. Por ahora asumo que RLS permite lectura.
      final List<dynamic> data = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final allOrders = data.map((e) => OrderModel.fromJson(e)).toList();

      // Filtrar Orders que contengan AL MENOS UN producto mío
      // (Esta lógica debería ir en backend RPC idealmente)
      /*
      return allOrders.where((order) {
        return order.items.any((item) => item.sellerId == sellerId);
      }).toList();
      */
      // TEMPORAL: Retorna todo para pruebas
      return allOrders;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error fetching sales');
      return [];
    }
  }

  // ---------------------------------------------------------
  // 9. HOME SCREEN QUERIES
  // ---------------------------------------------------------
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .gt('stock', 0)
          .order('created_at', ascending: false)
          .limit(10);
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'getFeaturedProducts');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .eq('categoria', category)
          .gt('stock', 0)
          .limit(10);
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'getProductsByCategory');
      return [];
    }
  }

  Future<List<Product>> getCheapestProducts() async {
    try {
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .gt('stock', 0)
          .order('precio', ascending: true)
          .limit(10);
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'getCheapestProducts');
      return [];
    }
  }

  Future<List<Product>> getBestSellers() async {
    try {
      // 1. Obtener los IDs más vendidos
      // Enviamos 'limit_val' o ningún parámetro si es que la función espera uno específico, probaremos con "limit"
      final List<dynamic> rpcData = await _supabase.rpc('get_best_sellers', params: {'limit_count': 10});
      
      if (rpcData.isEmpty) return [];

      final List<String> bestSellerIds = rpcData.map((e) => e['product_id'].toString()).toList();

      if (bestSellerIds.isEmpty) return [];

      // 2. Traer los productos completos con esos IDs y stock > 0
      final List<dynamic> data = await _supabase
          .from('products')
          .select()
          .inFilter('id', bestSellerIds)
          .gt('stock', 0);

      final List<Product> products = data.map((e) => Product.fromJson(e)).toList();
      
      // Mantener el orden del RPC
      products.sort((a, b) {
        final iA = bestSellerIds.indexOf(a.id.toString());
        final iB = bestSellerIds.indexOf(b.id.toString());
        return iA.compareTo(iB);
      });
      
      return products;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'getBestSellers');
      return [];
    }
  }
}
