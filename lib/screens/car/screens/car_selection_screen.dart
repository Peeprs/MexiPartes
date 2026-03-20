import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/car_provider.dart';

class CarSelectionScreen extends StatefulWidget {
  const CarSelectionScreen({super.key});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  String? selectedBrand;
  String? selectedModel;
  String? selectedYear;
  final TextEditingController versionController = TextEditingController();

  final List<String> brands = [
    'Toyota',
    'Honda',
    'Nissan',
    'Ford',
    'Chevrolet',
    'Volkswagen',
  ];
  final Map<String, List<String>> models = {
    'Toyota': ['Corolla', 'Camry', 'RAV4', 'Highlander'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot'],
    'Nissan': ['Sentra', 'Altima', 'Rogue', 'Pathfinder'],
    'Ford': ['Focus', 'Fusion', 'Escape', 'Explorer'],
    'Chevrolet': ['Cruze', 'Malibu', 'Equinox', 'Traverse'],
    'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas'],
  };
  final List<String> years = List.generate(
    10,
    (index) => (DateTime.now().year - index).toString(),
  );

  @override
  void dispose() {
    versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).iconTheme.color ?? Theme.of(context).textTheme.bodyLarge?.color),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // --- ICONO / LOGO ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- TÍTULO ---
                Text(
                  'Configura tu vehículo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Filtraremos las refacciones para asegurarnos de que sean compatibles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                ),
                const SizedBox(height: 50),

                // --- SELECTORES ---
                _buildCustomDropdown(
                  value: selectedBrand,
                  items: brands,
                  hint: 'Selecciona la Marca',
                  icon: Icons.branding_watermark,
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value;
                      selectedModel = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildCustomDropdown(
                  value: selectedModel,
                  items: selectedBrand != null
                      ? models[selectedBrand] ?? []
                      : [],
                  hint: 'Selecciona el Modelo',
                  icon: Icons.car_repair,
                  enabled: selectedBrand != null,
                  onChanged: (value) {
                    setState(() {
                      selectedModel = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildCustomDropdown(
                  value: selectedYear,
                  items: years,
                  hint: 'Año del Modelo',
                  icon: Icons.calendar_today,
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                ),
                const SizedBox(height: 60),

                // --- BOTÓN CONTINUAR ---
                ElevatedButton(
                  onPressed: () {
                    if (selectedBrand != null &&
                        selectedModel != null &&
                        selectedYear != null) {
                      Provider.of<CarProvider>(
                        context,
                        listen: false,
                      ).setCar(selectedBrand!, selectedModel!, selectedYear!);
                      Navigator.pushReplacementNamed(context, '/main');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Completa todos los campos'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.red,
                    shadowColor: Colors.redAccent.withValues(alpha: 0.5),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'GUARDAR Y CONTINUAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE MODERNIZADO ---
  Widget _buildCustomDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).disabledColor,
          ),
          dropdownColor: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          hint: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? Theme.of(context).iconTheme.color : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 12),
              Text(
                hint,
                style: TextStyle(
                  color: enabled ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).disabledColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
        ),
      ),
    );
  }
}
