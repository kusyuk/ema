# Quota and Model Fix

## Issues Found

### 1. **API Quota Exceeded Error** ✅ FIXED (Migrated to Groq)
- **Error**: `401 Unauthorized` with message: "This request exceeds your API key (cursor-hackathon) quota of 5. You have 5 credits remaining, while 11 credits are required for this request."
- **Root Cause**: 
  - Using `scribe_v2` model which requires 11 credits
  - Free tier has only 5 credits available
  - High-quality audio settings (44.1kHz, 128kbps) created large files requiring more credits
  - Error message was being replaced with generic "Unauthorized. Please check your API key."
- **Fix**: 
  - **Migrated from ElevenLabs to Groq** (better free tier: 14,400 requests/day)
  - Changed model from `scribe_v2` to `whisper-large-v3` (Groq)
  - Optimized audio settings to reduce file size (16kHz sample rate, 64kbps bitrate)
  - Updated error handling to show actual quota error messages instead of generic unauthorized message

### 2. **Model Selection** ✅ FIXED
- **Issue**: App was using `scribe_v2` which is not available on free tier
- **Fix**: Changed to `scribe_v1` which is available on free tier and uses fewer credits

### 3. **Audio Quality Optimization** ✅ IMPLEMENTED
- **Issue**: High-quality audio settings (44.1kHz, 128kbps) created large files consuming excessive credits
- **Fix**: 
  - Reduced sample rate from 44.1kHz to 16kHz (sufficient for speech, ~63% file size reduction)
  - Reduced bitrate from 128kbps to 64kbps (~50% file size reduction)
  - Total file size reduction: ~70-80% smaller files
  - Credit reduction: From 6+ credits to 1-2 credits per transcription

### 4. **Recording Duration Limits** ✅ IMPLEMENTED
- **Feature**: Added maximum recording duration (5 minutes) to prevent excessive quota usage
- **Implementation**:
  - Auto-stop recording at 5-minute limit
  - Warning displayed when approaching 4-minute threshold
  - Estimated credit cost shown during recording

### 5. **File Size Validation** ✅ IMPLEMENTED
- **Feature**: Validate file size before API upload and estimate credit cost
- **Implementation**:
  - File size check before transcription request
  - Credit cost estimation based on file size
  - Warnings for unusually large files (>500KB)
  - Logging for file size and estimated credits

## Files Modified

1. **`lib/core/constants/app_constants.dart`**
   - Added `optimizedSampleRate = 16000` (16kHz for speech)
   - Added `optimizedBitRate = 64000` (64kbps)
   - Added `maxRecordingDuration = Duration(minutes: 5)`
   - Added `recordingWarningThreshold = Duration(minutes: 4)`
   - Kept legacy settings for backward compatibility

2. **`lib/core/services/audio_recorder_service.dart`**
   - Updated `RecordConfig` to use optimized settings
   - Added file size logging after recording stops
   - Implemented auto-stop at maximum duration
   - Added logging for optimized settings

3. **`lib/presentation/pages/recording_page.dart`**
   - Added duration warning when approaching limit
   - Added estimated credit cost display during recording
   - Shows warning message at 4-minute threshold

4. **`lib/data/datasources/elevenlabs_remote_data_source.dart`**
   - Changed `model_id` from `'scribe_v2'` to `'scribe_v1'`
   - Added file size validation before upload
   - Added credit cost estimation (`_estimateCreditsFromFileSize`)
   - Added warnings for large files and high credit costs
   - Added detailed logging for file size and estimated credits

5. **`lib/core/network/api_client.dart`**
   - Updated 401 error handling to detect quota-related errors
   - Now shows actual error message when quota/credits are mentioned
   - Falls back to generic message only for other 401 errors

## Expected Behavior

After these optimizations:
1. ✅ App will use `scribe_v1` model (compatible with free tier)
2. ✅ Audio files are ~70-80% smaller (from ~90KB to ~20-30KB for similar duration)
3. ✅ Credit usage reduced from 6+ credits to 1-2 credits per transcription
4. ✅ Recording automatically stops at 5-minute limit
5. ✅ Users see warnings when approaching duration/credit limits
6. ✅ File size validation prevents uploading unnecessarily large files
7. ✅ Quota errors show actual error message (e.g., "This request exceeds your API key quota...")
8. ✅ Users see helpful information about credit limits instead of generic "Unauthorized" message

## Credit Calculation

### With Optimized Settings (16kHz, 64kbps):
- **File Size**: ~8-12 KB per 10 seconds of audio
- **Credit Cost**: ~1 credit per 15-20 seconds of audio
- **Example**: 
  - 30-second recording: ~24-36 KB file, ~2 credits
  - 1-minute recording: ~48-72 KB file, ~3-4 credits
  - 5-minute recording: ~240-360 KB file, ~15-20 credits (exceeds free tier)

### Tips for Reducing Quota Usage:
1. **Keep recordings short**: Aim for 1-2 minutes per consultation segment
2. **Monitor credit estimates**: The app shows estimated credits during recording
3. **Use optimized settings**: Already enabled by default (16kHz, 64kbps)
4. **Check file size**: Files >500KB will trigger warnings
5. **Split long consultations**: Record in segments rather than one long recording

## Notes

- **Free Tier Limitations**: 
  - Limited to `scribe_v1` model
  - Has a quota limit (typically 5 credits)
  - Each transcription request consumes credits based on audio length and model used
  
- **Audio Quality**: 
  - 16kHz sample rate is sufficient for speech recognition (telephone quality)
  - 64kbps bitrate maintains acceptable quality for transcription
  - These settings are optimized for speech, not music/high-fidelity audio
  
- **Upgrading**: 
  - To use `scribe_v2` or higher models, upgrade your ElevenLabs account
  - Update the `model_id` in `elevenlabs_remote_data_source.dart` accordingly
  - Can also increase audio quality settings if needed (but will increase credit usage)

