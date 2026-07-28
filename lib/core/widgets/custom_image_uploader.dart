import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmacare/core/constants/app_colors.dart';
import 'package:pharmacare/features/file_upload/presentation/cubit/file_upload_cubit.dart';
import 'package:pharmacare/features/file_upload/presentation/cubit/file_upload_state.dart';

import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';

class CustomImageUploader extends StatefulWidget {
  final String label;
  final String fileType; // Prescription, LabResult, etc.
  final Function(String url) onUploadSuccess;
  final Function(FileEntity file)? onUploadFileSuccess;
  final String? initialImageUrl;

  const CustomImageUploader({
    super.key,
    required this.label,
    required this.fileType,
    required this.onUploadSuccess,
    this.onUploadFileSuccess,
    this.initialImageUrl,
  });

  @override
  State<CustomImageUploader> createState() => _CustomImageUploaderState();
}

class _CustomImageUploaderState extends State<CustomImageUploader> {
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
        // Auto upload after picking
        if (mounted) {
          context.read<FileUploadCubit>().uploadFile(
                file: _selectedFile!,
                type: widget.fileType,
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileUploadCubit, FileUploadState>(
      listener: (context, state) {
        if (state is FileUploadSuccess) {
          widget.onUploadSuccess(state.file.previewUrl.isNotEmpty ? state.file.previewUrl : state.file.url);
          widget.onUploadFileSuccess?.call(state.file);
        } else if (state is FileUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: state is FileUploadLoading ? null : _showPickerOptions,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: state is FileUploadError
                        ? AppColors.error
                        : AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: _buildContent(state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(FileUploadState state) {
    if (state is FileUploadLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 10),
          Text('Uploading...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      );
    }

    if (_selectedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_selectedFile!, fit: BoxFit.cover),
            if (state is FileUploadSuccess)
              Container(
                color: Colors.black26,
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 50),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, size: 20, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                    context.read<FileUploadCubit>().reset();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
       return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(widget.initialImageUrl!, fit: BoxFit.cover),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 50, color: AppColors.primary.withOpacity(0.5)),
        const SizedBox(height: 10),
        const Text(
          'Tap to upload image',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const Text(
          '(Max size 5MB)',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
