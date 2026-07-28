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

enum ChatMode { ai, pharmacist }

class ChatScreen extends StatelessWidget {
  final String? pharmacistId;
  final String? relatedOrderId;
  final ChatMode initialMode;

  const ChatScreen({
    super.key,
    this.pharmacistId,
    this.relatedOrderId,
    this.initialMode = ChatMode.ai,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()
        ..connectAndLoadHistory(
          pharmacistId: pharmacistId,
          relatedOrderId: relatedOrderId,
        )
        ..loadAiHistory(),
      child: ChatView(initialMode: initialMode),
    );
  }
}

class ChatView extends StatefulWidget {
  final ChatMode initialMode;

  const ChatView({super.key, this.initialMode = ChatMode.ai});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _pharmacistController = TextEditingController();
  final TextEditingController _aiController = TextEditingController();
  final ScrollController _pharmacistScrollController = ScrollController();
  final ScrollController _aiScrollController = ScrollController();

  ChatMode get _chatMode =>
      _tabController.index == 0 ? ChatMode.pharmacist : ChatMode.ai;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialMode == ChatMode.pharmacist ? 0 : 1,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
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
    _tabController.dispose();
    _pharmacistController.dispose();
    _aiController.dispose();
    _pharmacistScrollController.dispose();
    _aiScrollController.dispose();
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

  Future<void> _sendAiMessage() async {
    final text = _aiController.text.trim();
    if (text.isEmpty) return;
    _scrollToBottom(_aiScrollController);
    final sent = await context.read<ChatCubit>().sendAiMessage(text);
    if (sent) _aiController.clear();
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
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildPharmacistTab(), _buildAiTab()],
                ),
              ),
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
                showTyping: false,
                loadingMore: thread.loadingMoreHistory,
                scrollController: _pharmacistScrollController,
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

  Widget _buildAiTab() {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.aiChat.errorMessage != current.aiChat.errorMessage &&
          current.aiChat.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.aiChat.errorMessage!,
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
      builder: (context, state) {
        final thread = state.aiChat;
        return Column(
          children: [
            Expanded(
              child: _buildMessagesList(
                messages: thread.messages,
                isLoading: thread.isLoading,
                showTyping: thread.isAiTyping,
                loadingMore: false,
                scrollController: _aiScrollController,
              ),
            ),
            _buildInputSection(
              controller: _aiController,
              isClosed: false,
              onSend: _sendAiMessage,
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
                      _chatMode == ChatMode.ai
                          ? 'المساعد الذكي'
                          : 'محادثة الصيدلية',
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
                            color: (_chatMode == ChatMode.ai || isConnected)
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _chatMode == ChatMode.ai
                              ? 'نشط دائماً'
                              : isConnected
                              ? 'متصل بالصيدلي'
                              : 'أوفلاين (جاري الاتصال)',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: (_chatMode == ChatMode.ai || isConnected)
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF1E2D4A),
        labelStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'محادثة الصيدلية'),
          Tab(text: 'المساعد الذكي (AI)'),
        ],
      ),
    );
  }

  Widget _buildMessagesList({
    required List<ChatMessageEntity> messages,
    required bool isLoading,
    required bool showTyping,
    required bool loadingMore,
    required ScrollController scrollController,
  }) {
    if (isLoading && messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final leadingCount = showTyping ? 1 : 0;
    final trailingCount = loadingMore ? 1 : 0;

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: messages.length + leadingCount + trailingCount,
      itemBuilder: (context, index) {
        if (index == 0 && showTyping) {
          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildTypingIndicator(),
          );
        }
        final messageIndex = index - leadingCount;
        if (messageIndex >= messages.length) {
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
        return FadeInUp(child: ChatBubble(message: messages[messageIndex]));
      },
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _typingDot(index)),
        ),
      ),
    );
  }

  Widget _typingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 5.w,
          height: 5.w,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2D4A).withOpacity(0.2 + (value * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
