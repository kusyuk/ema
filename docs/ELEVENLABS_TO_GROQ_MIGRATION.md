# ElevenLabs to Groq Migration

## Overview
This document describes the migration from ElevenLabs API to Groq API for speech-to-text transcription functionality.

## Migration Date
2025

## Reasons for Migration

### 1. **Better Free Tier Limits**
- **ElevenLabs**: 5 credits total (very limited, ~1-2 transcriptions)
- **Groq**: 14,400 requests/day (much more generous)

### 2. **Single API Provider**
- Both transcription and summarization now use Groq
- Simplified architecture and API key management
- Reduced dependencies

### 3. **Cost Reduction**
- No quota issues with Groq's generous free tier
- Better scalability for future growth

### 4. **Performance**
- Groq's fast inference speed
- High-quality Whisper models

## Technical Changes

### Files Modified

1. **`lib/data/datasources/groq_transcription_remote_data_source.dart`** (NEW)
   - New data source implementation using Groq's Whisper API
   - Uses `whisper-large-v3` model
   - Endpoint: `https://api.groq.com/openai/v1/audio/transcriptions`

2. **`lib/data/repositories/transcription_repository_impl.dart`**
   - Updated to use `GroqTranscriptionRemoteDataSource` instead of `ElevenLabsRemoteDataSource`
   - No changes to domain interface

3. **`lib/core/di/injection_container.dart`**
   - Removed `ElevenLabsRemoteDataSource` registration
   - Added `GroqTranscriptionRemoteDataSource` registration
   - Updated `TranscriptionRepository` to use Groq data source

4. **`lib/core/constants/app_constants.dart`**
   - Deprecated `elevenlabsBaseUrl` constant
   - Using existing `groqBaseUrl` for both transcription and summarization

5. **`lib/core/constants/env_constants.dart`**
   - Deprecated `elevenlabsApiKey` getter
   - Only `groqApiKey` needed now

6. **`pubspec.yaml`**
   - Removed `elevenlabs_flutter_updated: ^0.0.1` dependency

### Files Deprecated (Not Deleted)

- **`lib/data/datasources/elevenlabs_remote_data_source.dart`**
  - Kept as backup/fallback option
  - Can be deleted after confirming migration success

## API Differences

### ElevenLabs API
- Endpoint: `https://api.elevenlabs.io/v1/speech-to-text`
- Authentication: `xi-api-key` header
- Model: `scribe_v1` (free tier)
- Response: `{ "text": "..." }`
- Credits: Limited (5 credits total)

### Groq API
- Endpoint: `https://api.groq.com/openai/v1/audio/transcriptions`
- Authentication: `Authorization: Bearer <token>` header
- Model: `whisper-large-v3` or `whisper-large-v3-turbo`
- Response: `{ "text": "..." }` (OpenAI-compatible format)
- Rate Limits: 30 RPM, 14,400 RPD (free tier)

## Breaking Changes

### None
- The domain layer interface remains unchanged
- Repository interface unchanged
- No changes required in presentation layer
- Same audio file formats supported

## Migration Steps for Users

1. **Update `.env` file**:
   - Remove `ELEVENLABS_API_KEY` (no longer needed)
   - Ensure `GROQ_API_KEY` is set (already required for summarization)

2. **Run `flutter pub get`**:
   - Removes ElevenLabs dependency
   - Updates package dependencies

3. **Test transcription**:
   - Record a short audio clip
   - Verify transcription works with Groq
   - Check logs for any errors

## Benefits

1. ✅ **No more quota issues**: 14,400 requests/day vs 5 credits total
2. ✅ **Simplified setup**: Only one API key needed (Groq)
3. ✅ **Better performance**: Groq's fast inference
4. ✅ **Cost effective**: Generous free tier
5. ✅ **Unified architecture**: Single API provider for both transcription and summarization

## Troubleshooting

### Issue: "Groq API key not configured"
**Solution**: Ensure `GROQ_API_KEY` is set in `.env` file

### Issue: "Empty transcription response"
**Solution**: Check audio file format (must be supported: m4a, mp3, wav, flac, etc.)

### Issue: "File size too large"
**Solution**: Groq has a 25MB limit per file. Use optimized recording settings (16kHz, 64kbps)

### Issue: Rate limit errors (429)
**Solution**: Groq free tier has 30 RPM limit. Wait a minute and retry, or upgrade to paid tier

## Rollback Plan

If issues occur, you can rollback by:

1. Revert `transcription_repository_impl.dart` to use `ElevenLabsRemoteDataSource`
2. Revert `injection_container.dart` to register ElevenLabs data source
3. Re-add `elevenlabs_flutter_updated` to `pubspec.yaml`
4. Run `flutter pub get`
5. Restore `ELEVENLABS_API_KEY` in `.env` file

## Testing Checklist

- [x] Create Groq transcription data source
- [x] Update transcription repository
- [x] Update dependency injection
- [x] Remove ElevenLabs dependency
- [x] Update documentation
- [ ] Test with short audio file (< 30 seconds)
- [ ] Test with longer audio file (1-2 minutes)
- [ ] Test error handling
- [ ] Test full flow: Record → Transcribe → Summarize
- [ ] Verify logging works correctly

## Notes

- Groq uses Whisper models which are highly accurate for speech recognition
- Audio files are automatically downsampled to 16kHz mono by Groq
- Supported formats: `flac`, `mp3`, `mp4`, `mpeg`, `mpga`, `m4a`, `ogg`, `wav`, `webm`
- File size limit: 25MB per request
- Response format is OpenAI-compatible, making it easy to switch if needed

