import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Grid from '@mui/material/GridLegacy';
import {
  Box, Typography, Card, CardContent, TextField, Button, FormControlLabel, Switch,
  MenuItem, Select, FormControl, InputLabel, Alert, CircularProgress,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import SaveIcon from '@mui/icons-material/Save';
import { promoCodesService } from '../services/promoCodes.service';

export function PromoCodeDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isNew = id === 'new';
  const isEdit = id && !isNew;

  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  
  const [formData, setFormData] = useState({
    code: '',
    description: '',
    discountType: 'percentage' as 'percentage' | 'fixed',
    discountValue: 0,
    minAmount: 0,
    maxDiscount: 0,
    validFrom: new Date().toISOString().split('T')[0],
    validUntil: '',
    usageLimit: 0,
    userLimit: 0,
    applicableTo: 'all' as 'all' | 'bride' | 'groom',
    applicableBoostType: 'all' as 'all' | 'standard' | 'featured',
    isActive: true,
  });

  useEffect(() => {
    if (isNew) return;
    const load = async () => {
      try {
        const promo = await promoCodesService.getPromoCode(id!);
        setFormData({
          code: promo.code,
          description: promo.description || '',
          discountType: promo.discountType,
          discountValue: promo.discountType === 'percentage' ? promo.discountValue : Math.round(promo.discountValue / 100),
          minAmount: promo.minAmount ? Math.round(promo.minAmount / 100) : 0,
          maxDiscount: promo.maxDiscount ? Math.round(promo.maxDiscount / 100) : 0,
          validFrom: new Date(promo.validFrom).toISOString().split('T')[0],
          validUntil: new Date(promo.validUntil).toISOString().split('T')[0],
          usageLimit: promo.usageLimit || 0,
          userLimit: promo.userLimit || 0,
          applicableTo: promo.applicableTo,
          applicableBoostType: promo.applicableBoostType || 'all',
          isActive: promo.isActive,
        });
      } catch (e: any) {
        setMessage({ type: 'error', text: e?.response?.data?.message || 'Failed to load promo code' });
      }
      setLoading(false);
    };
    load();
  }, [id, isNew]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setMessage(null);
    try {
      if (isNew) {
        await promoCodesService.createPromoCode(formData);
        setMessage({ type: 'success', text: 'Promo code created successfully!' });
        setTimeout(() => navigate('/promo-codes'), 1500);
      } else {
        await promoCodesService.updatePromoCode(id!, formData);
        setMessage({ type: 'success', text: 'Promo code updated successfully!' });
      }
    } catch (e: any) {
      setMessage({ type: 'error', text: e?.response?.data?.message || 'Failed to save promo code' });
    }
    setSaving(false);
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ mb: 4, display: 'flex', alignItems: 'center', gap: 2 }}>
        <Button startIcon={<ArrowBackIcon />} onClick={() => navigate('/promo-codes')}>
          Back
        </Button>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b' }}>
          {isNew ? 'Create Promo Code' : isEdit ? 'Edit Promo Code' : 'Promo Code Details'}
        </Typography>
      </Box>

      {message && (
        <Alert severity={message.type} onClose={() => setMessage(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {message.text}
        </Alert>
      )}

      <form onSubmit={handleSubmit}>
        <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
          <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Basic Information
            </Typography>
          </Box>
          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Promo Code"
                  required
                  value={formData.code}
                  onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                  disabled={!isNew || saving}
                  helperText="Uppercase letters and numbers only"
                  inputProps={{ pattern: '[A-Z0-9]+', style: { textTransform: 'uppercase', fontFamily: 'monospace' } }}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Description (Optional)"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  disabled={saving}
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
          <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Discount Settings
            </Typography>
          </Box>
          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth required>
                  <InputLabel>Discount Type</InputLabel>
                  <Select
                    value={formData.discountType}
                    onChange={(e) => setFormData({ ...formData, discountType: e.target.value as 'percentage' | 'fixed' })}
                    disabled={saving}
                    label="Discount Type"
                  >
                    <MenuItem value="percentage">Percentage</MenuItem>
                    <MenuItem value="fixed">Fixed Amount (₹)</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label={formData.discountType === 'percentage' ? 'Discount Percentage (%)' : 'Discount Amount (₹)'}
                  type="number"
                  required
                  value={formData.discountValue}
                  onChange={(e) => setFormData({ ...formData, discountValue: Number(e.target.value) })}
                  disabled={saving}
                  inputProps={{ min: 0, max: formData.discountType === 'percentage' ? 100 : undefined }}
                  helperText={formData.discountType === 'percentage' ? '0-100%' : 'Amount in rupees'}
                />
              </Grid>
              {formData.discountType === 'percentage' && (
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Maximum Discount (₹)"
                    type="number"
                    value={formData.maxDiscount}
                    onChange={(e) => setFormData({ ...formData, maxDiscount: Number(e.target.value) })}
                    disabled={saving}
                    inputProps={{ min: 0 }}
                    helperText="Optional: Maximum discount cap"
                  />
                </Grid>
              )}
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Minimum Purchase Amount (₹)"
                  type="number"
                  value={formData.minAmount}
                  onChange={(e) => setFormData({ ...formData, minAmount: Number(e.target.value) })}
                  disabled={saving}
                  inputProps={{ min: 0 }}
                  helperText="Optional: Minimum amount required"
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
          <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Validity & Usage
            </Typography>
          </Box>
          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Valid From"
                  type="date"
                  required
                  value={formData.validFrom}
                  onChange={(e) => setFormData({ ...formData, validFrom: e.target.value })}
                  disabled={saving}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Valid Until"
                  type="date"
                  required
                  value={formData.validUntil}
                  onChange={(e) => setFormData({ ...formData, validUntil: e.target.value })}
                  disabled={saving}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Usage Limit"
                  type="number"
                  value={formData.usageLimit || ''}
                  onChange={(e) => setFormData({ ...formData, usageLimit: Number(e.target.value) || 0 })}
                  disabled={saving}
                  inputProps={{ min: 0 }}
                  helperText="Optional: Total number of times this code can be used (0 = unlimited)"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Per User Limit"
                  type="number"
                  value={formData.userLimit || ''}
                  onChange={(e) => setFormData({ ...formData, userLimit: Number(e.target.value) || 0 })}
                  disabled={saving}
                  inputProps={{ min: 0 }}
                  helperText="Optional: Maximum uses per user (0 = unlimited)"
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
          <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Applicability
            </Typography>
          </Box>
          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth>
                  <InputLabel>Applicable To</InputLabel>
                  <Select
                    value={formData.applicableTo}
                    onChange={(e) => setFormData({ ...formData, applicableTo: e.target.value as 'all' | 'bride' | 'groom' })}
                    disabled={saving}
                    label="Applicable To"
                  >
                    <MenuItem value="all">All Users</MenuItem>
                    <MenuItem value="bride">Brides Only</MenuItem>
                    <MenuItem value="groom">Grooms Only</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth>
                  <InputLabel>Applicable Boost Type</InputLabel>
                  <Select
                    value={formData.applicableBoostType}
                    onChange={(e) => setFormData({ ...formData, applicableBoostType: e.target.value as 'all' | 'standard' | 'featured' })}
                    disabled={saving}
                    label="Applicable Boost Type"
                  >
                    <MenuItem value="all">All Boost Types</MenuItem>
                    <MenuItem value="standard">Standard Only</MenuItem>
                    <MenuItem value="featured">Featured Only</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={formData.isActive}
                      onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                      disabled={saving}
                      sx={{
                        '& .MuiSwitch-switchBase.Mui-checked': { color: '#28BC79' },
                        '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': { backgroundColor: '#28BC79' },
                      }}
                    />
                  }
                  label="Active"
                />
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
          <Button variant="outlined" onClick={() => navigate('/promo-codes')} disabled={saving}>
            Cancel
          </Button>
          <Button
            type="submit"
            variant="contained"
            startIcon={<SaveIcon />}
            disabled={saving}
            sx={{
              bgcolor: '#28BC79',
              '&:hover': { bgcolor: '#22a066' },
            }}
          >
            {saving ? 'Saving...' : isNew ? 'Create Promo Code' : 'Save Changes'}
          </Button>
        </Box>
      </form>
    </Box>
  );
}
