import twilio from 'twilio';

// Initialize Twilio client
let twilioClient: twilio.Twilio | null = null;

if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
  twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
}

export interface SMSOptions {
  to: string;
  message: string;
  from?: string;
}

export const smsService = {
  async sendSMS(options: SMSOptions): Promise<{ success: boolean; messageId?: string; error?: string }> {
    try {
      if (!twilioClient) {
        console.warn('Twilio not configured. SMS not sent.');
        return {
          success: false,
          error: 'Twilio not configured',
        };
      }

      const fromNumber = options.from || process.env.TWILIO_PHONE_NUMBER;
      if (!fromNumber) {
        return {
          success: false,
          error: 'Twilio phone number not configured',
        };
      }

      const message = await twilioClient.messages.create({
        body: options.message,
        from: fromNumber,
        to: options.to,
      });

      return {
        success: true,
        messageId: message.sid,
      };
    } catch (error: any) {
      console.error('Twilio error:', error);
      return {
        success: false,
        error: error.message || 'Failed to send SMS',
      };
    }
  },

  async sendBulkSMS(smsList: SMSOptions[]): Promise<{ success: boolean; sent: number; failed: number; errors?: any[] }> {
    try {
      if (!twilioClient) {
        console.warn('Twilio not configured. SMS not sent.');
        return {
          success: false,
          sent: 0,
          failed: smsList.length,
          errors: ['Twilio not configured'],
        };
      }

      const fromNumber = process.env.TWILIO_PHONE_NUMBER;
      if (!fromNumber) {
        return {
          success: false,
          sent: 0,
          failed: smsList.length,
          errors: ['Twilio phone number not configured'],
        };
      }

      let sent = 0;
      let failed = 0;
      const errors: any[] = [];

      // Send SMS one by one (Twilio doesn't support bulk send directly)
      for (const sms of smsList) {
        try {
          const message = await twilioClient!.messages.create({
            body: sms.message,
            from: fromNumber,
            to: sms.to,
          });
          sent++;
        } catch (error: any) {
          failed++;
          errors.push({
            to: sms.to,
            error: error.message,
          });
        }
      }

      return {
        success: failed === 0,
        sent,
        failed,
        errors: errors.length > 0 ? errors : undefined,
      };
    } catch (error: any) {
      console.error('Twilio bulk SMS error:', error);
      return {
        success: false,
        sent: 0,
        failed: smsList.length,
        errors: [error.message],
      };
    }
  },
};
