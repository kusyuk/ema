import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'logger.dart';

/// File storage utility for managing audio files
class FileStorage {
  FileStorage._();

  static Directory? _audioDirectory;

  /// Initialize audio storage directory
  static Future<void> initialize() async {
    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      _audioDirectory = Directory('${appDocumentsDir.path}/${AppConstants.audioStoragePath}');
      
      if (!await _audioDirectory!.exists()) {
        await _audioDirectory!.create(recursive: true);
        Logger.info('Audio storage directory created');
      }
    } catch (e) {
      Logger.error('Failed to initialize audio storage', error: e);
      throw CacheException('Failed to initialize audio storage: ${e.toString()}');
    }
  }

  /// Get audio storage directory
  static Directory getAudioDirectory() {
    if (_audioDirectory == null) {
      throw const CacheException('Audio storage not initialized. Call initialize() first.');
    }
    return _audioDirectory!;
  }

  /// Get full path for audio file
  static String getAudioFilePath(String fileName) {
    return '${getAudioDirectory().path}/$fileName';
  }

  /// Save audio file
  static Future<File> saveAudioFile(String fileName, List<int> bytes) async {
    try {
      final file = File(getAudioFilePath(fileName));
      await file.writeAsBytes(bytes);
      Logger.info('Audio file saved: $fileName');
      return file;
    } catch (e) {
      Logger.error('Failed to save audio file', error: e);
      throw CacheException('Failed to save audio file: ${e.toString()}');
    }
  }

  /// Get audio file
  static File getAudioFile(String fileName) {
    final file = File(getAudioFilePath(fileName));
    if (!file.existsSync()) {
      throw CacheException('Audio file not found: $fileName');
    }
    return file;
  }

  /// Delete audio file
  static Future<void> deleteAudioFile(String fileName) async {
    try {
      final file = File(getAudioFilePath(fileName));
      if (await file.exists()) {
        await file.delete();
        Logger.info('Audio file deleted: $fileName');
      }
    } catch (e) {
      Logger.error('Failed to delete audio file', error: e);
      throw CacheException('Failed to delete audio file: ${e.toString()}');
    }
  }

  /// Get storage size in bytes
  static Future<int> getStorageSize() async {
    try {
      final directory = getAudioDirectory();
      if (!await directory.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      Logger.error('Failed to calculate storage size', error: e);
      return 0;
    }
  }

  /// Get formatted storage size
  static Future<String> getFormattedStorageSize() async {
    final bytes = await getStorageSize();
    if (bytes < 1024) {
      return '${bytes.toString()} B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Clean up old files (optional - for future implementation)
  static Future<void> cleanupOldFiles({int daysOld = 90}) async {
    try {
      final directory = getAudioDirectory();
      if (!await directory.exists()) {
        return;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      await for (final entity in directory.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            Logger.info('Deleted old audio file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      Logger.error('Failed to cleanup old files', error: e);
    }
  }
}

