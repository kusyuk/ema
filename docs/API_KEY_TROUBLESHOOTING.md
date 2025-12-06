# API Key Troubleshooting Guide

## Current Issue
Getting "Unauthorized. Please check your API key." error from ElevenLabs API.

## Verification Steps

### 1. Check .env File Format
Your `.env` file should have:
```
ELEVENLABS_API_KEY=sk_your_actual_api_key_here
```

**Important:**
- No spaces around the `=` sign
- No quotes around the value
- Key should start with `sk_`
- Make sure there are no extra spaces or newlines

### 2. Verify API Key is Loaded
Check the logs for:
```
[INFO] EMA: API key check: PRESENT (XX chars)
```

If it says "MISSING", the .env file is not being loaded correctly.

### 3. Verify API Key Format
The logs will now show:
- If the key starts with `sk_` (correct format)
- The length of the key
- A masked version (first 4 and last 4 characters)

### 4. Check API Key Validity
The ElevenLabs API key should:
- Start with `sk_`
- Be obtained from your ElevenLabs account dashboard
- Have the correct permissions for speech-to-text API
- Not be expired or revoked

### 5. Common Issues

#### Issue: API Key Not Found
**Symptoms:** Logs show "MISSING" for API key
**Solutions:**
- Verify `.env` file exists in project root
- Check file name is exactly `.env` (not `.env.txt` or similar)
- Ensure `ELEVENLABS_API_KEY=` is on a new line
- Restart the app after modifying .env

#### Issue: API Key Format Wrong
**Symptoms:** Logs show warning "API key does not start with 'sk_'"
**Solutions:**
- Verify the key starts with `sk_`
- Check for extra spaces or quotes in .env file
- Copy the key directly from ElevenLabs dashboard

#### Issue: Unauthorized Error
**Symptoms:** API returns 401 Unauthorized
**Solutions:**
- Verify the API key is correct in ElevenLabs dashboard
- Check if the API key has speech-to-text permissions
- Generate a new API key if needed
- Ensure you're using the correct API key (not a different service's key)

### 6. Testing API Key
You can test your API key using curl:
```bash
curl -X POST "https://api.elevenlabs.io/v1/speech-to-text" \
  -H "xi-api-key: YOUR_API_KEY_HERE" \
  -F "file=@test_audio.m4a" \
  -F "model_id=scribe_v2"
```

### 7. Next Steps
1. Check the logs for the masked API key format
2. Verify the key starts with `sk_`
3. If the key format is wrong, update the .env file
4. If the key is correct but still unauthorized, check your ElevenLabs account
5. Consider generating a new API key from ElevenLabs dashboard

