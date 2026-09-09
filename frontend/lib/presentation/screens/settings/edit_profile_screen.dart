import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarUrlController;
  String? _selectedGender;
  DateTime? _selectedBirthday;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _avatarUrlController = TextEditingController(text: user?.avatarUrl ?? '');
    _selectedGender = user?.gender;
    if (user?.birthday != null) {
      _selectedBirthday = DateTime.tryParse(user!.birthday!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    final success = await appState.updateProfile(
                      name: _nameController.text.trim(),
                      bio: _bioController.text.trim(),
                      gender: _selectedGender,
                      birthday: _selectedBirthday?.toIso8601String().substring(0, 10),
                      phone: _phoneController.text.trim(),
                      avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
                    );
                    setState(() => _isSaving = false);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.primaryRose),
                      );
                      Navigator.pop(context);
                    }
                  },
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar Editor
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.primaryRose,
                  backgroundImage: _avatarUrlController.text.isNotEmpty ? NetworkImage(_avatarUrlController.text) : (user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null),
                  child: (_avatarUrlController.text.isEmpty && user?.avatarUrl == null)
                      ? Text(user?.name.substring(0, 1) ?? 'U', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1E1C2B), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Couple ID & Username badge (read-only)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Couple ID (Permanent)', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(user?.coupleId ?? 'CP-XXXX', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Username', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('@${user?.username ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Name Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryRose),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
          ),
          const SizedBox(height: 16),

          // Bio Input
          TextField(
            controller: _bioController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Bio / Relationship Motto',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.favorite_outline_rounded, color: AppTheme.primaryRose),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
          ),
          const SizedBox(height: 16),

          // Gender Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                dropdownColor: const Color(0xFF1E1C2B),
                isExpanded: true,
                hint: Text('Select Gender (Optional)', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                items: ['Female', 'Male', 'Non-Binary', 'Prefer not to say'].map((g) {
                  return DropdownMenuItem<String>(
                    value: g.toLowerCase(),
                    child: Text(g, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Birthday Picker
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedBirthday = picked);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, color: AppTheme.primaryRose),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedBirthday == null
                          ? 'Set Birthday'
                          : 'Birthday: ${_selectedBirthday!.toIso8601String().substring(0, 10)}',
                      style: TextStyle(
                        color: _selectedBirthday == null ? Colors.white.withOpacity(0.6) : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_month_rounded, color: Colors.white54, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phone Input
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number (Optional)',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryRose),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
          ),
          const SizedBox(height: 16),

          // Avatar Image URL Input
          TextField(
            controller: _avatarUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Avatar Image URL',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.image_outlined, color: AppTheme.primaryRose),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
