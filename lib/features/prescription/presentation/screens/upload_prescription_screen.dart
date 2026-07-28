import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/core/widgets/custom_image_uploader.dart';
import 'package:pharmacare/features/file_upload/presentation/cubit/file_upload_cubit.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/prescription_cubit.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/prescription_state.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_state.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_state.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_cubit.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_state.dart';
import 'package:pharmacare/features/profile/presentation/screens/address_book_screen.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// صفحة رفع الروشتة وطلب الأدوية للصيدلية - Upload Prescription & Order Screen
class UploadPrescriptionScreen extends StatefulWidget {
  final bool isOrderMode;

  const UploadPrescriptionScreen({super.key, this.isOrderMode = false});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _doctorController = TextEditingController();
  final _clinicController = TextEditingController();
  String? _prescriptionUrl;
  String? _prescriptionFileId;
  AddressEntity? _selectedAddress;
  String? _selectedPharmacyId;
  DateTime _issueDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 90));
  bool _isSubmitted = false;

  void _submit(BuildContext context) {
    if (_prescriptionFileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى رفع صورة الروشتة أولاً والانتظار حتى انتهاء التحميل',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_doctorController.text.isEmpty || _clinicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إكمال بيانات الطبيب والعيادة', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (widget.isOrderMode) {
      if (_selectedPharmacyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('برجاء اختيار الصيدلية المستقبلة للطلب أولاً', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('برجاء اختيار عنوان التوصيل أولاً', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    context.read<PrescriptionCubit>().createPrescription(
          doctorName: _doctorController.text,
          clinicName: _clinicController.text,
          issueDate: DateFormat('yyyy-MM-dd').format(_issueDate),
          expiryDate: DateFormat('yyyy-MM-dd').format(_expiryDate),
          uploadedFileIds: [_prescriptionFileId!],
        );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _doctorController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<FileUploadCubit>()),
        BlocProvider(create: (context) => sl<PrescriptionCubit>()),
        BlocProvider(create: (context) => sl<PharmacyCubit>()..fetchPharmacies()),
        BlocProvider(create: (context) => sl<AddressCubit>()..fetchAddresses()),
        BlocProvider(create: (context) => sl<OrderCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PrescriptionCubit, PrescriptionState>(
            listener: (context, state) {
              if (state is PrescriptionSuccess) {
                if (widget.isOrderMode && _selectedPharmacyId != null && _selectedAddress != null) {
                  context.read<OrderCubit>().createOrder(
                        pharmacyId: _selectedPharmacyId!,
                        deliveryAddressId: _selectedAddress!.id,
                        prescriptionId: state.prescription.id,
                        deliveryNotes: _notesController.text.isNotEmpty
                            ? _notesController.text
                            : 'طلب روشتة مرفوعة',
                        items: const [],
                      );
                } else {
                  setState(() => _isSubmitted = true);
                }
              } else if (state is PrescriptionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),
          BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderCreatedSuccess) {
                setState(() => _isSubmitted = true);
              }
            },
          ),
        ],
        child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
          builder: (context, prescriptionState) {
            return BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                if (_isSubmitted) return _buildSuccessView();

                final isSubmitting = prescriptionState is PrescriptionLoading || orderState is OrderLoading;

                return Scaffold(
                  backgroundColor: const Color(0xFFF0F5FF),
                  body: Stack(
                    children: [
                      _buildMeshBackground(),
                      Column(
                        children: [
                          _buildHeader(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 32.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FadeInDown(
                                    duration: const Duration(milliseconds: 600),
                                    child: _buildGuidelinesCard(),
                                  ),
                                  SizedBox(height: 24.h),
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: const Duration(milliseconds: 200),
                                    child: CustomImageUploader(
                                      label: 'صورة الروشتة',
                                      fileType: 'Prescription',
                                      onUploadSuccess: (url) {
                                        setState(() => _prescriptionUrl = url);
                                      },
                                      onUploadFileSuccess: (file) {
                                        setState(() => _prescriptionFileId = file.id);
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: const Duration(milliseconds: 400),
                                    child: _buildDoctorInfoFields(),
                                  ),
                                  if (widget.isOrderMode) ...[
                                    SizedBox(height: 20.h),
                                    FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: const Duration(milliseconds: 500),
                                      child: _buildAddressPickerSection(),
                                    ),
                                    SizedBox(height: 20.h),
                                    FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: const Duration(milliseconds: 550),
                                      child: _buildPharmacyPickerSection(),
                                    ),
                                  ],
                                  SizedBox(height: 20.h),
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: const Duration(milliseconds: 600),
                                    child: _buildNotesField(),
                                  ),
                                  SizedBox(height: 24.h),
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: const Duration(milliseconds: 700),
                                    child: _buildExpectedTimeCard(),
                                  ),
                                  SizedBox(height: 28.h),
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: const Duration(milliseconds: 800),
                                    child: _buildSubmitButton(context, isSubmitting),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF43D4A0).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }


  /// الهيدر
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF2F6BFF),
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رفع روشتة',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Upload Prescription',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// كارت الإرشادات
  Widget _buildGuidelinesCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F6BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF2F6BFF),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'إرشادات الرفع',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _guidelineBullet('تأكد من وضوح الروشتة وبيانات الطبيب'),
              _guidelineBullet('الصورة يجب أن تكون ملتقطة في إضاءة جيدة'),
              _guidelineBullet('يمكنك إضافة ملاحظات للصيدلي في الأسفل'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guidelineBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'اسم الطبيب',
          hint: 'د. أحمد علي',
          controller: _doctorController,
          icon: Icons.person_outline,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          label: 'اسم العيادة / المستشفى',
          hint: 'عيادة الأمل التخصصية',
          controller: _clinicController,
          icon: Icons.local_hospital_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: const Color(0xFF2F6BFF).withOpacity(0.6),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  /// حقل العنوان
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Text(
            'عنوان التوصيل',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: TextField(
                controller: _addressController,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'شارع الجمهورية، المعادي، القاهرة',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF2F6BFF).withOpacity(0.6),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// حقل الملاحظات
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Text(
            'ملاحظات (اختياري)',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: TextField(
                controller: _notesController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: '...أي ملاحظات إضافية للصيدلي',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: const Color(0xFF2F6BFF).withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// كارد وقت الرد المتوقع
  Widget _buildExpectedTimeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2F6BFF).withOpacity(0.08),
            const Color(0xFF43D4A0).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF2F6BFF).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F6BFF).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Color(0xFF2F6BFF),
              size: 24,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت الرد المتوقع',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'سنقوم بمراجعة طلبك والرد خلال 30-60 دقيقة لتأكيد التوفر والسعر.',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPickerSection() {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        List<AddressEntity> addresses = [];
        if (state is AddressesLoaded) {
          addresses = state.addresses;
          if (_selectedAddress == null && addresses.isNotEmpty) {
            AddressEntity defaultAddr = addresses.first;
            for (final addr in addresses) {
              if (addr.isDefault) {
                defaultAddr = addr;
                break;
              }
            }
            _selectedAddress = defaultAddr;
          }
        }

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عنوان التوصيل *',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 10.h),
              if (addresses.isEmpty) ...[
                Text(
                  'لم تقم بإضافة عناوين توصيل بعد.',
                  style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.red),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AddressBookScreen()))
                        .then((_) => context.read<AddressCubit>().fetchAddresses());
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: Text('إضافة عنوان جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                DropdownButtonHideUnderline(
                  child: DropdownButton<AddressEntity>(
                    isExpanded: true,
                    value: _selectedAddress,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: addresses.map((addr) {
                      return DropdownMenuItem<AddressEntity>(
                        value: addr,
                        child: Text(
                          '${addr.city} - ${addr.street}',
                          style: GoogleFonts.cairo(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        _selectedAddress = newVal;
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPharmacyPickerSection() {
    return BlocBuilder<PharmacyCubit, PharmacyState>(
      builder: (context, state) {
        List<PharmacyEntity> pharmacies = [];
        if (state is PharmaciesLoaded) {
          pharmacies = state.pharmacies;
          if (_selectedPharmacyId == null && pharmacies.isNotEmpty) {
            _selectedPharmacyId = pharmacies.first.id;
          }
        }

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر صيدلية التوريد *',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 10.h),
              if (state is PharmacyLoading || state is PharmacyInitial)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else if (state is PharmacyError)
                Text(
                  'تعذر تحميل الصيدليات',
                  style: GoogleFonts.cairo(fontSize: 12.sp, color: AppColors.error),
                )
              else if (pharmacies.isEmpty)
                Text(
                  'عذراً، لا توجد صيدليات متاحة حالياً',
                  style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
                )
              else
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPharmacyId,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: pharmacies.map((pharm) {
                      return DropdownMenuItem<String>(
                        value: pharm.id,
                        child: Text(
                          pharm.name,
                          style: GoogleFonts.cairo(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        _selectedPharmacyId = newVal;
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F6BFF), Color(0xFF1E40AF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6BFF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.isOrderMode ? 'إرسال الروشتة والطلب للصيدلية' : 'حفظ الروشتة في السجل الطبي',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }


  /// شاشة النجاح
  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      body: Stack(
        children: [
          _buildMeshBackground(),
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C48C).withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Pulse(
                            infinite: true,
                            child: Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C48C).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 70,
                            color: Color(0xFF00C48C),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      widget.isOrderMode ? 'تم إرسال الطلب للصيدلية بنجاح!' : 'تم حفظ الروشتة بنجاح!',
                      style: GoogleFonts.cairo(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      widget.isOrderMode
                          ? 'تم إرسال الروشتة وطلب الأدوية للصيدلية المختارة.\nسيقوم الفريق بمراجعة طلبك وتحديد السعر والتواصل معك.'
                          : 'تم حفظ صورة الروشتة بنجاح في سجلاتك الطبية وترشيفها في قسم روشتاتي.',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      height: 54.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF2F6BFF).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'العودة للرئيسية',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F6BFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
