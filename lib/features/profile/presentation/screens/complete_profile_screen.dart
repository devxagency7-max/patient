import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/core/widgets/custom_button.dart';
import 'package:pharmacare/core/widgets/custom_text_field.dart';
import 'package:pharmacare/features/home/presentation/screens/main_shell_screen.dart';
import 'package:pharmacare/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:pharmacare/features/profile/presentation/cubit/profile_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _onCompleteProfile() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().completeProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _dateOfBirthController.text.isEmpty ? null : _dateOfBirthController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            // Success -> Go to Home
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShellScreen()),
              (route) => false,
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FC),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'أهلاً بك في طمنّي!',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لنكمل ملفك الشخصي لنقدم لك تجربة أفضل',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Name
                      CustomTextField(
                        label: 'الاسم بالكامل',
                        hint: 'أحمد علي',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسمك';
                          }
                          if (value.length > 100) {
                            return 'الاسم طويل جداً';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Phone
                      CustomTextField(
                        label: 'رقم الهاتف (اختياري)',
                        hint: '+201XXXXXXXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 20),
                      
                      // Date of Birth
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'تاريخ الميلاد (اختياري)',
                            hint: 'YYYY-MM-DD',
                            prefixIcon: Icons.cake_outlined,
                            controller: _dateOfBirthController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Gender
                      Text(
                        'النوع (اختياري)',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildGenderOption('Male', 'ذكر', Icons.male_rounded),
                          const SizedBox(width: 16),
                          _buildGenderOption('Female', 'أنثى', Icons.female_rounded),
                          const SizedBox(width: 16),
                          _buildGenderOption('Other', 'آخر', Icons.more_horiz_rounded),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      CustomButton(
                        text: 'ابدأ الآن',
                        onPressed: _onCompleteProfile,
                        isLoading: state is ProfileLoading,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5A97DF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF5A97DF) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF5A97DF).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
