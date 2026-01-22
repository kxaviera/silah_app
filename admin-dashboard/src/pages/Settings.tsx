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
    try {
      await settingsService.updatePaymentControls({ paymentEnabled: v });
      setSettings((s) => (s ? { ...s, paymentEnabled: v } : null));
      setMessage({ type: 'success', text: 'Payment settings updated.' });
    } catch (e) { setMessage({ type: 'error', text: (e as Error)?.message || 'Failed' }); }
    setSaving(false);
  };

  const handleFreePostingToggle = async (v: boolean) => {
    setSaving(true);
    try {
      await settingsService.updatePaymentControls({ allowFreePosting: v });
      setSettings((s) => (s ? { ...s, allowFreePosting: v } : null));
      setMessage({ type: 'success', text: 'Free posting setting updated.' });
    } catch (e) { setMessage({ type: 'error', text: (e as Error)?.message || 'Failed' }); }
    setSaving(false);
  };

  if (loading) return <Typography>Loading...</Typography>;
  const s = settings;

  return (
    <Box>
      <Typography variant="h5" fontWeight="bold" gutterBottom>Settings</Typography>
      {message && <Alert severity={message.type} onClose={() => setMessage(null)} sx={{ mb: 2 }}>{message.text}</Alert>}
      <Card sx={{ maxWidth: 640, mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>Payment Controls</Typography>
          <FormControlLabel control={<Switch checked={s?.paymentEnabled ?? true} onChange={(_, v) => handlePaymentToggle(v)} disabled={saving} />} label="Payment enabled" />
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>When disabled, all boosts are free.</Typography>
          <FormControlLabel control={<Switch checked={s?.allowFreePosting ?? false} onChange={(_, v) => handleFreePostingToggle(v)} disabled={saving} />} label="Allow free posting" />
          <Typography variant="body2" color="text.secondary">When enabled, users can choose to post for free without paying.</Typography>
        </CardContent>
      </Card>
      <Card sx={{ maxWidth: 640 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>Boost Pricing</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>Pricing is managed from the backend. Use API or database to update.</Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2">Standard - Bride</Typography>
              <TextField fullWidth size="small" type="number" value={s?.boostPricing?.standard?.bride?.price ?? 199} disabled />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2">Standard - Groom</Typography>
              <TextField fullWidth size="small" type="number" value={s?.boostPricing?.standard?.groom?.price ?? 299} disabled />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2">Featured - Bride</Typography>
              <TextField fullWidth size="small" type="number" value={s?.boostPricing?.featured?.bride?.price ?? 399} disabled />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2">Featured - Groom</Typography>
              <TextField fullWidth size="small" type="number" value={s?.boostPricing?.featured?.groom?.price ?? 599} disabled />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  );
}
