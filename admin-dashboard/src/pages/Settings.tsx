import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Box, Typography, Card, CardContent, Switch, FormControlLabel, TextField, Alert } from '@mui/material';
import { settingsService } from '../services/settings.service';
import type { AppSettings } from '../services/settings.service';

export function Settings() {
  const [settings, setSettings] = useState<AppSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    settingsService.getSettings().then((s) => { setSettings(s); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  const handlePaymentToggle = async (v: boolean) => {
    setSaving(true);
    setMessage(null);
    try {
      const result = await settingsService.updatePaymentControls({ paymentEnabled: v });
      setSettings((s) => (s ? { ...s, paymentEnabled: v } : null));
      setMessage({ type: 'success', text: 'Payment settings updated successfully.' });
    } catch (e: any) {
      console.error('Payment toggle error:', e);
      const errorMessage = e?.response?.data?.message || e?.message || 'Failed to update payment settings';
      setMessage({ type: 'error', text: errorMessage });
    }
    setSaving(false);
  };

  const handleFreePostingToggle = async (v: boolean) => {
    setSaving(true);
    setMessage(null);
    try {
      const result = await settingsService.updatePaymentControls({ allowFreePosting: v });
      setSettings((s) => (s ? { ...s, allowFreePosting: v } : null));
      setMessage({ type: 'success', text: 'Free posting setting updated successfully.' });
    } catch (e: any) {
      console.error('Free posting toggle error:', e);
      const errorMessage = e?.response?.data?.message || e?.message || 'Failed to update free posting setting';
      setMessage({ type: 'error', text: errorMessage });
    }
    setSaving(false);
  };

  if (loading) return <Typography>Loading...</Typography>;
  const s = settings;

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Settings
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Configure platform settings and payment controls
        </Typography>
      </Box>
      {message && (
        <Alert 
          severity={message.type} 
          onClose={() => setMessage(null)} 
          sx={{ 
            mb: 3,
            borderRadius: 2,
          }}
        >
          {message.text}
        </Alert>
      )}
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
            Payment Controls
          </Typography>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Box sx={{ mb: 3 }}>
            <FormControlLabel 
              control={
                <Switch 
                  checked={s?.paymentEnabled ?? true} 
                  onChange={(_, v) => handlePaymentToggle(v)} 
                  disabled={saving}
                  sx={{
                    '& .MuiSwitch-switchBase.Mui-checked': {
                      color: '#28BC79',
                    },
                    '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': {
                      backgroundColor: '#28BC79',
                    },
                  }}
                />
              } 
              label={
                <Box>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>Payment enabled</Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                    When disabled, all boosts are free.
                  </Typography>
                </Box>
              }
              sx={{ alignItems: 'flex-start' }}
            />
          </Box>
          <Box>
            <FormControlLabel 
              control={
                <Switch 
                  checked={s?.allowFreePosting ?? false} 
                  onChange={(_, v) => handleFreePostingToggle(v)} 
                  disabled={saving}
                  sx={{
                    '& .MuiSwitch-switchBase.Mui-checked': {
                      color: '#28BC79',
                    },
                    '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': {
                      backgroundColor: '#28BC79',
                    },
                  }}
                />
              } 
              label={
                <Box>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>Allow free posting</Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                    When enabled, users can choose to post for free without paying.
                  </Typography>
                </Box>
              }
              sx={{ alignItems: 'flex-start' }}
            />
          </Box>
        </CardContent>
      </Card>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0' }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
            Boost Pricing
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            Pricing is managed from the backend. Use API or database to update.
          </Typography>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Standard - Bride</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={s?.boostPricing?.standard?.bride?.price ?? 199} 
                disabled
                sx={{ bgcolor: '#f8fafc' }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Standard - Groom</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={s?.boostPricing?.standard?.groom?.price ?? 299} 
                disabled
                sx={{ bgcolor: '#f8fafc' }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Featured - Bride</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={s?.boostPricing?.featured?.bride?.price ?? 399} 
                disabled
                sx={{ bgcolor: '#f8fafc' }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Featured - Groom</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={s?.boostPricing?.featured?.groom?.price ?? 599} 
                disabled
                sx={{ bgcolor: '#f8fafc' }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  );
}
