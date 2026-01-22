import 'package:flutter/material.dart';

import '../../core/app_data.dart';
import 'payment_screen.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});
  static const routeName = '/create-ad';

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  bool featured = false;
  bool sponsored = false;
  
  final _headlineController = TextEditingController();
  final _aboutController = TextEditingController();
  String? _selectedCountry;
  String? _selectedReligion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Post matrimony ad',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ad details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _headlineController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Headline',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'e.g. Looking for a life partner',
                hintStyle: TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.title_outlined, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aboutController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'About me',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'Describe yourself...',
                hintStyle: TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.description_outlined, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCountry ?? 'India',
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Country',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.flag_outlined, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              items: AppData.countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReligion,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Religion',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.church_outlined, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              items: AppData.religions.map((religion) {
                return DropdownMenuItem(
                  value: religion,
                  child: Text(religion),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedReligion = value),
            ),
            const SizedBox(height: 24),
            Text(
              'Boost your ad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: featured
                    ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: featured
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : Colors.grey.shade200,
                  width: featured ? 2 : 1,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Featured post (3 days)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'Pay ₹299 to highlight your ad for 3 days. Higher visibility in search results.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                value: featured,
                activeColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() {
                  featured = v;
                  if (v) sponsored = false;
                }),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sponsored
                    ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sponsored
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : Colors.grey.shade200,
                  width: sponsored ? 2 : 1,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Sponsored post (7 days)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'Pay ₹599 for top placement and sponsored badge for 7 days.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                value: sponsored,
                activeColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() {
                  sponsored = v;
                  if (v) featured = false;
                }),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (featured || sponsored) {
                    Navigator.pushNamed(
                      context,
                      PaymentScreen.routeName,
                      arguments: {'featured': featured, 'sponsored': sponsored},
                    );
                  } else {
                    // Free post
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ad posted successfully (free)')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Post ad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
