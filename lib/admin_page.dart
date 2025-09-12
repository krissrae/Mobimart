import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobimart/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_pages.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  XFile? _imageFile;
  Uint8List? _imageBytes;

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  /// Upload product to Supabase
  Future<void> _addProduct() async {
    final name = nameController.text.trim();
    final price = priceController.text.trim();

    if (name.isEmpty || price.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields & select an image')));
      return;
    }

    try {
      // Determine extension and content type
      String extension = _imageFile!.name.split('.').last.toLowerCase();
      String imageName = '${DateTime.now().millisecondsSinceEpoch}_$name.$extension';
      String? contentType;
      if (extension == 'png') contentType = 'image/png';
      else if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';

      // Upload to Supabase storage
      await SupabaseManager.client.storage
          .from('pictures')
          .uploadBinary(imageName, _imageBytes!, fileOptions: FileOptions(contentType: contentType));

      final imageUrl = SupabaseManager.client.storage
          .from('pictures')
          .getPublicUrl(imageName);

      // Insert product into database
      await SupabaseManager.client.from('product').insert({
        'name': name,
        'price': double.tryParse(price),
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product "$name" added!')));

      // Clear fields
      nameController.clear();
      priceController.clear();
      setState(() {
        _imageFile = null;
        _imageBytes = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _signOut() async {
    await SupabaseManager.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (XAF)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 120)
                : const SizedBox(
              height: 120,
              child: Center(child: Text('No image selected')),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
              child: const Text('Select Product Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
