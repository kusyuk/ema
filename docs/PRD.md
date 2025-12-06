# Product Requirements Document (PRD)
## Elderly Medical Appointment (EMA) App

### Version: 1.0
### Date: 2025

---

## 1. Executive Summary

### 1.1 Problem Statement
Most elderly people who attend medical consultations alone struggle with:
- Understanding doctor's explanations, especially when technical/medical terms are used
- Following complex medical instructions
- Accurately sharing consultation information with family members
- Remembering appointment details and follow-up instructions

### 1.2 Solution Overview
EMA is a Flutter mobile application designed to assist elderly patients during medical consultations by:
- Recording and transcribing doctor-patient conversations
- Summarizing medical information in simple, layman's terms
- Providing text-to-speech functionality for accessibility
- Maintaining a comprehensive appointment history with calendar integration
- Enabling easy sharing of consultation summaries with family members

### 1.3 Target Users
- **Primary Users**: Elderly patients (65+ years) attending medical consultations
- **Secondary Users**: Family members who receive shared consultation summaries

---

## 2. Product Feedback & Recommendations

### 2.1 Strengths
✅ **Clear Problem-Solution Fit**: Addresses a real, underserved need in healthcare accessibility
✅ **Comprehensive Feature Set**: Covers recording, transcription, summarization, and history management
✅ **Technology Stack**: Well-chosen tools (Flutter, Hive, Groq) suitable for the use case

### 2.2 Critical Considerations & Recommendations

#### 2.2.1 Privacy & Security
- **HIPAA/GDPR Compliance**: Medical data requires strict privacy controls
- **Recommendation**: 
  - Implement encryption for stored audio files and transcripts
  - Add user consent flows for recording (doctor and patient)
  - Consider local-only processing option (no cloud uploads)
  - Add data retention policies and deletion options

#### 2.2.2 User Experience for Elderly Users
- **Large Text & High Contrast**: Essential for readability
- **Simple Navigation**: Minimal taps, clear icons, large touch targets
- **Voice Prompts**: Audio guidance for key actions
- **Offline Capability**: Ensure core features work without internet
- **Recommendation**: 
  - Minimum font size: 16-18pt
  - High contrast color schemes
  - Simplified UI with maximum 3-4 main screens
  - Haptic feedback for important actions
  - Tutorial/onboarding with voice narration

#### 2.2.3 Technical Considerations
- **Recording Quality**: Ensure clear audio capture in clinical environments
- **Battery Optimization**: Audio recording and processing are resource-intensive
- **Storage Management**: Audio files can be large; implement compression and cleanup
- **Network Resilience**: Handle offline scenarios gracefully
- **Recommendation**:
  - Implement audio compression (e.g., AAC format)
  - Add storage quota management
  - Background processing for transcription
  - Progress indicators for long operations

#### 2.2.4 Feature Enhancements
- **Multi-language Support**: Critical for diverse patient populations
- **Family Sharing**: Secure sharing mechanism (not just export)
- **Medication Reminders**: Integrate with appointment summaries
- **Doctor Profiles**: Save frequently visited doctors
- **Emergency Contacts**: Quick access during appointments
- **Recommendation**: Prioritize multi-language in MVP

---

## 3. Functional Requirements

### 3.1 Core Recording & Transcription Module

#### FR-1: Audio Recording
- **FR-1.1**: User can start/stop/pause audio recording during consultation
- **FR-1.2**: App displays recording status (time elapsed, recording indicator)
- **FR-1.3**: Recorded audio is saved locally to device storage
- **FR-1.4**: Audio files are stored with metadata (timestamp, appointment ID)
- **FR-1.5**: Support for background recording (app minimized)
- **FR-1.6**: Audio quality settings (standard/high quality)
- **Priority**: P0 (Critical)

#### FR-2: Speech-to-Text Transcription
- **FR-2.1**: Transcribe recorded audio using Groq API (Whisper models)
- **FR-2.2**: Display transcription in real-time or post-recording
- **FR-2.3**: Support multiple languages for transcription
- **FR-2.4**: Handle transcription errors gracefully with retry mechanism
- **FR-2.5**: Save raw transcription text locally
- **Priority**: P0 (Critical)

#### FR-3: LLM Summarization
- **FR-3.1**: Send transcribed text to Groq LLM for summarization
- **FR-3.2**: Summarize in layman's terms (non-technical language)
- **FR-3.3**: Support user's preferred language for summary
- **FR-3.4**: Extract key information:
  - Diagnosis/condition
  - Treatment plan
  - Medications prescribed
  - Follow-up instructions
  - Next appointment date (if mentioned)
- **FR-3.5**: Handle API failures with offline fallback message
- **Priority**: P0 (Critical)

#### FR-4: Text-to-Speech
- **FR-4.1**: Read summarized transcription aloud using flutter_tts
- **FR-4.2**: Support multiple languages for TTS
- **FR-4.3**: Adjustable reading speed
- **FR-4.4**: Play/stop controls (pause optional; removed due to plugin limits)
- **FR-4.5**: Highlight text being read (if possible)
- **Priority**: P0 (Critical)

#### FR-5: Data Persistence
- **FR-5.1**: Save complete session data to Hive database:
  - Raw audio file path
  - Raw transcription
  - Summarized transcription
  - Timestamp
  - Appointment association
- **FR-5.2**: Implement data encryption for sensitive information
- **Priority**: P0 (Critical)

### 3.2 Appointment Management Module (calendar-first home + bottom navigation)

#### FR-6: Appointment Creation
- **FR-6.1**: Create new appointment with fields:
  - Date & time (picker implemented)
  - Hospital/clinic name (implemented)
  - Doctor name (implemented)
  - Speciality/Department
  - Remarks/notes (implemented)
  - Location/address (implemented)
- **FR-6.2**: Associate recording with appointment (partial: linked on recording stop; ensure full CRUD linkage)
- **FR-6.3**: Link multiple recordings to single appointment
- **FR-6.4**: Add Appointment via FAB on Home/Calendar tab (calendar-first flow)
- **Priority**: P0 (Critical)

#### FR-7: Appointment History
- **FR-7.1**: Display all appointments in timeline view (History tab)
- **FR-7.2**: Sort by date (newest/oldest first)
- **FR-7.3**: Filter by doctor, hospital, or date range
- **FR-7.4**: Show appointment status (upcoming/past)
- **Priority**: P0 (Critical)

#### FR-8: Appointment Details View
- **FR-8.1**: Display full appointment information
- **FR-8.2**: Show associated recordings with play controls
- **FR-8.3**: Display raw and summarized transcriptions
- **FR-8.4**: Option to re-generate summary
- **Priority**: P0 (Critical)

#### FR-9: Calendar Integration (Home/Calendar tab)
- **FR-9.1**: Display appointments in calendar view (default landing)
- **FR-9.2**: Navigate by month/year
- **FR-9.3**: Highlight dates with appointments; selecting a date filters the list/card below
- **FR-9.4**: “Start Recording” surfaced when within a configurable window of a selected/upcoming appointment
- **Priority**: P1 (High)

#### FR-10: Appointment Reminders
- **FR-10.1**: Set reminders for upcoming appointments
- **FR-10.2**: Configurable reminder timing (1 day, 1 hour before)
- **FR-10.3**: Push notifications for reminders
- **Priority**: P1 (High)

### 3.3 Sharing & Export Module

#### FR-11: Share Functionality
- **FR-11.1**: Share appointment summary via:
  - Text message
  - Email
  - WhatsApp/other messaging apps
  - Export as PDF
- **FR-11.2**: Include in share:
  - Appointment details
  - Summarized transcription
  - Option to include raw transcription
  - Option to include audio file
- **Priority**: P1 (High)

### 3.4 User Interface Requirements (palette unchanged, layout inspired by provided mock)

#### FR-12: Accessibility
- **FR-12.1**: Minimum font size: 16-18pt (configurable up to 24pt)
- **FR-12.2**: High contrast color scheme
- **FR-12.3**: Large touch targets (minimum 44x44 points)
- **FR-12.4**: Clear visual feedback for all actions
- **FR-12.5**: Support for system accessibility settings
- **Priority**: P0 (Critical)

#### FR-13: Navigation
- **FR-13.1**: Simple navigation structure (max 3 levels deep)
- **FR-13.2**: Clear back button/gesture support
- **FR-13.3**: Home screen with quick access to:
  - Start recording
  - View appointments
  - Calendar
- **Priority**: P0 (Critical)

---

## 4. Non-Functional Requirements

### 4.1 Performance
- **NFR-1**: App should launch in < 2 seconds
- **NFR-2**: Recording should start within 1 second
- **NFR-3**: Transcription processing: < 30 seconds for 10-minute recording
- **NFR-4**: Summary generation: < 15 seconds
- **NFR-5**: Smooth scrolling in appointment list (60 FPS)

### 4.2 Reliability
- **NFR-6**: Handle network failures gracefully
- **NFR-7**: Auto-save progress during recording
- **NFR-8**: Retry mechanism for failed API calls
- **NFR-9**: Data backup/recovery mechanism

### 4.3 Security & Privacy
- **NFR-10**: Encrypt sensitive data at rest
- **NFR-11**: Secure API communication (HTTPS)
- **NFR-12**: No data sent to third parties without user consent
- **NFR-13**: User can delete all data at any time
- **NFR-14**: Compliance with local healthcare data regulations

### 4.4 Usability
- **NFR-15**: First-time user can complete core flow in < 5 minutes
- **NFR-16**: Intuitive UI requiring minimal training
- **NFR-17**: Error messages in simple, non-technical language
- **NFR-18**: Offline mode for viewing saved data

### 4.5 Compatibility
- **NFR-19**: Support iOS 13+ and Android API 21+ (Android 5.0+)
- **NFR-20**: Support devices with minimum 2GB RAM
- **NFR-21**: Optimize for screen sizes 4.5" to 7"

---

## 5. Technical Architecture

### 5.1 Architecture Pattern
- **Clean Architecture** with clear separation of concerns:
  - **Presentation Layer**: UI components, state management
  - **Domain Layer**: Business logic, use cases, entities
  - **Data Layer**: Repositories, data sources (local/remote)

### 5.2 Technology Stack

#### Core Framework
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

#### Local Storage
- **Hive**: NoSQL database for structured data (appointments, metadata)
- **File System**: Local storage for audio files

#### External Services
- **Groq API**: LLM for summarization
- **ElevenLabs API**: Speech-to-text transcription

#### Key Packages
- **flutter_tts**: Text-to-speech functionality
- **elevenlabs_flutter_updated**: Speech-to-text integration (updated package)
- **permission_handler**: Audio recording permissions
- **path_provider**: File system access
- **intl**: Date/time formatting
- **share_plus**: Sharing functionality
- **flutter_local_notifications**: Appointment reminders
- **table_calendar**: Calendar view (optional)

### 5.3 Data Models

#### Appointment Entity
```dart
- id: String
- dateTime: DateTime
- hospitalName: String
- doctorName: String
- speciality: String?
- remarks: String?
- location: String?
- recordings: List<Recording>
- createdAt: DateTime
- updatedAt: DateTime
```

#### Recording Entity
```dart
- id: String
- appointmentId: String
- audioFilePath: String
- rawTranscription: String?
- summarizedTranscription: String?
- duration: Duration
- createdAt: DateTime
- language: String
```

### 5.4 API Integration

#### Groq API
- **Endpoint**: Groq API for LLM summarization
- **Authentication**: API key (stored securely)
- **Request**: Transcribed text + language preference
- **Response**: Summarized text in layman's terms

#### ElevenLabs API
- **Endpoint**: ElevenLabs transcription API
- **Authentication**: API key (stored securely)
- **Request**: Audio file
- **Response**: Transcribed text

---

## 6. User Stories

### 6.1 Core User Stories

**US-1**: As an elderly patient, I want to record my consultation so that I can review it later.

**US-2**: As an elderly patient, I want the app to explain medical terms in simple language so that I can understand my diagnosis.

**US-3**: As an elderly patient, I want the app to read the summary aloud so that I don't have to strain my eyes.

**US-4**: As an elderly patient, I want to save my appointment details so that I can remember when to return.

**US-5**: As an elderly patient, I want to share my consultation summary with my family so that they can help me follow instructions.

**US-6**: As a family member, I want to receive a clear summary of my relative's consultation so that I can provide appropriate support.

---

## 7. Success Metrics

### 7.1 User Engagement
- Daily active users
- Number of recordings per user per month
- Appointment history entries per user

### 7.2 Feature Usage
- Percentage of recordings that are transcribed
- Percentage of transcriptions that are summarized
- TTS usage rate
- Sharing frequency

### 7.3 User Satisfaction
- App store ratings (target: 4.5+ stars)
- User feedback on clarity of summaries
- Time to complete core user flows

---

## 8. Out of Scope (Future Considerations)

- Real-time transcription during recording
- Integration with hospital systems
- Medication tracking and reminders
- Health data visualization
- Multi-user accounts (family access)
- Cloud backup/sync
- Doctor portal for verification
- Integration with wearable devices

---

## 9. Assumptions & Dependencies

### 9.1 Assumptions
- Users have smartphones with audio recording capability
- Users have internet connectivity for API calls (with offline fallback)
- Users are comfortable with basic smartphone usage
- Doctors consent to being recorded (user responsibility)
- Groq and ElevenLabs APIs remain available and affordable

### 9.2 Dependencies
- Groq API availability and pricing
- ElevenLabs API availability and pricing
- Flutter framework updates
- Platform permissions (microphone, storage)

---

## 10. Risks & Mitigation

### 10.1 Technical Risks
- **Risk**: API rate limits or costs
  - **Mitigation**: Implement caching, batch processing, local-first approach

- **Risk**: Audio quality in noisy environments
  - **Mitigation**: Noise reduction, audio enhancement, user guidance

- **Risk**: Large storage requirements
  - **Mitigation**: Audio compression, storage management, cleanup tools

### 10.2 User Experience Risks
- **Risk**: Complex UI for elderly users
  - **Mitigation**: Extensive user testing, simplified design, accessibility focus

- **Risk**: Privacy concerns
  - **Mitigation**: Clear consent flows, encryption, transparent data handling

### 10.3 Legal/Compliance Risks
- **Risk**: Recording consent requirements
  - **Mitigation**: Clear consent UI, legal disclaimers, doctor notification

---

## 11. Appendix

### 11.1 Glossary
- **LLM**: Large Language Model
- **TTS**: Text-to-Speech
- **STT**: Speech-to-Text
- **Hive**: NoSQL database for Flutter

### 11.2 References
- ElevenLabs Flutter Package: https://pub.dev/packages/elevenlabs_flutter_updated/install
- Flutter TTS Package: https://pub.dev/packages/flutter_tts
- Groq API Documentation: (to be added)
- Hive Database: https://pub.dev/packages/hive

