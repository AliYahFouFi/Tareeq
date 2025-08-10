# API Key Security Guidelines

## Important Security Notice

This project uses external APIs that require API keys. To maintain security:

### 🚨 Never commit actual API keys to version control!

## Setup Instructions

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual API keys in `.env`:**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Replace `your_google_maps_api_key_here` with your actual key

3. **Update `lib/const.dart` for development:**
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual Google Maps API key
   - **Remember**: Never commit this file with real keys!

## Production Deployment

For production environments, use:
- Environment variables
- Firebase Remote Config
- Secure secret management services
- Build-time configuration injection

## Files to Keep Secure

- `lib/const.dart` - Contains API key constants
- `.env` - Environment variables (already in .gitignore)
- Any files containing sensitive configuration

## What's Already Protected

The repository is configured to ignore sensitive files:
- `.env` and `*.env` files are ignored
- `lib/const.dart` is ignored to prevent accidental commits of API keys

## Emergency: If You Accidentally Commit API Keys

1. **Immediately revoke/regenerate the API keys** in your provider's console
2. Update your local files with new keys
3. Consider using `git filter-branch` or BFG Repo-Cleaner to remove from history
4. Force push the cleaned history (if safe to do so)