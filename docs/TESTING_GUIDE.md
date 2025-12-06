# Testing Guide - EMA App

## Current Features Available for Testing

### ✅ Implemented Features

1. **Home Page** - Main entry point
2. **Recording Page** - Audio recording functionality
3. **Transcription Page** - Audio transcription and summarization
4. **Appointments Page** - View appointment history

---

## How to Test

### 1. **Home Page**
- **Location**: Main screen when app launches
- **Features**:
  - Large "Start Recording" button
  - "View Appointments" button
  - Welcome message

**Test Steps**:
1. Launch the app
2. You should see the home page with two main buttons
3. Verify buttons are large and easy to tap (elderly-friendly design)

---

### 2. **Recording Feature**
- **Access**: Tap "Start Recording" from home page
- **Features**:
  - Microphone permission request
  - Start/Stop/Pause/Resume recording
  - Recording timer display
  - Visual recording indicator

**Test Steps**:
1. From home page, tap "Start Recording"
2. Grant microphone permission when prompted
3. Tap the large record button to start recording
4. Speak for a few seconds (e.g., "This is a test recording")
5. Tap "Stop" to finish recording
6. App should automatically navigate to transcription page

**Expected Behavior**:
- Permission request appears if not granted
- Recording button changes to stop button when recording
- Timer displays elapsed time
- Red indicator shows recording is active
- After stopping, navigates to transcription page

---

### 3. **Transcription & Summarization**
- **Access**: Automatically appears after stopping a recording
- **Features**:
  - Automatic transcription of audio
  - Progress indicator during transcription
  - Automatic summarization in layman's terms
  - Display of raw transcription and summary
  - Save functionality
  - Retry options for errors

**Test Steps**:
1. After stopping a recording, transcription page appears
2. Wait for transcription to complete (shows progress)
3. Transcription text appears
4. Summary is automatically generated
5. Review the summary (should be in simple language)
6. Tap "Save" to save the recording and summary

**Expected Behavior**:
- Progress indicator shows during transcription
- Raw transcription displays in expandable section
- Summary appears below transcription
- Summary uses simple, non-technical language
- Save button saves to database
- Error handling with retry options

---

### 4. **Appointments Page**
- **Access**: Tap "View Appointments" from home page
- **Features**:
  - List of all appointments
  - Appointment details (doctor, hospital, date/time)
  - Recording count per appointment
  - Pull to refresh
  - Empty state message

**Test Steps**:
1. From home page, tap "View Appointments"
2. If no appointments exist, see empty state
3. After creating a recording, return here to see the appointment
4. Pull down to refresh the list
5. Tap on an appointment card (details page coming soon)

**Expected Behavior**:
- Shows all saved appointments
- Displays appointment information clearly
- Shows number of recordings per appointment
- Empty state when no appointments exist
- Refresh functionality works

---

## Testing Flow

### Complete End-to-End Test:

1. **Launch App** → Home page appears
2. **Start Recording** → Tap "Start Recording"
3. **Grant Permission** → Allow microphone access
4. **Record Audio** → Speak for 10-30 seconds
5. **Stop Recording** → Tap stop button
6. **View Transcription** → Wait for transcription to complete
7. **Review Summary** → Check that summary is in simple language
8. **Save Recording** → Tap save button
9. **View Appointments** → Go back and check appointments page
10. **Verify Data** → Confirm appointment appears in list

---

## Known Limitations

- **Appointment Details Page**: Not yet implemented (shows snackbar)
- **Text-to-Speech**: Not yet implemented (Phase 7)
- **Appointment Creation Form**: Not yet implemented
- **Settings Page**: Not yet implemented

---

## Troubleshooting

### App Stuck on Flutter Logo
- ✅ **Fixed**: Initialization issues resolved
- If it happens again, check logs: `flutter logs`

### Permission Denied
- Go to device settings → Apps → EMA → Permissions
- Enable microphone permission
- Restart the app

### Transcription Fails
- Check internet connection
- Verify API keys in `.env` file
- Check logs for error messages
- Use retry button on transcription page

### No Appointments Showing
- Create a recording first (appointments are created when recording is saved)
- Pull down to refresh the appointments list
- Check if recording was saved successfully

---

## Next Features to Test (Coming Soon)

- **Phase 7**: Text-to-Speech feature
- **Phase 8**: Appointment management (create, edit, delete)
- **Phase 9**: Sharing functionality
- **Phase 10**: Notifications and reminders

---

## Feedback

When testing, please note:
- Any UI elements that are too small
- Any confusing navigation
- Any errors or crashes
- Any features that don't work as expected
- Suggestions for improvement

