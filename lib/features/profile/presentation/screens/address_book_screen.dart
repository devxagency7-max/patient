import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/core/widgets/custom_button.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_cubit.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_state.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddressCubit>()..fetchAddresses(),
      child: const AddressBookView(),
    );
  }
}

class AddressBookView extends StatefulWidget {
  const AddressBookView({super.key});

  @override
  State<AddressBookView> createState() => _AddressBookViewState();
}

class _AddressBookViewState extends State<AddressBookView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'العناوين المحفوظة',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          _buildMeshBackground(),
          BlocConsumer<AddressCubit, AddressState>(
            listener: (context, state) {
              if (state is AddressOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF08C75A),
                  ),
                );
              } else if (state is AddressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFFFF4757),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AddressLoading && state is! AddressesLoaded) {
                return _buildLoadingState();
              }

              if (state is AddressesLoaded) {
                final addresses = state.addresses;
                if (addresses.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildAddressList(context, addresses);
              }

              if (state is AddressError) {
                return _buildErrorState(context, state.message);
              }

              return _buildLoadingState();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressBottomSheet(context),
        backgroundColor: const Color(0xFF5A97DF),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(
          'إضافة عنوان جديد',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50.h,
          left: -50.w,
          child: Container(
            width: 250.r,
            height: 250.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5A97DF).withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -100.h,
          right: -100.w,
          child: Container(
            width: 350.r,
            height: 350.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF08C75A).withOpacity(0.06),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3,
      padding: EdgeInsets.all(20.r),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120.h,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 70.sp,
                color: const Color(0xFF5A97DF),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد عناوين محفوظة',
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'أضف عنوان توصيلك لتسهيل عملية طلب وتوصيل الأدوية إليك في أسرع وقت.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60.sp, color: const Color(0xFFFF4757)),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ أثناء تحميل البيانات',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            message,
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<AddressCubit>().fetchAddresses(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(BuildContext context, List<AddressEntity> addresses) {
    return ListView.builder(
      itemCount: addresses.length,
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 100.h),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 350),
          delay: Duration(milliseconds: index * 60),
          child: Container(
            margin: EdgeInsets.only(bottom: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: address.isDefault ? const Color(0xFF5A97DF) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: address.isDefault ? const Color(0xFF5A97DF) : const Color(0xFF94A3B8),
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            address.city,
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (address.isDefault) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF5FC),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'افتراضي',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5A97DF),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (!address.isDefault)
                            IconButton(
                              icon: const Icon(Icons.star_outline_rounded, color: Color(0xFF94A3B8)),
                              tooltip: 'تعيين كافتراضي',
                              onPressed: () => context.read<AddressCubit>().setDefault(address.id),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4757)),
                            onPressed: () => _showDeleteConfirmation(context, address.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'الشارع: ${address.street}',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  Text(
                    'المحافظة: ${address.governorate}',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (address.additionalInfo != null && address.additionalInfo!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'معلومات إضافية: ${address.additionalInfo}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'حذف العنوان',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف هذا العنوان؟ لا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AddressCubit>().deleteAddress(addressId);
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(color: const Color(0xFFFF4757), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext parentContext) {
    final addressCubit = parentContext.read<AddressCubit>();
    final formKey = GlobalKey<FormState>();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final govController = TextEditingController();
    final infoController = TextEditingController();
    bool isDefault = false;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetInnerContext, setStateSheet) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'إضافة عنوان توصيل جديد',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: streetController,
                    decoration: InputDecoration(
                      labelText: 'الشارع ورقم البناية / الشقة *',
                      labelStyle: GoogleFonts.cairo(fontSize: 13.sp),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      prefixIcon: const Icon(Icons.streetview_rounded),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'الرجاء إدخال الشارع' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'المدينة / المنطقة *',
                      labelStyle: GoogleFonts.cairo(fontSize: 13.sp),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'الرجاء إدخال المدينة' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: govController,
                    decoration: InputDecoration(
                      labelText: 'المحافظة *',
                      labelStyle: GoogleFonts.cairo(fontSize: 13.sp),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'الرجاء إدخال المحافظة' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: infoController,
                    decoration: InputDecoration(
                      labelText: 'معلومات إضافية (اختياري)',
                      labelStyle: GoogleFonts.cairo(fontSize: 13.sp),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      prefixIcon: const Icon(Icons.info_outline_rounded),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SwitchListTile(
                    title: Text(
                      'تعيين كعنوان افتراضي للتوصيل',
                      style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    value: isDefault,
                    activeColor: const Color(0xFF5A97DF),
                    onChanged: (val) {
                      setStateSheet(() {
                        isDefault = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(
                    text: 'حفظ العنوان',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(sheetContext).pop();
                        // Call Add Address API via pre-fetched addressCubit
                        addressCubit.addAddress(
                          street: streetController.text.trim(),
                          city: cityController.text.trim(),
                          governorate: govController.text.trim(),
                          additionalInfo: infoController.text.trim(),
                          isDefault: isDefault,
                          latitude: 30.05, // default Mock coordinates
                          longitude: 31.25,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

