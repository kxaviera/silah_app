# Environment Variables Setup Guide

## ✅ .env File Created

The `.env` file has been created in the Backend directory with all required environment variables.

## 📋 Required Environment Variables

### Server Configuration
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
- `FRONTEND_URL` - Frontend URL for CORS

### Database
- `MONGODB_URI` - MongoDB connection string

### Authentication
- `JWT_SECRET` - Secret key for user JWT tokens
- `JWT_EXPIRE` - JWT expiration time (default: 7d)
- `ADMIN_JWT_SECRET` - Secret key for admin JWT tokens
- `ADMIN_JWT_EXPIRE` - Admin JWT expiration time (default: 24h)

### Google OAuth
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret

### Payment (Stripe)
- `STRIPE_SECRET_KEY` - Stripe secret key
- `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key
- `STRIPE_WEBHOOK_SECRET` - Stripe webhook secret

### Email (SendGrid)
- `SENDGRID_API_KEY` - SendGrid API key
- `SENDGRID_FROM_EMAIL` - Default sender email

### SMS (Twilio)
- `TWILIO_ACCOUNT_SID` - Twilio account SID
- `TWILIO_AUTH_TOKEN` - Twilio auth token
- `TWILIO_PHONE_NUMBER` - Twilio phone number

### File Upload (Choose one)
**Cloudinary:**
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

**AWS S3:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_BUCKET_NAME`
- `AWS_REGION`

### Company Details
- `COMPANY_NAME` - Company name for invoices
- `COMPANY_GSTIN` - GST number
- `COMPANY_EMAIL` - Support email
- `COMPANY_PHONE` - Support phone
- `COMPANY_ADDRESS` - Company address

## 🔧 Next Steps

1. **Open `.env` file** in `D:\Silah\Backend\.env`

2. **Replace placeholder values** with your actual credentials:
   - Generate JWT secrets: `openssl rand -base64 32`
   - Set up MongoDB (local or Atlas)
   - Configure Google OAuth (if using Google Sign-In)
   - Set up Stripe (if using payments)
   - Configure SendGrid (if using emails)
   - Configure Twilio (if using SMS)
   - Set up Cloudinary or AWS S3 (for file uploads)

3. **For Production:**
   - Use strong, unique secrets
   - Never commit `.env` to Git (already in `.gitignore`)
   - Use environment variables from your hosting provider
   - Enable HTTPS
   - Use secure MongoDB connections

## 🔒 Security Notes

- ✅ `.env` is already in `.gitignore`
- ⚠️ Never share your `.env` file
- ⚠️ Use different secrets for development and production
- ⚠️ Rotate secrets regularly
- ⚠️ Use environment variables in production hosting

## 📝 Quick Start

1. **Minimum required for local development:**
   ```env
   MONGODB_URI=mongodb://localhost:27017/silah
   JWT_SECRET=your-secret-key-here
   ADMIN_JWT_SECRET=your-admin-secret-key-here
   ```

2. **Generate secure secrets:**
   ```bash
   # On Windows PowerShell:
   [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
   
   # On Linux/Mac:
   openssl rand -base64 32
   ```

3. **Start the server:**
   ```bash
   npm run dev
   ```

## 🆘 Troubleshooting

### "MongoDB connection error"
- Make sure MongoDB is running locally
- Or update `MONGODB_URI` with your MongoDB Atlas connection string

### "JWT secret not configured"
- Make sure `JWT_SECRET` and `ADMIN_JWT_SECRET` are set in `.env`
- Restart the server after updating `.env`

### "SendGrid/Twilio not configured"
- These are optional for development
- The app will work without them, but email/SMS features won't function
- See `EMAIL_SMS_SETUP.md` for setup instructions
