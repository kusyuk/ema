import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../constants/env_constants.dart';
import '../network/api_client.dart';
import '../utils/file_storage.dart';
import '../utils/logger.dart';
import '../services/audio_recorder_service.dart';
import '../services/audio_player_service.dart';
import '../../data/datasources/appointment_local_data_source.dart';
import '../../data/datasources/recording_local_data_source.dart';
import '../../data/datasources/groq_remote_data_source.dart';
import '../../data/datasources/groq_transcription_remote_data_source.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../../domain/repositories/summarization_repository.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/recording_repository_impl.dart';
import '../../data/repositories/transcription_repository_impl.dart';
import '../../data/repositories/summarization_repository_impl.dart';
import '../../domain/usecases/appointments/create_appointment.dart';
import '../../domain/usecases/appointments/get_appointments.dart';
import '../../domain/usecases/appointments/get_appointment_by_id.dart';
import '../../domain/usecases/appointments/update_appointment.dart';
import '../../domain/usecases/appointments/delete_appointment.dart';
import '../../domain/usecases/appointments/get_upcoming_appointments.dart';
import '../../domain/usecases/recordings/create_recording.dart';
import '../../domain/usecases/recordings/get_recordings_by_appointment.dart';
import '../../domain/usecases/recordings/update_recording.dart';
import '../../domain/usecases/transcription/transcribe_audio.dart';
import '../../domain/usecases/summarization/summarize_text.dart';
import '../../domain/usecases/recordings/start_recording.dart';
import '../../domain/usecases/recordings/stop_recording.dart';
import '../../domain/usecases/recordings/pause_recording.dart';
import '../../domain/usecases/recordings/resume_recording.dart';
import '../../domain/usecases/recordings/check_recording_permission.dart';
import '../../domain/usecases/recordings/request_recording_permission.dart';
import '../../domain/usecases/recordings/save_transcription_and_summary.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize dependency injection container
Future<void> init() async {
  try {
    Logger.info('Starting dependency injection initialization...');
    
    // Initialize Hive
    Logger.info('Initializing Hive...');
    await Hive.initFlutter();
    Logger.info('Hive initialized successfully');
    
    // Load environment variables
    Logger.info('Loading environment variables...');
    await EnvConstants.load();
    Logger.info('Environment variables loaded');
    
    // Initialize file storage
    Logger.info('Initializing file storage...');
    await FileStorage.initialize();
    Logger.info('File storage initialized');
  
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
  
  // Register audio services
  sl.registerLazySingleton<AudioRecorderService>(
    () => AudioRecorderService(),
  );
  
  sl.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerService(),
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
  
  sl.registerLazySingleton<GroqTranscriptionRemoteDataSource>(
    () => GroqTranscriptionRemoteDataSourceImpl(sl<ApiClient>()),
  );
  
  // Register repositories
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl<AppointmentLocalDataSource>()),
  );
  
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(sl<RecordingLocalDataSource>()),
  );
  
  sl.registerLazySingleton<TranscriptionRepository>(
    () => TranscriptionRepositoryImpl(sl<GroqTranscriptionRemoteDataSource>()),
  );
  
  sl.registerLazySingleton<SummarizationRepository>(
    () => SummarizationRepositoryImpl(sl<GroqRemoteDataSource>()),
  );
  
  // Register use cases - Appointments
  sl.registerLazySingleton<CreateAppointment>(
    () => CreateAppointment(sl<AppointmentRepository>()),
  );
  
  sl.registerLazySingleton<GetAppointments>(
    () => GetAppointments(sl<AppointmentRepository>()),
  );
  
  sl.registerLazySingleton<GetAppointmentById>(
    () => GetAppointmentById(sl<AppointmentRepository>()),
  );
  
  sl.registerLazySingleton<UpdateAppointment>(
    () => UpdateAppointment(sl<AppointmentRepository>()),
  );
  
  sl.registerLazySingleton<DeleteAppointment>(
    () => DeleteAppointment(sl<AppointmentRepository>()),
  );
  
  sl.registerLazySingleton<GetUpcomingAppointments>(
    () => GetUpcomingAppointments(sl<AppointmentRepository>()),
  );
  
  // Register use cases - Recordings
  sl.registerLazySingleton<CreateRecording>(
    () => CreateRecording(sl<RecordingRepository>()),
  );
  
  sl.registerLazySingleton<GetRecordingsByAppointment>(
    () => GetRecordingsByAppointment(sl<RecordingRepository>()),
  );
  
  sl.registerLazySingleton<UpdateRecording>(
    () => UpdateRecording(sl<RecordingRepository>()),
  );
  
  // Register use cases - Transcription
  sl.registerLazySingleton<TranscribeAudio>(
    () => TranscribeAudio(sl<TranscriptionRepository>()),
  );
  
  // Register use cases - Summarization
  sl.registerLazySingleton<SummarizeText>(
    () => SummarizeText(sl<SummarizationRepository>()),
  );
  
  // Register use cases - Recording operations
  sl.registerLazySingleton<StartRecording>(
    () => StartRecording(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<StopRecording>(
    () => StopRecording(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<PauseRecording>(
    () => PauseRecording(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<ResumeRecording>(
    () => ResumeRecording(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<CheckRecordingPermission>(
    () => CheckRecordingPermission(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<RequestRecordingPermission>(
    () => RequestRecordingPermission(sl<AudioRecorderService>()),
  );
  
  sl.registerLazySingleton<SaveTranscriptionAndSummary>(
    () => SaveTranscriptionAndSummary(sl<RecordingRepository>()),
  );
    
    Logger.info('Dependency injection initialization completed successfully');
  } catch (e, stackTrace) {
    Logger.error(
      'Failed to initialize dependency injection',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}


