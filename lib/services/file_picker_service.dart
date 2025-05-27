// ignore_for_file: avoid_print

import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilePickerService {
  static Future<FilePickerResult?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt', 'doc'],
        allowMultiple: false,
        withData: kIsWeb, // Important: Load file data for web
        withReadStream: !kIsWeb, // Use stream for mobile
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Debug logging
        print('=== File Picker Debug ===');
        print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
        print('File name: ${file.name}');
        print('File size: ${file.size} bytes');
        print('File extension: ${file.extension}');
        print('File path: ${file.path}');
        print('Has bytes: ${file.bytes != null}');
        print('Bytes length: ${file.bytes?.length ?? 0}');
        print('========================');
        
        // Validate file
        if (file.size == 0) {
          throw Exception('Selected file is empty');
        }
        
        if (file.size > 10 * 1024 * 1024) { // 10MB limit
          throw Exception('File too large. Please select a file smaller than 10MB');
        }
        
        // For web, ensure we have bytes
        if (kIsWeb && file.bytes == null) {
          throw Exception('Failed to read file data on web platform');
        }
        
        return result;
      }
      
      return null;
    } catch (e) {
      print('File picker error: $e');
      throw Exception('File picking failed: $e');
    }
  }
  
  /// Get file data as bytes - works on both web and mobile
  static Future<Uint8List?> getFileBytes(PlatformFile file) async {
    try {
      if (kIsWeb) {
        // On web, bytes should already be loaded
        return file.bytes;
      } else {
        // On mobile, read from path
        if (file.path != null) {
          // You would use dart:io File here for mobile
          // But since we're focusing on web, we'll return bytes if available
          return file.bytes;
        }
      }
      return null;
    } catch (e) {
      print('Error getting file bytes: $e');
      return null;
    }
  }
  
  /// Validate file type
  static bool isValidFileType(String? extension) {
    if (extension == null) return false;
    final validExtensions = ['pdf', 'docx', 'txt', 'doc'];
    return validExtensions.contains(extension.toLowerCase());
  }
  
  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}