# Firebase to Firestore Sync Function

This Vercel serverless function continuously syncs data from Firebase Realtime Database to Firestore collections, creating historical records every minute.

## Features

- ✅ Syncs data from Realtime Database to Firestore every minute
- ✅ Creates separate collections for each variable (oxygen_flow, oxygen_pressure, oxygen_purity, running_hours, temp_1)
- ✅ Stores timestamp with each record
- ✅ Automatic cleanup of old records (keeps last 1000 documents per collection)
- ✅ Error handling and logging
- ✅ Works independently of your Flutter app
- ✅ Serverless deployment on Vercel

## Setup Instructions

### 1. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`node-red-75bfc`)
3. Go to **Project Settings** > **Service Accounts**
4. Click **"Generate new private key"**
5. Download the JSON file and keep it safe

### 2. Environment Variables Setup

1. Copy `.env.example` to `.env`
2. Fill in the values from your Firebase service account JSON:

```bash
cp .env.example .env
```

3. Edit `.env` with your Firebase credentials:
   - `FIREBASE_PROJECT_ID`: Your project ID (node-red-75bfc)
   - `FIREBASE_PRIVATE_KEY`: The private key from the JSON file
   - `FIREBASE_CLIENT_EMAIL`: The client email from the JSON file
   - `FIREBASE_DATABASE_URL`: Your Realtime Database URL

### 3. Install Dependencies

```bash
npm install
```

### 4. Deploy to Vercel

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy the function:
```bash
vercel --prod
```

4. Set environment variables in Vercel:
   - Go to your Vercel dashboard
   - Select your project
   - Go to Settings > Environment Variables
   - Add all the environment variables from your `.env` file

### 5. Enable Cron Jobs

The function is configured to run every minute using Vercel's cron jobs. Make sure you have a Pro plan on Vercel to use cron jobs, or manually trigger the function using webhooks.

## How It Works

1. **Data Sync**: Every minute, the function reads current data from your Realtime Database
2. **Firestore Storage**: Creates new documents in 5 separate collections:
   - `oxygen_flow` collection
   - `oxygen_pressure` collection  
   - `oxygen_purity` collection
   - `running_hours` collection
   - `temp_1` collection

3. **Document Structure**:
```json
{
  "value": 25.5,
  "timestamp": "2024-01-01T12:00:00Z",
  "created_at": "2024-01-01T12:00:00.000Z"
}
```

4. **Cleanup**: Automatically removes old documents to keep only the last 1000 records per collection

## Testing

You can test the function locally:

```bash
npm run dev
```

Then visit `http://localhost:3000/api/sync` to trigger the sync manually.

## Monitoring

- Check Vercel's function logs for sync status
- Monitor Firestore console to see new documents being created
- The function logs detailed information about each sync operation

## Troubleshooting

### Common Issues

1. **"Error initializing Firebase Admin"**
   - Check your environment variables
   - Ensure the private key is properly formatted with `\n` characters

2. **"Permission denied"**
   - Verify your service account has Firestore and Realtime Database permissions
   - Check Firebase rules

3. **"Function timeout"**
   - The function has a 5-minute timeout limit
   - If sync takes too long, consider optimizing the data structure

### Environment Variables Format

Make sure your `FIREBASE_PRIVATE_KEY` includes the full private key with proper line breaks:

```
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
```

## Security

- Never commit your `.env` file to version control
- Use Vercel's environment variables for production
- Ensure your Firebase service account has minimal required permissions

## Cost Considerations

- Vercel Pro plan required for cron jobs ($20/month)
- Firebase Firestore charges per read/write operation
- Consider the frequency of updates based on your usage needs

## Support

If you encounter issues:
1. Check the Vercel function logs
2. Verify your Firebase permissions
3. Test the function locally first
4. Ensure all environment variables are set correctly 