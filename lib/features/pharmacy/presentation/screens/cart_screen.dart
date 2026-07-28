import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacy/data/models/medicine_data.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_state.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_state.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/order_tracking_screen.dart';
import 'package:pharmacare/features/profile/domain/entities/address_entity.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_cubit.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_state.dart';
import 'package:pharmacare/features/profile/presentation/screens/address_book_screen.dart';

/// صفحة السلة وتأكيد الطلب - Cart & Order Confirmation Screen مربوطة بالـ API
class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCartUpdated;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCartUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AddressCubit>()..fetchAddresses()),
        BlocProvider(create: (context) => getIt<OrderCubit>()),
        BlocProvider(create: (context) => getIt<PharmacyCubit>()..fetchPharmacies()),
      ],
      child: CartView(cartItems: cartItems, onCartUpdated: onCartUpdated),
    );
  }
}

class CartView extends StatefulWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCartUpdated;

  const CartView({
    super.key,
    required this.cartItems,
    required this.onCartUpdated,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  AddressEntity? _selectedAddress;
  String? _selectedPharmacyId;
  String? _createdOrderId;

  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
    });
    widget.onCartUpdated();
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
      } else {
        widget.cartItems.removeAt(index);
      }
    });
    widget.onCartUpdated();
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
    widget.onCartUpdated();
  }

  void _confirmOrder(BuildContext context) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('برجاء اختيار عنوان التوصيل أولاً', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPharmacyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('برجاء اختيار الصيدلية أولاً', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final itemsPayload = widget.cartItems
        .map((e) => {
              'medicineId': e.medicine.id,
              'quantity': e.quantity,
            })
        .toList();

    context.read<OrderCubit>().createOrder(
          pharmacyId: _selectedPharmacyId!,
          deliveryAddressId: _selectedAddress!.id,
          prescriptionId: null,
          deliveryNotes: 'طلب توصيل من سلة المريض المباشرة',
          items: itemsPayload,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCreatedSuccess) {
          setState(() {
            _createdOrderId = state.order.id;
          });
          // مسح السلة بعد نجاح الطلب
          widget.cartItems.clear();
          widget.onCartUpdated();
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, orderState) {
        final isConfirming = orderState is OrderLoading;
        final orderPlaced = _createdOrderId != null;

        return Scaffold(
          backgroundColor: AppColors.primaryLight,
          body: Stack(
            children: [
              _buildMeshBackground(),
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: orderPlaced
                        ? _buildOrderSuccess()
                        : widget.cartItems.isEmpty
                            ? _buildEmptyCart()
                            : _buildCartContent(isConfirming),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: (!orderPlaced && widget.cartItems.isNotEmpty)
              ? _buildBottomBar(isConfirming)
              : null,
        );
      },
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.06),
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

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.9),
                AppColors.primary.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
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
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سلة الطلبات',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '${widget.cartItems.length} أدوية في السلة',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
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

  Widget _buildCartContent(bool isConfirming) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'الأدوية المضافة',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(widget.cartItems.length, (index) {
            return FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: index * 100),
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _cartItemCard(index),
              ),
            );
          }),
          SizedBox(height: 20.h),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: _buildOrderSummary(),
          ),
          SizedBox(height: 20.h),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: _buildAddressPickerSection(),
          ),
          SizedBox(height: 20.h),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 500),
            child: _buildPharmacyPickerSection(),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _cartItemCard(int index) {
    final item = widget.cartItems[index];

    return Dismissible(
      key: Key(item.medicine.id + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(index),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 30.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Color(0xFFFF4757),
          size: 32,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2F6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicine.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'الجرعة: ${item.medicine.dosage}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  _quantityButton(
                    icon: Icons.remove_rounded,
                    onTap: () => _decrementQuantity(index),
                    color: const Color(0xFF64748B),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.add_rounded,
                    onTap: () => _incrementQuantity(index),
                    color: const Color(0xFF2F6BFF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF1E293B), size: 20),
              SizedBox(width: 8.w),
              Text(
                'ملخص الحساب',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آلية التسعير',
                style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF64748B)),
              ),
              Text(
                'تسعير صيدلي لاحق',
                style: GoogleFonts.cairo(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(color: AppColors.primary.withOpacity(0.1), height: 1),
          ),
          Text(
            'سيقوم الصيدلي بمراجعة أدوية الطلب وتحديد السعر النهائي ثم التواصل معك هاتفياً أو عبر الشات للموافقة قبل البدء في التوصيل.',
            style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey[600], height: 1.5),
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
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14.r),
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
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14.r),
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

  Widget _buildBottomBar(bool isConfirming) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آلية الدفع',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'كاش عند التوصيل',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: isConfirming ? null : () => _confirmOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                elevation: 10,
                shadowColor: AppColors.primary.withOpacity(0.4),
                padding: EdgeInsets.symmetric(horizontal: 32.w),
              ),
              child: isConfirming
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      children: [
                        Text(
                          'إرسال الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 56,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'سلتك خالية حالياً',
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يبدو أنك لم تضف أي أدوية بعد',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2F6BFF),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
            ),
            child: Text(
              'تصفح الصيدلية',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSuccess() {
    return Stack(
      children: [
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
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 70,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'تم إرسال طلبك!',
                    style: GoogleFonts.cairo(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'تم تسليم طلبك للصيدلية للمراجعة والتسعير.\nيرجى تتبع حالة الطلب من قسم التتبع.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F6BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'رقم المعاملة: #${_createdOrderId!.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F6BFF),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => OrderTrackingScreen(orderId: _createdOrderId!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'تتبع الطلب الآن ⌖',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'العودة للرئيسية',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
