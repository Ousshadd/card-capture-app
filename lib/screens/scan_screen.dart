import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers dyal l-fields standard d'les cartes visites
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _webController = TextEditingController();

  // --- Logic dyal l-Permissions o Selection ---
  Future<void> _handleImageSelection(ImageSource source) async {
    PermissionStatus status;

    // 1. Check Permissions 3la hsab l-source
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // Gallery permission (khtalef 3la hsab version d'Android m-ghattiha l-plugin)
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    // 2. Illa l-user 3ta l-Permission, n-hll l-Picker
    if (status.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        // Hna sadiqi dyalk ghadi y-zid l-appel d'l-OCR bach y-3emmar had les fields
      }
    } else if (status.isPermanentlyDenied) {
      // Illa dār "Don't ask again", khass y-mchi l-Settings
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Please enable camera/gallery access in settings to scan cards."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => openAppSettings(), child: const Text("Settings")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Scan Visiting Card"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. Selection Box (Dima bayna l-user) ---
            _buildSelectionBox(),
            
            const SizedBox(height: 25),

            // --- 2. Preview o Form (Conditional Rendering) ---
            if (_selectedImage != null) ...[
              _buildImagePreview(),
              const SizedBox(height: 25),
              _buildExtendedForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Icon(Icons.badge_outlined, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 10),
          const Text("Select a visiting card to scan", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.camera_alt, "Camera", () => _handleImageSelection(ImageSource.camera)),
              _buildActionButton(Icons.photo_library, "Gallery", () => _handleImageSelection(ImageSource.gallery)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildExtendedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Card Details", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueGrey)),
        const SizedBox(height: 15),
        _buildTextField(_nameController, "Name", Icons.person),
        _buildTextField(_designationController, "Designation", Icons.work_outline),
        _buildTextField(_companyController, "Company", Icons.business),
        _buildTextField(_phoneController, "Phone Number", Icons.phone),
        _buildTextField(_emailController, "Email Address", Icons.email),
        _buildTextField(_webController, "Website", Icons.language),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              // Hna ghadi n-zido SQLite logic mn b3d
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("SAVE CARD", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}