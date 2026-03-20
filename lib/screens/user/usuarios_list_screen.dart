import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../services/api_services.dart';
import 'user_crud_screen.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final _api = ApiService();
  late Future<List<Usuario>> _future;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  void _cargarUsuarios() {
    setState(() {
      _future = _api.getUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Usuarios', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarUsuarios,
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 10),
                  const Text(
                    'Error cargando usuarios',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _cargarUsuarios,
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                'Sin usuarios registrados',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _cargarUsuarios(),
            color: Colors.red,
            backgroundColor: Colors.black,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final u = usuarios[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    child: Text(
                      (u.strNombre.isNotEmpty ? u.strNombre[0] : '?')
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${u.strNombre} ${u.strApellidoPaterno}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    u.strCorreo,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UsuarioCrudScreen(usuario: u),
                            ),
                          ).then((_) => _cargarUsuarios());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, u),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsuarioCrudScreen()),
          ).then((_) => _cargarUsuarios());
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt_1, color: Colors.black),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Usuario u) async {
    final messenger = ScaffoldMessenger.of(context); // Capturar referencia segura
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Eliminar usuario',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de eliminar a ${u.strNombre}?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Mostrar loading simple si deseas, o simplemente llamar a la API
      final ok = await _api.deleteUsuario(u.id);
      
      if (!mounted) return;

      if (ok) {
        _cargarUsuarios();
        messenger.showSnackBar(
          const SnackBar(content: Text('Usuario eliminado correctamente'), backgroundColor: Colors.green),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el usuario'), backgroundColor: Colors.red),
        );
      }
    }
  }
}