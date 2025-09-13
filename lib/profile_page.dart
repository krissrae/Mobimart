import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _contact = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final user = SupabaseManager.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await SupabaseManager.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (response != null) {
          setState(() {
            _name = response['name'] as String? ?? '';
            _address = response['address'] as String? ?? '';
            _contact = response['contact'] as String? ?? '';
          });
        } else {
          setState(() {
            _name = '';
            _address = '';
            _contact = '';
          });
        }
      } catch (e) {
        setState(() {
          _name = '';
          _address = '';
          _contact = '';
        });
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    final user = SupabaseManager.client.auth.currentUser;
    if (user != null) {
      await SupabaseManager.client.from('profiles').upsert({
        'id': user.id,
        'name': _name,
        'address': _address,
        'contact': _contact,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      await _loadProfile();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSaved: (v) => _name = v ?? '',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      initialValue: _address,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                      ),
                      onSaved: (v) => _address = v ?? '',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter address' : null,
                    ),
                    TextFormField(
                      initialValue: _contact,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                      ),
                      onSaved: (v) => _contact = v ?? '',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter contact' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
