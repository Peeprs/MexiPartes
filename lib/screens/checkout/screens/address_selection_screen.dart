import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/api_services.dart';
import '../../../models/address_model.dart';
import '../../../models/cart_item_model.dart';
import '../../address/screens/add_edit_address_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<Address> _addresses = [];
  String? _selectedAddressId;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Ya no usamos SharedPreferences, leemos de Supabase
    final addresses = await _apiService.getAddresses(userId);

    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
    );
    // Si regresa algo (objeto Address), significa que guardó con éxito
    if (result != null) {
      _loadAddresses(); // Recargamos la lista desde la BD
    }
  }

  Address? _getSelectedAddress() {
    if (_selectedAddressId == null) return null;
    // Encuentra la dirección completa en la lista usando el ID seleccionado.
    return _addresses.firstWhere((addr) => addr.id == _selectedAddressId);
  }

  @override
  Widget build(BuildContext context) {
    // Los argumentos se reciben aquí para que el botón inferior pueda usarlos.
    final cartItems =
        ModalRoute.of(context)!.settings.arguments as List<CartItem>;
    final selectedAddress = _getSelectedAddress();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Seleccionar Dirección',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _selectedAddressId != null
              ? () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/processing',
                    arguments: {
                      'cartItems': cartItems,
                      'selectedAddress': selectedAddress,
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey[800],
            disabledForegroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Completar Pago',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No tienes direcciones guardadas',
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _navigateToAddAddress,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Agregar una Dirección',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        final isSelected = _selectedAddressId == address.id;
        return Card(
          color: isSelected ? const Color(0xFF2C2C2E) : Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            onTap: () => setState(() => _selectedAddressId = address.id),
            leading: const Icon(Icons.home_outlined, color: Colors.white),
            title: Text(
              '${address.name} ${address.lastNamePaternal}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${address.street}, ${address.colony}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                : null,
          ),
        );
      },
    );
  }
}
