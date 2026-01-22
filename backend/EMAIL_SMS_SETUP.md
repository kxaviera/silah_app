# Email/SMS Service Integration Guide

## ✅ Integration Complete

Email and SMS services have been integrated using:
- **SendGrid** for emails
- **Twilio** for SMS

## 📧 SendGrid Setup

### 1. Create SendGrid Account
1. Go to https://sendgrid.com
2. Sign up for a free account (100 emails/day free)
3. Verify your email address

### 2. Create API Key
1. Go to Settings → API Keys
2. Click "Create API Key"
3. Name it (e.g., "Silah Admin")
4. Select "Full Access" or "Restricted Access" with Mail Send permissions
5. Copy the API key (you'll only see it once!)

### 3. Verify Sender Email
1. Go to Settings → Sender Authentication
2. Click "Verify a Single Sender"
3. Fill in your details
4. Verify the email address

### 4. Add to .env
```env
SENDGRID_API_KEY=SG.your_api_key_here
SENDGRID_FROM_EMAIL=noreply@silah.com
```

## 📱 Twilio Setup

### 1. Create Twilio Account
1. Go to https://www.twilio.com
2. Sign up for a free trial account
3. Verify your phone number

### 2. Get Credentials
1. Go to Console Dashboard
2. Copy your Account SID
3. Copy your Auth Token
4. Get a phone number (Trial account includes one)

### 3. Add to .env
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

## 🔧 Configuration

### Update .env File
```env
# Email Service (SendGrid)
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here
SENDGRID_FROM_EMAIL=noreply@silah.com

# SMS Service (Twilio)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

## 📝 Usage

### Send Email
```bash
POST /api/admin/communications/email
{
  "recipientId": "user_id",
  "subject": "Welcome to Silah",
  "message": "<h1>Welcome!</h1><p>Thank you for joining.</p>",
  "templateId": "optional_template_id"
}
```

### Send SMS
```bash
POST /api/admin/communications/sms
{
  "recipientId": "user_id",
  "message": "Your boost is expiring soon!"
}
```

### Bulk Email
```bash
POST /api/admin/communications/bulk-email
{
  "userIds": ["id1", "id2", "id3"],
  "subject": "Important Announcement",
  "message": "<p>Hello users!</p>"
}
```

## 🧪 Testing

### Test Email (without SendGrid)
If SendGrid is not configured, the system will:
- Log a warning
- Save communication record with status "failed"
- Return error in response

### Test SMS (without Twilio)
If Twilio is not configured, the system will:
- Log a warning
- Save communication record with status "failed"
- Return error in response

## 📊 Features

### Email Service
- ✅ Send individual emails
- ✅ Send bulk emails (up to 1000 per batch)
- ✅ HTML email support
- ✅ Plain text fallback
- ✅ Delivery tracking
- ✅ Error handling

### SMS Service
- ✅ Send individual SMS
- ✅ Send bulk SMS (sequential)
- ✅ Delivery tracking
- ✅ Error handling

## 🔒 Security Notes

1. **Never commit API keys to Git**
   - Keep `.env` in `.gitignore`
   - Use environment variables in production

2. **Rotate API keys regularly**
   - Change keys every 90 days
   - Revoke old keys immediately

3. **Use restricted API keys**
   - Only grant necessary permissions
   - Use separate keys for different environments

## 💰 Pricing

### SendGrid (Free Tier)
- 100 emails/day free
- Unlimited contacts
- Email API access
- **Paid plans start at $15/month**

### Twilio (Free Trial)
- $15.50 credit for trial
- ~1000 SMS messages
- **Paid: ~$0.0075 per SMS**

## 🚨 Error Handling

The system handles errors gracefully:
- Failed sends are logged
- Communication records show status
- Error messages are returned
- System continues to function even if services are down

## 📈 Monitoring

Monitor your usage:
- **SendGrid Dashboard**: Track email delivery, opens, clicks
- **Twilio Console**: Monitor SMS delivery, costs
- **Admin Dashboard**: View communication history

## 🔄 Alternative Services

If you prefer different services:

### Email Alternatives
- **AWS SES** (cheaper, more setup)
- **Mailgun** (similar to SendGrid)
- **Postmark** (transactional emails)

### SMS Alternatives
- **AWS SNS** (cheaper, more setup)
- **Nexmo/Vonage** (similar to Twilio)
- **MessageBird** (global coverage)

To switch services, update:
- `src/services/email.service.ts`
- `src/services/sms.service.ts`

## ✅ Next Steps

1. ✅ Sign up for SendGrid and Twilio
2. ✅ Add API keys to `.env`
3. ✅ Test sending email/SMS
4. ✅ Monitor usage and costs
5. ✅ Set up alerts for failures
