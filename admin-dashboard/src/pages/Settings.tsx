import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Box, Typography, Card, CardContent, Switch, FormControlLabel, TextField, Alert, Button } from '@mui/material';
import SaveIcon from '@mui/icons-material/Save';
import { settingsService } from '../services/settings.service';
import type { AppSettings } from '../services/settings.service';

export function Settings() {
  const [settings, setSettings] = useState<AppSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savingPricing, setSavingPricing] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  
  // Local state for pricing fields
  const [pricing, setPricing] = useState({
    standard: { bride: 199, groom: 299 },
    featured: { bride: 399, groom: 599 },
  });

  useEffect(() => {
    settingsService.getSettings().then((s) => { 
      setSettings(s); 
      if (s?.boostPricing) {
        setPricing({
          standard: {
            bride: s.boostPricing.standard.bride.price,
            groom: s.boostPricing.standard.groom.price,
          },
          featured: {
            bride: s.boostPricing.featured.bride.price,
            groom: s.boostPricing.featured.groom.price,
          },
        });
      }
      setLoading(false); 
    }).catch(() => setLoading(false));
  }, []);

  const handlePaymentToggle = async (v: boolean) => {
    setSaving(true);
    setMessage(null);
    try {
      await settingsService.updatePaymentControls({ paymentEnabled: v });
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
      await settingsService.updatePaymentControls({ allowFreePosting: v });
      setSettings((s) => (s ? { ...s, allowFreePosting: v } : null));
      setMessage({ type: 'success', text: 'Free posting setting updated successfully.' });
    } catch (e: any) {
      console.error('Free posting toggle error:', e);
      const errorMessage = e?.response?.data?.message || e?.message || 'Failed to update free posting setting';
      setMessage({ type: 'error', text: errorMessage });
    }
    setSaving(false);
  };

  const handleSavePricing = async () => {
    setSavingPricing(true);
    setMessage(null);
    try {
      const result = await settingsService.updatePricing({
        standard: {
          bride: { 
            price: pricing.standard.bride,
            enabled: s?.boostPricing?.standard?.bride?.enabled ?? true,
          },
          groom: { 
            price: pricing.standard.groom,
            enabled: s?.boostPricing?.standard?.groom?.enabled ?? true,
          },
          duration: s?.boostPricing?.standard?.duration ?? 7,
        },
        featured: {
          bride: { 
            price: pricing.featured.bride,
            enabled: s?.boostPricing?.featured?.bride?.enabled ?? true,
          },
          groom: { 
            price: pricing.featured.groom,
            enabled: s?.boostPricing?.featured?.groom?.enabled ?? true,
          },
          duration: s?.boostPricing?.featured?.duration ?? 7,
        },
      });
      if (result.settings) {
        setSettings(result.settings);
        setPricing({
          standard: {
            bride: result.settings.boostPricing.standard.bride.price,
            groom: result.settings.boostPricing.standard.groom.price,
          },
          featured: {
            bride: result.settings.boostPricing.featured.bride.price,
            groom: result.settings.boostPricing.featured.groom.price,
          },
        });
      }
      setMessage({ type: 'success', text: 'Pricing updated successfully.' });
    } catch (e: any) {
      console.error('Pricing update error:', e);
      const errorMessage = e?.response?.data?.message || e?.message || 'Failed to update pricing';
      setMessage({ type: 'error', text: errorMessage });
    }
    setSavingPricing(false);
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
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Boost Pricing
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
              Set pricing for boost plans (amounts in ₹)
            </Typography>
          </Box>
          <Button
            variant="contained"
            startIcon={<SaveIcon />}
            onClick={handleSavePricing}
            disabled={savingPricing}
            sx={{
              bgcolor: '#28BC79',
              '&:hover': { bgcolor: '#22a066' },
            }}
          >
            {savingPricing ? 'Saving...' : 'Save Pricing'}
          </Button>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Standard - Bride (₹)</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={pricing.standard.bride}
                onChange={(e) => setPricing({ ...pricing, standard: { ...pricing.standard, bride: Number(e.target.value) } })}
                disabled={savingPricing}
                inputProps={{ min: 0, step: 1 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Standard - Groom (₹)</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={pricing.standard.groom}
                onChange={(e) => setPricing({ ...pricing, standard: { ...pricing.standard, groom: Number(e.target.value) } })}
                disabled={savingPricing}
                inputProps={{ min: 0, step: 1 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Featured - Bride (₹)</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={pricing.featured.bride}
                onChange={(e) => setPricing({ ...pricing, featured: { ...pricing.featured, bride: Number(e.target.value) } })}
                disabled={savingPricing}
                inputProps={{ min: 0, step: 1 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, color: '#475569' }}>Featured - Groom (₹)</Typography>
              <TextField 
                fullWidth 
                size="small" 
                type="number" 
                value={pricing.featured.groom}
                onChange={(e) => setPricing({ ...pricing, featured: { ...pricing.featured, groom: Number(e.target.value) } })}
                disabled={savingPricing}
                inputProps={{ min: 0, step: 1 }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  );
}
