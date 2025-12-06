import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../constants/env_constants.dart';
import '../network/api_client.dart';
import '../utils/file_storage.dart';
import '../../data/datasources/appointment_local_data_source.dart';
import '../../data/datasources/recording_local_data_source.dart';
import '../../data/datasources/groq_remote_data_source.dart';
import '../../data/datasources/elevenlabs_remote_data_source.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../../domain/repositories/summarization_repository.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/recording_repository_impl.dart';
import '../../data/repositories/transcription_repository_impl.dart';
import '../../data/repositories/summarization_repository_impl.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize dependency injection container
Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Load environment variables
  await EnvConstants.load();
  
  // Initialize file storage
  await FileStorage.initialize();
  
  // Register core services
  
  // Register Dio instance
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    ),
  );
  
  // Register API clients
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<Dio>()),
  );
  
  // Register Hive box
  final box = await Hive.openBox(AppConstants.hiveBoxName);
  sl.registerLazySingleton<Box<dynamic>>(
    () => box,
  );
  
  // Register data sources
  sl.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(sl<Box<dynamic>>()),
  );
  
  sl.registerLazySingleton<RecordingLocalDataSource>(
    () => RecordingLocalDataSourceImpl(sl<Box<dynamic>>()),
  );
  
  // Register remote data sources
  sl.registerLazySingleton<GroqRemoteDataSource>(
    () => GroqRemoteDataSourceImpl(sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<ElevenLabsRemoteDataSource>(
    () => ElevenLabsRemoteDataSourceImpl(sl<ApiClient>()),
  );
  
  // Register repositories
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl<AppointmentLocalDataSource>()),
  );
  
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(sl<RecordingLocalDataSource>()),
  );
  
  sl.registerLazySingleton<TranscriptionRepository>(
    () => TranscriptionRepositoryImpl(sl<ElevenLabsRemoteDataSource>()),
  );
  
  sl.registerLazySingleton<SummarizationRepository>(
    () => SummarizationRepositoryImpl(sl<GroqRemoteDataSource>()),
  );
  
  // TODO: Register use cases as they are created
}

