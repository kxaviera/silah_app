import sgMail from '@sendgrid/mail';

// Initialize SendGrid
if (process.env.SENDGRID_API_KEY) {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
}

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
  from?: string;
}

export const emailService = {
  async sendEmail(options: EmailOptions): Promise<{ success: boolean; messageId?: string; error?: string }> {
    try {
      if (!process.env.SENDGRID_API_KEY) {
        console.warn('SendGrid API key not configured. Email not sent.');
        return {
          success: false,
          error: 'SendGrid API key not configured',
        };
      }

      const msg = {
        to: options.to,
        from: options.from || process.env.SENDGRID_FROM_EMAIL || 'noreply@silah.com',
        subject: options.subject,
        text: options.text || options.html.replace(/<[^>]*>/g, ''), // Strip HTML for text version
        html: options.html,
      };

      const [response] = await sgMail.send(msg);

      return {
        success: true,
        messageId: response.headers['x-message-id'] as string,
      };
    } catch (error: any) {
      console.error('SendGrid error:', error);
      return {
        success: false,
        error: error.message || 'Failed to send email',
      };
    }
  },

  async sendBulkEmails(emails: EmailOptions[]): Promise<{ success: boolean; sent: number; failed: number; errors?: any[] }> {
    try {
      if (!process.env.SENDGRID_API_KEY) {
        console.warn('SendGrid API key not configured. Emails not sent.');
        return {
          success: false,
          sent: 0,
          failed: emails.length,
          errors: ['SendGrid API key not configured'],
        };
      }

      const messages = emails.map((email) => ({
        to: email.to,
        from: email.from || process.env.SENDGRID_FROM_EMAIL || 'noreply@silah.com',
        subject: email.subject,
        text: email.text || email.html.replace(/<[^>]*>/g, ''),
        html: email.html,
      }));

      // SendGrid allows up to 1000 emails per request
      const batchSize = 1000;
      let sent = 0;
      let failed = 0;
      const errors: any[] = [];

      for (let i = 0; i < messages.length; i += batchSize) {
        const batch = messages.slice(i, i + batchSize);
        try {
          await sgMail.send(batch);
          sent += batch.length;
        } catch (error: any) {
          failed += batch.length;
          errors.push({
            batch: i,
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
      console.error('SendGrid bulk email error:', error);
      return {
        success: false,
        sent: 0,
        failed: emails.length,
        errors: [error.message],
      };
    }
  },
};
