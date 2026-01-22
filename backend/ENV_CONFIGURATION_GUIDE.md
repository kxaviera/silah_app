# Environment Variables Configuration Guide

## 📋 Quick Setup Checklist

### ✅ Minimum Required (For Local Development)
- [ ] `MONGODB_URI` - MongoDB connection string
- [ ] `JWT_SECRET` - Secret key for user tokens
- [ ] `ADMIN_JWT_SECRET` - Secret key for admin tokens

### ⚠️ Optional (For Full Features)
- [ ] `GOOGLE_CLIENT_ID` - For Google Sign-In
- [ ] `STRIPE_SECRET_KEY` - For payments
- [ ] `SENDGRID_API_KEY` - For emails
- [ ] `TWILIO_ACCOUNT_SID` - For SMS
- [ ] `CLOUDINARY_CLOUD_NAME` - For file uploads

---

## 🔧 Step-by-Step Configuration

### Step 1: Generate Secure JWT Secrets

**On Windows PowerShell:**
```powershell
# Generate JWT_SECRET
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))

# Generate ADMIN_JWT_SECRET (run again for different value)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

**On Linux/Mac:**
```bash
# Generate JWT_SECRET
openssl rand -base64 32

# Generate ADMIN_JWT_SECRET (run again for different value)
openssl rand -base64 32
```

**Copy the generated strings** and paste them into `.env`:
```env
JWT_SECRET=paste-generated-secret-here
ADMIN_JWT_SECRET=paste-generated-secret-here
```

---

### Step 2: Configure MongoDB

#### Option A: Local MongoDB
If you have MongoDB installed locally:
```env
MONGODB_URI=mongodb://localhost:27017/silah
```

#### Option B: MongoDB Atlas (Cloud)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account
3. Create a cluster (free tier available)
4. Click "Connect" → "Connect your application"
5. Copy the connection string
6. Replace `<password>` with your database password
7. Replace `<dbname>` with `silah`

Example:
```env
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/silah?retryWrites=true&w=majority
```

---

### Step 3: Server Configuration

**For Local Development:**
```env
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
```

**For Production:**
```env
PORT=5000
NODE_ENV=production
FRONTEND_URL=https://yourdomain.com
```

---

### Step 4: Google OAuth (Optional - For Google Sign-In)

1. Go to https://console.cloud.google.com
2. Create a new project or select existing
3. Enable "Google+ API"
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Choose "Web application"
6. Add authorized redirect URIs:
   - `http://localhost:5000/api/auth/google/callback` (for development)
   - `https://yourdomain.com/api/auth/google/callback` (for production)
7. Copy Client ID and Client Secret

```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

---

### Step 5: Stripe Payment (Optional - For Payments)

1. Go to https://stripe.com
2. Create an account
3. Go to "Developers" → "API keys"
4. Copy "Secret key" (starts with `sk_test_` for testing)
5. Copy "Publishable key" (starts with `pk_test_` for testing)

```env
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret  # Optional, for webhooks
```

**Note:** For production, use `sk_live_` and `pk_live_` keys.

---

### Step 6: SendGrid Email (Optional - For Emails)

1. Go to https://sendgrid.com
2. Sign up for free account (100 emails/day free)
3. Verify your email
4. Go to "Settings" → "API Keys"
5. Click "Create API Key"
6. Name it (e.g., "Silah Admin")
7. Select "Full Access" or "Restricted Access" with Mail Send permissions
8. Copy the API key (starts with `SG.`)

```env
SENDGRID_API_KEY=SG.your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@silah.com  # Must be verified in SendGrid
```

**Important:** Verify the sender email in SendGrid before using.

---

### Step 7: Twilio SMS (Optional - For SMS)

1. Go to https://www.twilio.com
2. Sign up for free trial account
3. Verify your phone number
4. Go to Console Dashboard
5. Copy "Account SID" (starts with `AC`)
6. Copy "Auth Token"
7. Get a phone number (Trial includes one)

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890  # Format: +countrycode+number
```

---

### Step 8: File Upload (Choose One)

#### Option A: Cloudinary (Recommended - Easy Setup)

1. Go to https://cloudinary.com
2. Sign up for free account
3. Go to Dashboard
4. Copy "Cloud name"
5. Copy "API Key"
6. Copy "API Secret"

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

#### Option B: AWS S3

1. Go to https://aws.amazon.com/s3
2. Create an AWS account
3. Create an S3 bucket
4. Create IAM user with S3 permissions
5. Generate access keys

```env
AWS_ACCESS_KEY_ID=your_aws_access_key_id
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
AWS_BUCKET_NAME=your_s3_bucket_name
AWS_REGION=us-east-1
```

---

### Step 9: Company Details (For Invoices)

Update with your actual company information:

```env
COMPANY_NAME=Silah Matrimony
COMPANY_GSTIN=29ABCDE1234F1Z5  # Your GST number
COMPANY_EMAIL=support@silah.com  # Your support email
COMPANY_PHONE=+91-1234567890  # Your support phone
COMPANY_ADDRESS=123 Main Street, City, State, Country - 123456  # Your address
```

---

### Step 10: Socket.io Configuration

**For Local Development:**
```env
SOCKET_IO_CORS_ORIGIN=http://localhost:3000
```

**For Production:**
```env
SOCKET_IO_CORS_ORIGIN=https://yourdomain.com
```

---

## 📝 Complete .env Example

Here's a complete example with all values filled (replace with your actual values):

```env
# ============================================
# Silah Backend - Environment Variables
# ============================================

# Server Configuration
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:3000

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/silah
# OR for MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/silah?retryWrites=true&w=majority

# JWT Configuration
JWT_SECRET=your-generated-secret-key-here-min-32-chars
JWT_EXPIRE=7d
ADMIN_JWT_SECRET=your-generated-admin-secret-key-here-min-32-chars
ADMIN_JWT_EXPIRE=24h

# Google OAuth Configuration (Optional)
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Payment Gateway (Stripe) - Optional
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Email Service (SendGrid) - Optional
SENDGRID_API_KEY=SG.your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@silah.com

# SMS Service (Twilio) - Optional
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# File Upload Configuration - Choose One
# Option 1: Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# Option 2: AWS S3 (comment out Cloudinary if using this)
# AWS_ACCESS_KEY_ID=your_aws_access_key_id
# AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
# AWS_BUCKET_NAME=your_s3_bucket_name
# AWS_REGION=us-east-1

# Company Details (for invoices)
COMPANY_NAME=Silah Matrimony
COMPANY_GSTIN=29ABCDE1234F1Z5
COMPANY_EMAIL=support@silah.com
COMPANY_PHONE=+91-1234567890
COMPANY_ADDRESS=123 Main Street, City, State, Country - 123456

# Socket.io Configuration
SOCKET_IO_CORS_ORIGIN=http://localhost:3000
```

---

## ✅ Verification Checklist

After updating `.env`, verify:

- [ ] `MONGODB_URI` is correct and MongoDB is accessible
- [ ] `JWT_SECRET` and `ADMIN_JWT_SECRET` are long, random strings
- [ ] `FRONTEND_URL` matches your frontend URL
- [ ] Optional services are configured if you plan to use them
- [ ] Company details are accurate (for invoices)

---

## 🧪 Test Configuration

After updating `.env`, test the configuration:

```bash
cd D:\Silah\Backend
npm run dev
```

**Expected Output:**
```
✅ MongoDB Connected
🚀 Server running on port 5000
📡 API available at http://localhost:5000/api
🔌 Socket.io ready for connections
```

**If you see errors:**
- Check MongoDB connection string
- Verify all required variables are set
- Check for typos in variable names
- Ensure no extra spaces around `=` sign

---

## 🔒 Security Best Practices

1. **Never commit `.env` to Git** ✅ (Already in `.gitignore`)
2. **Use different secrets for development and production**
3. **Rotate secrets regularly** (every 90 days)
4. **Use environment variables in production** (not `.env` file)
5. **Restrict API key permissions** (use restricted access when possible)
6. **Use HTTPS in production**
7. **Keep secrets secure** (don't share in chat, email, etc.)

---

## 🆘 Troubleshooting

### "MongoDB connection error"
- Check if MongoDB is running (local) or accessible (Atlas)
- Verify connection string format
- Check network/firewall settings
- Verify username/password are correct

### "JWT secret not configured"
- Make sure `JWT_SECRET` and `ADMIN_JWT_SECRET` are set
- Restart server after updating `.env`
- Check for typos or extra spaces

### "SendGrid/Twilio not configured"
- These are optional - app will work without them
- Email/SMS features won't function without them
- Check API keys are correct
- Verify sender email/phone is verified

### "Invalid Google OAuth credentials"
- Check Client ID and Secret are correct
- Verify redirect URIs are configured
- Ensure Google+ API is enabled

---

## 📞 Need Help?

If you need help with any specific service setup:
- **MongoDB Atlas:** https://docs.atlas.mongodb.com
- **Google OAuth:** https://developers.google.com/identity/protocols/oauth2
- **Stripe:** https://stripe.com/docs
- **SendGrid:** https://docs.sendgrid.com
- **Twilio:** https://www.twilio.com/docs
- **Cloudinary:** https://cloudinary.com/documentation

---

**Last Updated:** January 22, 2026
