import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_services.dart';

class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends State<PublishProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Drivers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();

  // State
  String _selectedCategory = 'Motor';
  bool _isLoading = false;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Motor',
    'Frenos',
    'Suspensión',
    'Eléctrico',
    'Interiores',
    'Carrocería',
    'Accesorios',
    'Fluidos',
    'Llantas',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality:
            70, // Compresión al 70% (mantiene buena calidad pero baja mucho el peso)
        maxWidth: 1024, // Redimensionar a max 1024px de ancho
      );
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _imageController.clear(); // Limpiar URL si se selecciona local
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitProduct() async {
    // Validar: O tiene texto en URL O tiene archivo seleccionado
    if (_imageController.text.isEmpty && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar una imagen (URL o subir archivo).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.usuarioActual;

    if (user == null) return;

    // VALIDACIÓN CRÍTICA:
    // Si el usuario tiene ID "0", es una sesión corrupta de la versión anterior.
    if (user.id == '0' || user.id == '0' || user.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu sesión necesita actualizarse. Por favor, cierra sesión e ingresa de nuevo.',
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      // Opcional: Forzar cierre de sesión aquí
      // authProvider.logout();
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageController.text.trim();

      // 1. SUBIR IMAGEN LOCAL SI EXISTE
      if (_selectedImageFile != null) {
        // Ahora el método lanza excepción si falla, no retorna null.
        final uploadedUrl = await _apiService.uploadProductImage(
          _selectedImageFile!,
        );
        finalImageUrl = uploadedUrl;
      }

      final product = Product(
        id: '', // DB Generated
        nombre: _nameController.text.trim(),
        descripcion: _descController.text.trim(),
        precio: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        imagenUrl: finalImageUrl,
        categoria: _selectedCategory,
        updatedAt: DateTime.now(),
        // sellerId se maneja en el servicio o DB
      );

      final error = await _apiService.createProduct(product, user.id);

      if (!mounted) return;

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto publicado con éxito')),
        );
        Navigator.pop(context);
      } else {
        throw error;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema oscuro consistente
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Publicar Producto'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos del Producto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Nombre
              _buildLabel('Título de la publicación'),
              _buildTextField(
                controller: _nameController,
                hint: 'Ej. Balatas Cerámicas Aveo 2018',
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),

              // Descripción
              _buildLabel('Descripción detallada'),
              _buildTextField(
                controller: _descController,
                hint: 'Describe el estado, marca y compatibilidad...',
                icon: Icons.description,
                lines: 3,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),

              Row(
                children: [
                  // Precio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Precio (MXN)'),
                        _buildTextField(
                          controller: _priceController,
                          hint: '0.00',
                          icon: Icons.attach_money,
                          inputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            if (double.tryParse(v) == null) return 'Inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Stock
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Stock (Unidades)'),
                        _buildTextField(
                          controller: _stockController,
                          hint: '1',
                          icon: Icons.inventory_2,
                          inputType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            if (int.tryParse(v) == null) return 'Inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Categoría
              _buildLabel('Categoría'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.grey[900],
                    value: _selectedCategory,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECCIÓN DE IMAGEN (Local o URL)
              const SizedBox(height: 10),
              _buildLabel('Imagen del Producto'),

              // 1. Botones para subir imagen local
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Cámara"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galería"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 2. Campo de URL (Opcional si subió foto)
              if (_selectedImageFile == null)
                _buildTextField(
                  controller: _imageController,
                  hint: 'O pega una URL aquí...',
                  icon: Icons.link,
                  lines: 1,
                  onChanged: (_) => setState(() {
                    _selectedImageFile = null; // Prioridad a URL si escribe
                  }),
                ),

              // 3. PREVIEW
              if (_selectedImageFile != null ||
                  _imageController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                    image: _selectedImageFile != null
                        ? DecorationImage(
                            image: FileImage(_selectedImageFile!),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: NetworkImage(_imageController.text),
                            fit: BoxFit.cover,
                            onError: (_, _) {},
                          ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedImageFile = null;
                                _imageController.clear();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Botón Publicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'PUBLICAR AHORA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int lines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ), // <--- Espaciado interno
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
