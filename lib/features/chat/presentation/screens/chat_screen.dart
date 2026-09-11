import 'dart:io';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/core/di/injection_container.dart';
import 'package:pharmacare/features/chat/domain/entities/chat_message_entity.dart';
import 'package:pharmacare/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:pharmacare/features/chat/presentation/cubit/chat_state.dart';
import 'package:pharmacare/features/chat/presentation/widgets/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String? pharmacistId;
  final String? relatedOrderId;

  const ChatScreen({
    super.key,
    this.pharmacistId,
    this.relatedOrderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()
        ..connectAndLoadHistory(
          pharmacistId: pharmacistId,
          relatedOrderId: relatedOrderId,
        ),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _pharmacistController = TextEditingController();
  final ScrollController _pharmacistScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pharmacistScrollController.addListener(_onPharmacistScroll);
  }

  void _onPharmacistScroll() {
    if (_pharmacistScrollController.position.pixels >=
        _pharmacistScrollController.position.maxScrollExtent - 100) {
      context.read<ChatCubit>().loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _pharmacistScrollController.removeListener(_onPharmacistScroll);
    _pharmacistController.dispose();
    _pharmacistScrollController.dispose();
    super.dispose();
  }

  Future<void> _sendPharmacistMessage() async {
    final text = _pharmacistController.text.trim();
    if (text.isEmpty) return;
    _scrollToBottom(_pharmacistScrollController);
    final sent = await context.read<ChatCubit>().sendMessage(text);
    // Only clear on success — on failure the text stays so the patient
    // doesn't have to retype it, and the error snackbar explains why.
    if (sent) _pharmacistController.clear();
  }

  Future<void> _pickAndSendAttachment() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    _scrollToBottom(_pharmacistScrollController);
    if (!mounted) return;
    await context.read<ChatCubit>().sendAttachment(File(image.path));
  }

  void _scrollToBottom(ScrollController controller) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: Stack(
        children: [
          _buildBackgroundBlob(),
          Column(
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              Expanded(child: _buildPharmacistTab()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistTab() {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.pharmacistChat.errorMessage !=
              current.pharmacistChat.errorMessage &&
          current.pharmacistChat.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.pharmacistChat.errorMessage!,
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
      builder: (context, state) {
        final thread = state.pharmacistChat;
        return Column(
          children: [
            if (thread.isConversationClosed) _buildClosedBanner(),
            Expanded(
              child: _buildMessagesList(
                messages: thread.messages,
                isLoading: thread.isLoading,
                loadingMore: thread.loadingMoreHistory,
                scrollController: _pharmacistScrollController,
                onRefresh: () => context.read<ChatCubit>().connectAndLoadHistory(),
              ),
            ),
            _buildInputSection(
              controller: _pharmacistController,
              isClosed: thread.isConversationClosed,
              onSend: _sendPharmacistMessage,
              onAttach: _pickAndSendAttachment,
              isUploadingAttachment: thread.isUploadingAttachment,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundBlob() {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          left: -100.w,
          child: Container(
            width: 350.w,
            height: 350.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 50.h,
          right: -80.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.08),
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
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isConnected = state.pharmacistChat.isConnected;

        return Container(
          margin: EdgeInsets.fromLTRB(
            20.w,
            MediaQuery.of(context).padding.top + 10.h,
            20.w,
            0,
          ),
          height: 70.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo_icon_app-removebg-preview.png',
                  width: 45.w,
                  height: 45.h,
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محادثة الصيدلية',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2D4A),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isConnected ? 'متصل بالصيدلي' : 'أوفلاين (جاري الاتصال)',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: isConnected ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'تحديث المحادثة',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.read<ChatCubit>().connectAndLoadHistory(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList({
    required List<ChatMessageEntity> messages,
    required bool isLoading,
    required bool loadingMore,
    required ScrollController scrollController,
    required Future<void> Function() onRefresh,
  }) {
    if (isLoading && messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final trailingCount = loadingMore ? 1 : 0;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: messages.length + trailingCount,
        itemBuilder: (context, index) {
          if (index >= messages.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          return FadeInUp(child: ChatBubble(message: messages[index]));
        },
      ),
    );
  }

  Widget _buildClosedBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'المحادثة مقفولة — انتهت العلاقة مع الصيدلي.',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required TextEditingController controller,
    required bool isClosed,
    required VoidCallback onSend,
    VoidCallback? onAttach,
    bool isUploadingAttachment = false,
  }) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 2.h,
          top: 10.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Row(
            children: [
              if (onAttach != null)
                GestureDetector(
                  onTap: (isClosed || isUploadingAttachment)
                      ? null
                      : onAttach,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    margin: EdgeInsets.only(left: 4.w),
                    child: Center(
                      child: isUploadingAttachment
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              Icons.attach_file_rounded,
                              color: isClosed
                                  ? Colors.grey
                                  : AppColors.primary,
                              size: 22.r,
                            ),
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isClosed,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: isClosed
                        ? 'المحادثة مقفولة'
                        : 'اكتب رسالتك هنا...',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: GoogleFonts.cairo(
                      color: const Color(0xFF1E2D4A).withOpacity(0.4),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E2D4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isClosed ? null : onSend,
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
