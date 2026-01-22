import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_data.dart';
import '../../core/profile_api.dart';
import 'payment_post_profile_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  static const routeName = '/complete-profile';

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileApi = ProfileApi();
  final _imagePicker = ImagePicker();
  
  bool hideMobile = true;
  bool hidePhotos = false;
  File? _profilePhoto;
  String? _profilePhotoUrl;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _heightController = TextEditingController();
  final _incomeController = TextEditingController();
  final _aboutController = TextEditingController();
  final _preferencesController = TextEditingController();
  
  // Family details controllers
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  
  // Family details dropdowns
  String? _fatherOccupation;
  String? _motherOccupation;
  String? _brothersCount;
  String? _brothersMaritalStatus;
  String? _sistersCount;
  String? _sistersMaritalStatus;
  
  // Dropdown values
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedLivingCountry;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedComplexion;
  String? _selectedEducation;
  String? _selectedProfession;
  String? _profileHandledBy; // 'self', 'father', 'mother', 'brother', 'sister'

  InputDecoration _inputDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF757575), // Colors.black54
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF757575), size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String? hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: const TextStyle(
          color: Color(0xFF212121), // Colors.black87
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(label, icon),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                displayText(item),
                style: const TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        hint: hint != null
            ? Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 15,
                ),
              )
            : null,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        iconSize: 24,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: 300,
        isExpanded: true,
        isDense: false,
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                displayText(item),
                style: TextStyle(
                  color: value == item
                      ? theme.colorScheme.primary
                      : const Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'groom';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Complete profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          image: _profilePhoto != null
                              ? DecorationImage(
                                  image: FileImage(_profilePhoto!),
                                  fit: BoxFit.cover,
                                )
                              : _profilePhotoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_profilePhotoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _profilePhoto == null && _profilePhotoUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.black54,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: _isUploadingPhoto
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: _pickImage,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildSectionTitle('Profile management'),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'This profile is handled by',
                icon: Icons.person_outline,
                value: _profileHandledBy ?? 'self',
                items: const ['self', 'father', 'mother', 'brother', 'sister'],
                displayText: (value) {
                  switch (value) {
                    case 'self':
                      return 'Self';
                    case 'father':
                      return 'Father';
                    case 'mother':
                      return 'Mother';
                    case 'brother':
                      return 'Brother';
                    case 'sister':
                      return 'Sister';
                    default:
                      return value;
                  }
                },
                onChanged: (value) => setState(() => _profileHandledBy = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select who handles this profile';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Personal details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Full name', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Date of birth',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dayController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _inputDecoration('DD', Icons.cake_outlined),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final day = int.tryParse(value.trim());
                        if (day == null || day < 1 || day > 31) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _inputDecoration('MM', Icons.cake_outlined),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final month = int.tryParse(value.trim());
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _inputDecoration('YYYY', Icons.cake_outlined),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final year = int.tryParse(value.trim());
                        if (year == null || year < 1950 || year > DateTime.now().year) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Gender',
                icon: Icons.person_outline,
                value: _selectedGender,
                items: const ['Male', 'Female'],
                displayText: (value) => value,
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Location (home)'),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Country',
                icon: Icons.flag_outlined,
                value: _selectedCountry ?? 'India',
                items: AppData.countries,
                displayText: (value) => value,
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value ?? 'India';
                    _selectedState = null;
                    _selectedCity = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'State / Province',
                icon: Icons.map_outlined,
                value: _selectedState,
                items: _getStatesForCountry(),
                displayText: (value) => value,
                hint: _getStatesForCountry().isEmpty ? 'Select country first' : 'Select state',
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'City',
                icon: Icons.location_city_outlined,
                value: _selectedCity,
                items: _getCitiesForState(),
                displayText: (value) => value,
                hint: _getCitiesForState().isEmpty || _getCitiesForState().first == 'Select state first' 
                    ? 'Select state first' 
                    : 'Select city',
                onChanged: (value) => setState(() => _selectedCity = value),
                validator: (value) {
                  if (value == null || value.isEmpty || value == 'Select state first') {
                    return 'Please select city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Currently living / working in'),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Country of residence',
                icon: Icons.flight_takeoff_outlined,
                value: _selectedLivingCountry,
                items: AppData.countries,
                displayText: (value) => value,
                hint: 'Select country',
                onChanged: (value) {
                  setState(() {
                    _selectedLivingCountry = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Religion & community'),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Religion',
                icon: Icons.church_outlined,
                value: _selectedReligion,
                items: AppData.religions,
                displayText: (value) => value,
                hint: 'Select religion',
                onChanged: (value) {
                  setState(() {
                    _selectedReligion = value;
                    _selectedCaste = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Caste / Community',
                icon: Icons.group_outlined,
                value: _selectedCaste,
                items: AppData.getCastesForReligion(_selectedReligion),
                displayText: (value) => value,
                hint: _selectedReligion == null ? 'Select religion first' : 'Select caste',
                onChanged: (value) => setState(() => _selectedCaste = value),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Physical details'),
              const SizedBox(height: 16),
              TextField(
                controller: _heightController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Height (cm)', Icons.height_outlined).copyWith(
                  hintText: 'e.g. 175',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Complexion / Skin tone',
                icon: Icons.face_outlined,
                value: _selectedComplexion,
                items: AppData.complexions,
                displayText: (value) => value,
                hint: 'Select complexion',
                onChanged: (value) => setState(() => _selectedComplexion = value),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Education & profession'),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Highest education',
                icon: Icons.school_outlined,
                value: _selectedEducation,
                items: AppData.educationLevels,
                displayText: (value) => value,
                hint: 'Select education',
                onChanged: (value) => setState(() => _selectedEducation = value),
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Profession',
                icon: Icons.work_outline,
                value: _selectedProfession,
                items: AppData.professions,
                displayText: (value) => value,
                hint: 'Select profession',
                onChanged: (value) => setState(() => _selectedProfession = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _incomeController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Annual income (optional)', Icons.attach_money_outlined).copyWith(
                  hintText: 'e.g. 50000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('About me'),
              const SizedBox(height: 16),
              TextField(
                controller: _aboutController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Write a short introduction', Icons.edit_outlined).copyWith(
                  alignLabelWithHint: true,
                  hintText: 'Tell others about yourself...',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Partner preferences'),
              const SizedBox(height: 16),
              TextField(
                controller: _preferencesController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Describe your preferred partner', Icons.favorite_outline).copyWith(
                  alignLabelWithHint: true,
                  hintText: 'What are you looking for in a partner?',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Family details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatherNameController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Father\'s name (optional)', Icons.person_outline),
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Father\'s occupation (optional)',
                icon: Icons.work_outline,
                value: _fatherOccupation,
                items: AppData.familyOccupations,
                displayText: (value) => value,
                hint: 'Select occupation',
                onChanged: (value) => setState(() => _fatherOccupation = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motherNameController,
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration('Mother\'s name (optional)', Icons.person_outline),
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Mother\'s occupation (optional)',
                icon: Icons.work_outline,
                value: _motherOccupation,
                items: AppData.familyOccupations,
                displayText: (value) => value,
                hint: 'Select occupation',
                onChanged: (value) => setState(() => _motherOccupation = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'Brothers (optional)',
                      icon: Icons.person_outline,
                      value: _brothersCount,
                      items: AppData.siblingCounts,
                      displayText: (value) => value,
                      hint: 'Select count',
                      onChanged: (value) => setState(() => _brothersCount = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'Brothers status (optional)',
                      icon: Icons.family_restroom_outlined,
                      value: _brothersMaritalStatus,
                      items: AppData.maritalStatus,
                      displayText: (value) => value,
                      hint: 'Select status',
                      onChanged: (value) => setState(() => _brothersMaritalStatus = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'Sisters (optional)',
                      icon: Icons.person_outline,
                      value: _sistersCount,
                      items: AppData.siblingCounts,
                      displayText: (value) => value,
                      hint: 'Select count',
                      onChanged: (value) => setState(() => _sistersCount = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'Sisters status (optional)',
                      icon: Icons.family_restroom_outlined,
                      value: _sistersMaritalStatus,
                      items: AppData.maritalStatus,
                      displayText: (value) => value,
                      hint: 'Select status',
                      onChanged: (value) => setState(() => _sistersMaritalStatus = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Privacy'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Hide mobile number',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: const Text(
                        'Recommended. Others send request to view your number.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      value: hideMobile,
                      onChanged: (v) => setState(() => hideMobile = v),
                      activeColor: theme.colorScheme.primary,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    SwitchListTile(
                      title: const Text(
                        'Hide profile photos',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: const Text(
                        'Show photos only after you accept their request.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      value: hidePhotos,
                      onChanged: (v) => setState(() => hidePhotos = v),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleSaveAndContinue(role),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save & continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 16,
      ),
    );
  }

  List<String> _getStatesForCountry() {
    if (_selectedCountry == null) return [];
    switch (_selectedCountry) {
      case 'India':
        return AppData.indianStates; // Use comprehensive list from AppData
      case 'Saudi Arabia':
        return ['Riyadh Province', 'Makkah Province', 'Eastern Province', 'Al Madinah Province', 'Al Qassim Province', 'Asir Province'];
      case 'UAE':
        return ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman', 'Ras Al Khaimah', 'Fujairah', 'Umm Al Quwain'];
      case 'Pakistan':
        return ['Sindh', 'Punjab', 'Khyber Pakhtunkhwa', 'Balochistan', 'Islamabad Capital Territory', 'Gilgit-Baltistan'];
      case 'USA':
        return ['California', 'New York', 'Texas', 'Florida', 'Illinois', 'Pennsylvania', 'Ohio', 'Georgia'];
      case 'UK':
        return ['England', 'Scotland', 'Wales', 'Northern Ireland'];
      case 'Canada':
        return ['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba', 'Saskatchewan'];
      case 'Australia':
        return ['New South Wales', 'Victoria', 'Queensland', 'Western Australia', 'South Australia', 'Tasmania'];
      default:
        return [];
    }
  }

  List<String> _getCitiesForState() {
    if (_selectedState == null) {
      if (_selectedCountry == null || _selectedCountry != 'India') {
        return ['Select state/province first'];
      }
      return ['Select state first'];
    }
    // Use AppData for Indian states (has comprehensive city list)
    if (_selectedCountry == 'India') {
      return AppData.getCitiesForState(_selectedState);
    }
    // For other countries with states
    switch (_selectedState) {
      case 'Riyadh Province':
        return ['Riyadh', 'Diriyah', 'Al Kharj', 'Dawadmi'];
      case 'Makkah Province':
        return ['Jeddah', 'Mecca', 'Taif', 'Rabigh'];
      case 'Eastern Province':
        return ['Dammam', 'Khobar', 'Dhahran', 'Jubail'];
      case 'Al Madinah Province':
        return ['Medina', 'Yanbu', 'Badr', 'Al Ula'];
      case 'Dubai':
        return ['Dubai', 'Jumeirah', 'Deira', 'Bur Dubai', 'Marina'];
      case 'Abu Dhabi':
        return ['Abu Dhabi', 'Al Ain', 'Liwa Oasis'];
      case 'Sharjah':
        return ['Sharjah', 'Khor Fakkan', 'Kalba'];
      default:
        return ['Select state first'];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profilePhoto = File(image.path);
          _isUploadingPhoto = true;
          _errorMessage = null;
        });

        // Upload photo
        final response = await _profileApi.uploadPhoto(
          imagePath: image.path,
          onProgress: (sent, total) {
            // Progress callback (optional)
          },
        );

        if (response['success'] == true) {
          setState(() {
            _profilePhotoUrl = response['photoUrl'] as String?;
            _isUploadingPhoto = false;
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to upload photo';
            _isUploadingPhoto = false;
            _profilePhoto = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image. Please try again.';
        _isUploadingPhoto = false;
        _profilePhoto = null;
      });
    }
  }

  Future<void> _handleSaveAndContinue(String role) async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required dropdowns
    if (_selectedGender == null) {
      setState(() {
        _errorMessage = 'Please select gender';
      });
      return;
    }

    if (_selectedCountry == null) {
      setState(() {
        _errorMessage = 'Please select country';
      });
      return;
    }

    if (_selectedCity == null) {
      setState(() {
        _errorMessage = 'Please select city';
      });
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate and calculate date of birth
      final day = int.tryParse(_dayController.text.trim());
      final month = int.tryParse(_monthController.text.trim());
      final year = int.tryParse(_yearController.text.trim());
      
      if (day == null || month == null || year == null) {
        setState(() {
          _errorMessage = 'Please enter a valid date of birth';
          _isLoading = false;
        });
        return;
      }
      
      DateTime dateOfBirth;
      try {
        dateOfBirth = DateTime(year, month, day);
        if (dateOfBirth.year != year || dateOfBirth.month != month || dateOfBirth.day != day) {
          setState(() {
            _errorMessage = 'Please enter a valid date of birth';
            _isLoading = false;
          });
          return;
        }
        // Check minimum age (18 years)
        final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
        if (age < 18) {
          setState(() {
            _errorMessage = 'You must be at least 18 years old';
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Please enter a valid date of birth';
          _isLoading = false;
        });
        return;
      }

      // Prepare profile data
      final profileData = {
        'name': _nameController.text.trim(),
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': _selectedGender,
        'profileHandledBy': _profileHandledBy ?? 'self',
        'height': _heightController.text.trim().isNotEmpty
            ? int.tryParse(_heightController.text.trim())
            : null,
        'complexion': _selectedComplexion,
        'country': _selectedCountry,
        'livingCountry': _selectedLivingCountry,
        'state': _selectedState,
        'city': _selectedCity,
        'religion': _selectedReligion,
        'caste': _selectedCaste,
        'education': _selectedEducation,
        'profession': _selectedProfession,
        'annualIncome': _incomeController.text.trim().isNotEmpty
            ? int.tryParse(_incomeController.text.trim())
            : null,
        'about': _aboutController.text.trim(),
        'partnerPreferences': _preferencesController.text.trim(),
        'hideMobile': hideMobile,
        'hidePhotos': hidePhotos,
        // Family details
        'fatherName': _fatherNameController.text.trim().isNotEmpty ? _fatherNameController.text.trim() : null,
        'fatherOccupation': _fatherOccupation,
        'motherName': _motherNameController.text.trim().isNotEmpty ? _motherNameController.text.trim() : null,
        'motherOccupation': _motherOccupation,
        'brothersCount': _brothersCount,
        'brothersMaritalStatus': _brothersMaritalStatus,
        'sistersCount': _sistersCount,
        'sistersMaritalStatus': _sistersMaritalStatus,
        if (_profilePhotoUrl != null) 'profilePhoto': _profilePhotoUrl,
      };

      // Call complete profile API
      final response = await _profileApi.completeProfile(
        profileData: profileData,
      );

      if (response['success'] == true) {
        // Profile saved successfully, navigate to payment screen
        if (mounted) {
          Navigator.pushNamed(
            context,
            PaymentPostProfileScreen.routeName,
            arguments: role,
          );
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to save profile. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _heightController.dispose();
    _incomeController.dispose();
    _aboutController.dispose();
    _preferencesController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }
}
