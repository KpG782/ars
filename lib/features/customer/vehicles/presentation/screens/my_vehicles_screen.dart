import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

// A simple data model for a vehicle
class Vehicle {
  final String licensePlate;
  final String manufacturer;
  final String model;
  final String modelYear;
  final String color;
  final String fuelType;
  final bool isFirstOwner;

  Vehicle({
    required this.licensePlate,
    required this.manufacturer,
    required this.model,
    required this.modelYear,
    required this.color,
    required this.fuelType,
    required this.isFirstOwner,
  });
}

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // List to hold the vehicles
  final List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to add a new vehicle to the list
  void _addVehicle(Vehicle vehicle) {
    setState(() {
      _vehicles.add(vehicle);
    });
  }

  // Method to update an existing vehicle
  void _updateVehicle(int index, Vehicle vehicle) {
    setState(() {
      _vehicles[index] = vehicle;
    });
  }

  // Method to delete a vehicle
  void _deleteVehicle(int index) {
    setState(() {
      _vehicles.removeAt(index);
    });
  }

  // Method to show the form dialog for adding a new vehicle
  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: _VehicleForm(
              onSave: (vehicle) {
                _addVehicle(vehicle);
              },
            ),
          ),
        );
      },
    );
  }

  // Method to show the form dialog for editing an existing vehicle
  void _showEditVehicleDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: _VehicleForm(
              initialVehicle: _vehicles[index],
              onSave: (vehicle) {
                _updateVehicle(index, vehicle);
              },
            ),
          ),
        );
      },
    );
  }

  // Method to show the delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Confirmation',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Do you really want to delete ${_vehicles[index].licensePlate.toUpperCase()}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize16,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _deleteVehicle(index);
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emergencyColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor, // Teal color
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.chevron_left, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Vehicles',
          style: AppTheme.figtreeBold.copyWith(color: AppTheme.onSurfaceColor),
        ),
        centerTitle: true,
      ),
      // If the list is empty, show the initial screen, otherwise show the list
      body: _vehicles.isEmpty ? _buildEmptyState() : _buildVehicleList(),
      floatingActionButton: _vehicles.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddVehicleDialog(context),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(LucideIcons.plus, color: Colors.white),
            ),
    );
  }

  // Widget for the initial "No vehicles" view
  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  LucideIcons.car,
                  size: 100,
                  color: AppTheme.onSurfaceColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No vehicles added yet',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please add your vehicle to get started!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    color: AppTheme.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _showAddVehicleDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  icon: const Icon(LucideIcons.circle_plus, size: 24),
                  label: const Text(
                    'Add Vehicle',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize18,
                      fontWeight: FontWeight.bold,
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

  // Widget to display the list of added vehicles
  Widget _buildVehicleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        return _VehicleCard(
          vehicle: _vehicles[index],
          onEdit: () => _showEditVehicleDialog(context, index),
          onDelete: () => _showDeleteConfirmationDialog(context, index),
        );
      },
    );
  }
}

// Card widget to display a single vehicle's information
class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Placeholder for the car logo
            Image.network(
              'https://cdn.icon-icons.com/icons2/1381/PNG/512/toyotalogo_93713.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(LucideIcons.car, size: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.manufacturer.toUpperCase()} ${vehicle.model.toUpperCase()} ${vehicle.modelYear}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSize16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.fuelType} | ${vehicle.licensePlate.toUpperCase()}',
                    style: const TextStyle(color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                _buildActionButton(
                  icon: LucideIcons.pencil,
                  label: 'Edit',
                  color: AppTheme.primaryColor,
                  onPressed: onEdit,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: LucideIcons.trash_2,
                  label: 'Delete',
                  color: AppTheme.emergencyColor,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 28,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

// A stateful widget for the form inside the dialog, handles both add and edit
class _VehicleForm extends StatefulWidget {
  final Function(Vehicle) onSave;
  final Vehicle? initialVehicle;

  const _VehicleForm({required this.onSave, this.initialVehicle});

  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<_VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();

  late int _fuelTypeIndex;
  late int _ownerTypeIndex;

  final List<String> _fuelTypes = ['Gas', 'Diesel', 'LPG'];

  // Check if we are editing an existing vehicle
  bool get isEditing => widget.initialVehicle != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Pre-fill form fields if editing
      final vehicle = widget.initialVehicle!;
      _plateController.text = vehicle.licensePlate;
      _manufacturerController.text = vehicle.manufacturer;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.modelYear;
      _colorController.text = vehicle.color;
      _fuelTypeIndex = _fuelTypes.indexOf(vehicle.fuelType);
      _ownerTypeIndex = vehicle.isFirstOwner ? 0 : 1;
    } else {
      // Default values for new vehicle
      _fuelTypeIndex = 1;
      _ownerTypeIndex = 0;
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // For simplicity, we are not adding form validation yet.
    final vehicleData = Vehicle(
      licensePlate: _plateController.text,
      manufacturer: _manufacturerController.text,
      model: _modelController.text,
      modelYear: _yearController.text,
      color: _colorController.text,
      fuelType: _fuelTypes[_fuelTypeIndex],
      isFirstOwner: _ownerTypeIndex == 0,
    );
    widget.onSave(vehicleData);
    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important for Dialog sizing
              children: [
                Text(
                  isEditing ? 'Update Details' : 'Add Vehicle',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing
                      ? 'Edit the details as necessary.'
                      : 'Input your car information',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize16,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _plateController,
                  label: 'License Plate Number:',
                  hint: 'e.g., NBC1234',
                ),
                _buildTextField(
                  controller: _manufacturerController,
                  label: 'Car Manufacturer:',
                  hint: 'e.g., Toyota',
                ),
                _buildTextField(
                  controller: _modelController,
                  label: 'Car Model:',
                  hint: 'e.g., Avanza',
                ),
                _buildTextField(
                  controller: _yearController,
                  label: 'Model Year:',
                  hint: 'e.g., 2021',
                ),
                _buildTextField(
                  controller: _colorController,
                  label: 'Color:',
                  hint: 'e.g., Black',
                ),
                _buildChoiceChip(
                  label: 'Fuel Type:',
                  choices: _fuelTypes,
                  selectedIndex: _fuelTypeIndex,
                  onSelected: (index) {
                    setState(() => _fuelTypeIndex = index);
                  },
                ),
                _buildChoiceChip(
                  label: "Vehicle's first owner Type:",
                  choices: ['Yes', 'No'],
                  selectedIndex: _ownerTypeIndex,
                  onSelected: (index) {
                    setState(() => _ownerTypeIndex = index);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.onPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Vehicle' : 'Save Vehicle',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSize14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.primaryColor.withAlpha(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required List<String> choices,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSize14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(choices.length, (index) {
              return ChoiceChip(
                label: Text(choices[index]),
                selected: selectedIndex == index,
                onSelected: (selected) {
                  if (selected) {
                    onSelected(index);
                  }
                },
                backgroundColor: AppTheme.primaryColor.withAlpha(10),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: selectedIndex == index ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
