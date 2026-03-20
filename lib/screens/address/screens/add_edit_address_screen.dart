import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/api_services.dart';
import '../../../models/address_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNamePaternalController;
  late TextEditingController _lastNameMaternalController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _extNumController;
  late TextEditingController _intNumController;
  late TextEditingController _colonyController;
  late TextEditingController _phoneController;
  late TextEditingController _betweenStreetsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _lastNamePaternalController = TextEditingController(
      text: widget.address?.lastNamePaternal ?? '',
    );
    _lastNameMaternalController = TextEditingController(
      text: widget.address?.lastNameMaternal ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.address?.postalCode ?? '',
    );
    _extNumController = TextEditingController(
      text: widget.address?.extNum ?? '',
    );
    _intNumController = TextEditingController(
      text: widget.address?.intNum ?? '',
    );
    _colonyController = TextEditingController(
      text: widget.address?.colony ?? '',
    );
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _betweenStreetsController = TextEditingController(
      text: widget.address?.betweenStreets ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _extNumController.dispose();
    _intNumController.dispose();
    _colonyController.dispose();
    _phoneController.dispose();
    _betweenStreetsController.dispose();
    super.dispose();
  }

  final ApiService _apiService = ApiService();

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          throw 'No hay sesión de usuario activa';
        }

        // Genera un ID único si es una dirección nueva para la UI local,
        // pero la DB generará uno real si lo mandamos vacío.
        // El modelo Address usa String, así que si es nueva mandamos '' y ApiService lo remueve.
        final addressId = widget.address?.id ?? '';

        final newAddress = Address(
          id: addressId,
          name: _nameController.text.trim(),
          lastNamePaternal: _lastNamePaternalController.text.trim(),
          lastNameMaternal: _lastNameMaternalController.text.trim(),
          street: _streetController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          extNum: _extNumController.text.trim(),
          intNum: _intNumController.text.trim().isNotEmpty
              ? _intNumController.text.trim()
              : null,
          colony: _colonyController.text.trim(),
          phone: _phoneController.text.trim(),
          betweenStreets: _betweenStreetsController.text.trim().isNotEmpty
              ? _betweenStreetsController.text.trim()
              : null,
        );

        final success = await _apiService.saveAddress(newAddress, user.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dirección guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(newAddress);
        } else if (mounted) {
          throw 'Error al guardar en base de datos';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo guardar la dirección: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color ?? Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.address == null ? 'Nueva Dirección' : 'Editar Dirección',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _nameController,
                label: 'Nombres',
                hint: 'Ingresa tu nombre',
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _lastNamePaternalController,
                      label: 'Apellido Paterno',
                      hint: 'Paterno',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      controller: _lastNameMaternalController,
                      label: 'Apellido Materno',
                      hint: 'Materno',
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              _buildInputField(
                controller: _streetController,
                label: 'Dirección',
                hint: 'Calle y número',
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInputField(
                      controller: _postalCodeController,
                      label: 'C.P.',
                      hint: 'C.P.',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildInputField(
                      controller: _extNumController,
                      label: 'Num. Ext.',
                      hint: 'Exterior',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildInputField(
                      controller: _intNumController,
                      label: 'Num. Int.',
                      hint: 'Interior',
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              _buildInputField(
                controller: _colonyController,
                label: 'Colonia',
                hint: 'Ingresa tu colonia',
              ),
              _buildInputField(
                controller: _phoneController,
                label: 'Teléfono',
                hint: 'Ej. 5512345678',
                keyboardType: TextInputType.phone,
              ),
              _buildInputField(
                controller: _betweenStreetsController,
                label: 'Entre calle y calle',
                hint: '(Opcional)',
                isRequired: false,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveForm,
                // Default theme style (Red/White) will be used automatically
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Guardar Dirección',
                        // ...
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ), // Dynamic text color
            decoration: InputDecoration(
              hintText: hint,
              // Theme defaults will handle fillColor (0xFF1C1C1E) and borders
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
