import 'dart:async';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/pharmacy/data/models/medicine_data.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/medicine_search_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/medicine_search_state.dart';
import 'package:pharmacare/features/pharmacy/presentation/screens/cart_screen.dart';
import 'package:pharmacare/features/pharmacy/presentation/widgets/medicine_card.dart';
import 'package:pharmacare/features/prescription/presentation/screens/upload_prescription_screen.dart';
import 'package:shimmer/shimmer.dart';

/// صفحة طلب الدواء - Order Medicine Screen مربوطة بالـ API
class OrderMedicineScreen extends StatelessWidget {
  const OrderMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MedicineSearchCubit>()..searchMedicines(''),
      child: const OrderMedicineView(),
    );
  }
}

class OrderMedicineView extends StatefulWidget {
  const OrderMedicineView({super.key});

  @override
  State<OrderMedicineView> createState() => _OrderMedicineViewState();
}

class _OrderMedicineViewState extends State<OrderMedicineView> {
  final List<CartItem> _cartItems = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MedicineSearchCubit>().loadNextPage();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<MedicineSearchCubit>().searchMedicines(query);
      }
    });
  }

  /// عدد العناصر في السلة
  int get _cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// إضافة دواء للسلة
  void _addToCart(MedicineEntity medicine) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.medicine.id == medicine.id,
      );
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(medicine: medicine));
      }
    });

    // إظهار SnackBar بنمط زجاجي
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C48C).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'تم إضافة ${medicine.name} للسلة ✓',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// فتح صفحة السلة
  void _openCart() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CartScreen(
          cartItems: _cartItems,
          onCartUpdated: () => setState(() {}),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      body: Stack(
        children: [
          _buildMeshBackground(),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<MedicineSearchCubit, MedicineSearchState>(
                  builder: (context, state) {
                    if (state is MedicineSearchLoading && state.isFirstFetch) {
                      return _buildShimmerGrid();
                    }

                    List<MedicineEntity> medicines = [];
                    bool hasReachedMax = false;

                    if (state is MedicineSearchLoaded) {
                      medicines = state.medicines;
                      hasReachedMax = state.hasReachedMax;
                    } else if (state is MedicineSearchLoading) {
                      medicines = state.oldMedicines;
                    } else if (state is MedicineSearchError) {
                      return _buildErrorState(state.message);
                    }

                    if (medicines.isEmpty) {
                      return _buildEmptyState();
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: hasReachedMax ? medicines.length : medicines.length + 2,
                      itemBuilder: (context, index) {
                        if (index >= medicines.length) {
                          return _buildLoadingItem();
                        }
                        final medicine = medicines[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: MedicineCard(
                            medicine: medicine,
                            onAddToCart: () => _addToCart(medicine),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
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
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.85),
                AppColors.primary.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب دواء',
                            style: GoogleFonts.cairo(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'PharmaCare Global Catalog',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _openCart,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.shopping_basket_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            if (_cartItemCount > 0)
                              Positioned(
                                top: -5,
                                right: -5,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4757),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 22.w,
                                    minHeight: 22.w,
                                  ),
                                  child: Text(
                                    '$_cartItemCount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم الدواء أو المادة الفعالة...',
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UploadPrescriptionScreen(isOrderMode: true),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'مش عارف اسم الدواء؟ارفع الروشتة  📄',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'عذراً، لم نجد نتائج لبحثك',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ أثناء الاتصال',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            message,
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<MedicineSearchCubit>().searchMedicines(_searchQuery),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
