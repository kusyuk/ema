# Development Todo List
## Elderly Medical Appointment (EMA) App

### Project Status: Development In Progress
### Last Updated: 2025
### Current Phase: Phase 8 - Appointment Management (calendar-first redesign approved; keep current palette)

---

## Development Phases

### Phase 1: Project Setup & Foundation (Week 1-2)

#### 1.1 Project Initialization
- [x] **SETUP-001**: Configure Flutter project structure following Clean Architecture ✅
  - Create folder structure: `lib/core/`, `lib/features/`, `lib/data/`, `lib/domain/`, `lib/presentation/`
  - Set up dependency injection (get_it)
  - Configure environment variables management

- [x] **SETUP-002**: Add core dependencies to `pubspec.yaml` ✅
  - `hive` and `hive_flutter` for local database
  - `flutter_tts` for text-to-speech
  - ~~`elevenlabs_flutter_updated` for speech-to-text~~ (DEPRECATED - Migrated to Groq)
  - `permission_handler` for audio permissions
  - `path_provider` for file system access
  - `dio` for API calls
  - `intl` for date/time formatting
  - `share_plus` for sharing functionality
  - `flutter_local_notifications` for reminders
  - `get_it` for dependency injection
  - `equatable` for value equality
  - `freezed` for immutable classes
  - `flutter_dotenv` for environment variables

- [x] **SETUP-003**: Configure development tools ✅
  - Set up linting rules in `analysis_options.yaml`
  - Configure code formatting
  - Create environment configuration files (`.env`)

- [x] **SETUP-004**: Set up version control ✅
  - Git repository initialized
  - `.gitignore` configured for Flutter
  - `.env` file excluded from version control

#### 1.2 Architecture Foundation
- [x] **ARCH-001**: Implement Clean Architecture layers ✅
  - Created base classes for repositories
  - Set up use cases/interactors structure
  - Defined entity models (Appointment, Recording)
  - Created data source interfaces

- [x] **ARCH-002**: Set up dependency injection container ✅
  - Registered repositories
  - Registered data sources
  - Registered external services (APIs)
  - Use cases registration pending

- [x] **ARCH-003**: Implement error handling ✅
  - Created custom exception classes
  - Set up error handling with Result pattern
  - Implemented error-to-failure mapping
  - Created error logging mechanism (Logger)

- [x] **ARCH-004**: Set up state management ✅
  - Chosen Provider for state management
  - Created base Result pattern for error handling
  - State management patterns ready for implementation

---

### Phase 2: Core Data Layer (Week 2-3)

#### 2.1 Local Database Setup
- [x] **DATA-001**: Configure Hive database ✅
  - Initialize Hive in app
  - Database box configured
  - Database encryption (optional - can be added later)

- [x] **DATA-002**: Create data models ✅
  - `AppointmentModel` (extends Appointment entity)
  - `RecordingModel` (extends Recording entity)
  - Implement to/from JSON methods
  - `UserPreferencesModel` (pending - for future settings)

- [x] **DATA-003**: Implement local data sources ✅
  - `AppointmentLocalDataSource` (CRUD operations)
  - `RecordingLocalDataSource` (audio file management)
  - Implemented caching strategies with Hive

- [x] **DATA-004**: File storage management ✅
  - Created audio file storage service (`FileStorage`)
  - Implemented file naming conventions
  - Created storage cleanup/management tools
  - Implemented storage quota checking
  - File compression utilities (pending - can be added later)

#### 2.2 Repository Implementation
- [x] **REPO-001**: Create repository interfaces (domain layer) ✅
  - `AppointmentRepository`
  - `RecordingRepository`
  - `TranscriptionRepository`
  - `SummarizationRepository`

- [x] **REPO-002**: Implement repositories (data layer) ✅
  - `AppointmentRepositoryImpl` (local data source)
  - `RecordingRepositoryImpl` (local data source)
  - `TranscriptionRepositoryImpl` (remote data source)
  - `SummarizationRepositoryImpl` (remote data source)

---

### Phase 3: External API Integration (Week 3-4)

#### 3.1 API Service Setup
- [x] **API-001**: Configure API clients ✅
  - Set up Groq API client (`GroqRemoteDataSource`)
  - ~~Set up ElevenLabs API client~~ (DEPRECATED - Migrated to Groq)
  - Set up Groq transcription API client (`GroqTranscriptionRemoteDataSource`)
  - Implement API key management (secure storage via `.env`)
  - Created API configuration classes (`ApiClient`)

- [x] **API-002**: Implement Groq integration ✅
  - Created `GroqRemoteDataSourceImpl` class
  - Implemented summarization API call
  - Handle API responses and errors
  - Added request/response logging
  - Retry logic (handled by ApiClient)

- [x] **API-003**: Implement Groq transcription integration ✅ (Migrated from ElevenLabs)
  - Created `GroqTranscriptionRemoteDataSourceImpl` class
  - Implemented speech-to-text API call using Whisper models
  - Handle audio file upload (multipart form data)
  - Process transcription response
  - Added comprehensive logging
  - Retry logic (handled by ApiClient)
  - ~~`ElevenLabsRemoteDataSourceImpl`~~ (DEPRECATED - kept as backup)

- [x] **API-004**: API error handling ✅
  - Handle network failures (NetworkException)
  - Handle API rate limits (ServerException with 429)
  - Handle authentication errors (ServerException with 401)
  - Implemented offline fallback messages
  - Created user-friendly error messages

---

### Phase 4: Domain Layer & Use Cases (Week 4-5)

#### 4.1 Entity Models
- [x] **DOMAIN-001**: Create domain entities ✅
  - `Appointment` entity
  - `Recording` entity
  - `Transcription` entity (embedded in Recording)
  - `Summary` entity (embedded in Recording)
  - `UserPreferences` entity (pending - for future settings)

#### 4.2 Use Cases
- [ ] **USE-001**: Recording use cases
  - `StartRecordingUseCase`
  - `StopRecordingUseCase`
  - `PauseRecordingUseCase`
  - `SaveRecordingUseCase`
  - `DeleteRecordingUseCase`

- [ ] **USE-002**: Transcription use cases
  - `TranscribeAudioUseCase`
  - `GetTranscriptionUseCase`
  - `RetryTranscriptionUseCase`

- [ ] **USE-003**: Summarization use cases
  - `SummarizeTranscriptionUseCase`
  - `GetSummaryUseCase`
  - `RegenerateSummaryUseCase`

- [ ] **USE-004**: Appointment use cases
  - `CreateAppointmentUseCase`
  - `GetAppointmentsUseCase`
  - `GetAppointmentByIdUseCase`
  - `UpdateAppointmentUseCase`
  - `DeleteAppointmentUseCase`
  - `GetUpcomingAppointmentsUseCase`

- [ ] **USE-005**: Text-to-speech use cases
  - `SpeakTextUseCase`
  - `StopSpeakingUseCase`
  - `PauseSpeakingUseCase`
  - `SetSpeakingLanguageUseCase`
  - `SetSpeakingSpeedUseCase`

- [ ] **USE-006**: Sharing use cases
  - `ShareAppointmentUseCase`
  - `ExportAppointmentAsPdfUseCase` (future)

---

### Phase 5: Audio Recording Feature (Week 5-6)

#### 5.1 Audio Recording Service
- [x] **AUDIO-001**: Implement audio recording service ✅
  - Request microphone permissions
  - Initialize audio recorder (`AudioRecorderService`)
  - Implement start/stop/pause/resume functionality
  - Handle recording errors
  - Save audio to local storage
  - Track recording duration with stream

- [x] **AUDIO-002**: Audio quality management ✅
  - Configure audio format (AAC/m4a)
  - Set appropriate sample rate (44.1kHz) and bitrate (128kbps)
  - File naming conventions implemented

- [ ] **AUDIO-003**: Background recording support
  - Implement foreground service (Android)
  - Handle app lifecycle events
  - Maintain recording state
  - Show persistent notification
  - **Note**: Optional for MVP, can be added later

- [x] **AUDIO-004**: Audio playback ✅
  - Implement audio player (`AudioPlayerService`)
  - Create playback controls (play/pause/stop/seek)
  - Display playback progress (streams)
  - Volume and speed control

#### 5.2 Recording UI
- [x] **UI-AUDIO-001**: Recording screen ✅
  - Large record button
  - Recording timer display
  - Visual recording indicator
  - Pause/resume controls
  - Stop and save button
  - Clear error messages
  - Duration stream integration

- [x] **UI-AUDIO-002**: Recording permissions UI ✅
  - Permission request dialog
  - Permission denied handling
  - Permission check on page load

---

### Phase 6: Transcription & Summarization Feature (Week 6-7)

#### 6.1 Transcription Flow
- [x] **TRANS-001**: Transcription service integration ✅
  - Upload audio to Groq (GroqTranscriptionRemoteDataSource) (Migrated from ElevenLabs)
  - Handle transcription completion
  - Save transcription to database (via RecordingRepository)
  - Error handling implemented

- [x] **TRANS-002**: Transcription UI ✅
  - Show transcription progress
  - Display raw transcription (expandable)
  - Retry failed transcriptions
  - Loading states and error handling
  - Automatic navigation after recording

#### 6.2 Summarization Flow
- [x] **SUMM-001**: Summarization service integration ✅
  - Send transcription to Groq (GroqRemoteDataSource)
  - Format prompt for layman's terms
  - Handle language preferences
  - Process summary response
  - Extract key information (diagnosis, treatment, etc.)
  - Save summary to database (via RecordingRepository)

- [x] **SUMM-002**: Summarization UI ✅
  - Show summarization progress
  - Display summarized text
  - Regenerate summary option
  - Loading states and error handling
  - Save functionality integrated

---

### Phase 7: Text-to-Speech Feature (Week 7)

#### 7.1 TTS Implementation
- [x] **TTS-001**: Integrate flutter_tts ✅
  - Initialize TTS engine
  - Configure language support (initial set)
  - Implement speak functionality
  - Handle TTS errors
  - (Optional) Broaden language list

- [x] **TTS-002**: TTS Controls ✅
  - Play/pause/stop functionality
  - Speed adjustment
  - Language selection
  - Pitch adjustment
  - Volume control (optional)

- [x] **TTS-003**: TTS UI ✅
  - TTS control buttons
  - Speed selector
  - Language selector
  - Pitch selector
  - (Optional) Text highlighting / progress indicator

#### 7.2 TTS Polish (Remaining)
- [x] **TTS-004**: Persist TTS settings (language/rate/pitch) ✅
- [ ] **TTS-005**: Expand language list (as needed)
- [ ] **TTS-006**: Refine UX defaults and accessibility cues
- Note: Inline playback + TTS now available on Appointment Detail cards (dialog removed)

---

### Phase 8: Appointment Management (Week 8-9)

#### 8.1 Appointment Data Management
- [x] **APT-001**: Appointment CRUD operations
  - Create appointment with validation (form UI implemented; persist/validate across layers)
  - Save to Hive database
  - Retrieve appointments
  - Update appointment details (UI hooked; ensure persistence)
  - Delete appointment (implemented; cascades recordings/audio)
  - Associate recordings with appointments (ensure recordings show in history; linkage consistent across edit/delete) ✅

- [ ] **APT-002**: Appointment queries
  - Get all appointments
  - Get appointments by date range
  - Get appointments by doctor
  - Get upcoming appointments
  - Sort and filter functionality

#### 8.2 Appointment UI
- [x] **UI-APT-001**: Create appointment screen
  - Date/time picker (large, accessible) ✅
  - Hospital name input ✅
  - Doctor name input ✅
  - Speciality dropdown
  - Remarks text field ✅
  - Location input ✅
  - Save button ✅
  - Form validation (basic) ✅

- [x] **UI-APT-002**: Appointment list screen
  - Timeline view
  - Appointment cards (basic) ✅
  - Date grouping
  - Filter options
  - Search functionality
  - Pull to refresh ✅

- [x] **UI-APT-003**: Appointment detail screen
  - Display all appointment information ✅
  - Show associated recordings ✅
  - Display transcriptions (raw and summarized) ✅
  - Play audio controls ✅
  - Text-to-speech controls (inline, no dialog) ✅
  - Edit appointment option ✅
  - Delete appointment option ✅ (cascades recordings/audio)
  - Share button

- [x] **UI-APT-004**: Calendar-first Home + Bottom Nav
  - Bottom navigation with 3 tabs: Home/Calendar (default), History (timeline), Settings ✅
  - Calendar view highlighting appointment dates; selecting date filters list/card ✅
  - Next Appointment/Selected Day card with inline actions ✅
  - FAB “New Appointment” on Home/Calendar ✅
  - “Start Recording” surfaced when within configurable window of selected/upcoming appointment (use existing recording flow) ✅
  - Keep current EMA palette; mirror layout from provided mock (round cards, high contrast) ✅

- [ ] **UI-APT-004**: Calendar view
  - Month/year navigation
  - Highlight appointment dates
  - Tap date to view appointments
  - Large, accessible calendar UI

---

### Phase 9: Sharing & Export (Week 9-10)

#### 9.1 Sharing Implementation
- [ ] **SHARE-001**: Share service
  - Format appointment data for sharing
  - Include summary text
  - Option to include raw transcription
  - Option to include audio file
  - Generate shareable text/PDF

- [ ] **SHARE-002**: Share UI
  - Share button in appointment detail
  - Share options dialog
  - Select sharing method
  - Preview share content
  - Handle share completion

---

### Phase 10: Reminders & Notifications (Week 10)

#### 10.1 Notification Setup
- [ ] **NOTIF-001**: Configure local notifications
  - Request notification permissions
  - Set up notification channels (Android)
  - Configure notification styles
  - Handle notification taps

- [ ] **NOTIF-002**: Reminder logic
  - Calculate reminder times
  - Schedule notifications
  - Handle notification cancellation
  - Update reminders when appointment changes

- [ ] **NOTIF-003**: Reminder UI
  - Reminder settings in appointment creation
  - Reminder toggle
  - Reminder time selection
  - View scheduled reminders

---

### Phase 11: UI/UX & Accessibility (Week 11-12)

#### 11.1 Accessibility Features
- [ ] **A11Y-001**: Text sizing
  - Minimum 16-18pt font
  - Configurable up to 24pt
  - Respect system font size settings
  - Test with large text enabled

- [ ] **A11Y-002**: High contrast
  - High contrast color scheme
  - Sufficient color contrast ratios (WCAG AA minimum)
  - Dark mode support
  - Test with high contrast mode

- [ ] **A11Y-003**: Touch targets
  - Minimum 44x44 point touch targets
  - Adequate spacing between buttons
  - Test on various screen sizes

- [ ] **A11Y-004**: Screen reader support
  - Semantic labels for all UI elements
  - Screen reader testing
  - Proper focus management

- [ ] **A11Y-005**: Visual feedback
  - Clear button states
  - Loading indicators
  - Success/error messages
  - Haptic feedback (where appropriate)

#### 11.2 Navigation & Layout
- [ ] **UI-NAV-001**: Main navigation
  - Bottom navigation bar (simple, 3-4 items)
  - Home screen
  - Appointments screen
  - Settings screen
  - Clear navigation hierarchy

- [ ] **UI-NAV-002**: Home screen
  - Large "Start Recording" button
  - Quick access to recent appointments
  - Upcoming appointments widget
  - Clear, uncluttered design

- [ ] **UI-NAV-003**: Settings screen
  - Language selection
  - Text size adjustment
  - Notification preferences
  - Storage management
  - About/Help section
  - Privacy settings

#### 11.3 Onboarding & Help
- [ ] **UI-ONB-001**: First-time user onboarding
  - Welcome screen
  - Feature introduction
  - Permission requests
  - Basic tutorial
  - Skip option

- [ ] **UI-HELP-001**: Help & documentation
  - In-app help section
  - FAQ
  - Contact support option
  - Tutorial videos (optional)

---

### Phase 12: Testing & Quality Assurance (Week 12-13)

#### 12.1 Unit Testing
- [ ] **TEST-001**: Domain layer tests
  - Test use cases
  - Test entity models
  - Test business logic

- [ ] **TEST-002**: Data layer tests
  - Test repositories
  - Test data sources
  - Test data models
  - Mock API responses

- [ ] **TEST-003**: Service tests
  - Test API services
  - Test audio services
  - Test TTS services

#### 12.2 Widget Testing
- [ ] **TEST-004**: UI component tests
  - Test key screens
  - Test user interactions
  - Test form validation
  - Test navigation

#### 12.3 Integration Testing
- [ ] **TEST-005**: End-to-end flows
  - Complete recording flow
  - Complete appointment creation flow
  - Complete sharing flow
  - Test error scenarios

#### 12.4 Manual Testing
- [ ] **TEST-006**: Device testing
  - Test on various Android devices
  - Test on various iOS devices
  - Test different screen sizes
  - Test with accessibility features enabled

- [ ] **TEST-007**: User acceptance testing
  - Test with elderly users (if possible)
  - Gather feedback
  - Iterate on UX issues

---

### Phase 13: Performance Optimization (Week 13-14)

#### 13.1 Performance Improvements
- [ ] **PERF-001**: App performance
  - Optimize app startup time
  - Reduce memory usage
  - Optimize database queries
  - Implement lazy loading

- [ ] **PERF-002**: Audio optimization
  - Optimize audio compression
  - Reduce file sizes
  - Implement background processing
  - Optimize playback performance

- [ ] **PERF-003**: Network optimization
  - Implement request caching
  - Batch API calls where possible
  - Optimize payload sizes
  - Handle slow networks gracefully

- [ ] **PERF-004**: Storage optimization
  - Implement storage cleanup
  - Compress old recordings
  - Add storage usage display
  - Warn when storage is low

---

### Phase 14: Security & Privacy (Week 14)

#### 14.1 Security Implementation
- [ ] **SEC-001**: Data encryption
  - Encrypt sensitive data in Hive
  - Encrypt audio files (optional)
  - Secure API key storage
  - Implement secure communication (HTTPS)

- [ ] **SEC-002**: Privacy features
  - User consent flows
  - Privacy policy display
  - Data deletion functionality
  - Clear data retention policy

- [ ] **SEC-003**: Permission handling
  - Proper permission requests
  - Permission denied handling
  - Permission rationale explanations

---

### Phase 15: Documentation & Deployment Prep (Week 15)

#### 15.1 Documentation
- [ ] **DOC-001**: Code documentation
  - Add code comments
  - Document public APIs
  - Create architecture diagrams
  - Document setup instructions

- [ ] **DOC-002**: User documentation
  - User manual
  - Quick start guide
  - FAQ document
  - Video tutorials (optional)

#### 15.2 Deployment Preparation
- [ ] **DEPLOY-001**: App configuration
  - Set up app icons
  - Configure app name and description
  - Set up app versioning
  - Configure app signing

- [ ] **DEPLOY-002**: Store preparation
  - Prepare app store listings
  - Create screenshots
  - Write app descriptions
  - Prepare privacy policy
  - Prepare terms of service

- [ ] **DEPLOY-003**: Beta testing
  - Set up beta testing channels
  - Distribute to testers
  - Collect feedback
  - Fix critical issues

---

## Priority Legend

- **P0 (Critical)**: Must have for MVP
- **P1 (High)**: Important for MVP, can be simplified
- **P2 (Medium)**: Nice to have, can be added post-MVP
- **P3 (Low)**: Future enhancement

## Notes

- Estimated timeline: 15 weeks for full implementation
- MVP can be achieved in ~10 weeks focusing on P0 items
- Regular testing and user feedback should be incorporated throughout
- Consider breaking into smaller releases for iterative delivery

## Dependencies Between Phases

- Phase 1 must complete before all others
- Phase 2 should complete before Phase 3
- Phase 3 should complete before Phase 4
- Phase 4 should complete before Phase 5-9
- Phase 11 (UI/UX) can run parallel with Phase 5-10
- Phase 12-15 should come after core features are complete

