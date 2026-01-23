import { useState, useEffect } from 'react';
import {
  Box, Typography, TextField, Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  IconButton, Chip, Button, InputAdornment, Card, CircularProgress, Dialog, DialogTitle, DialogContent, DialogActions, Alert,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { promoCodesService } from '../services/promoCodes.service';
import type { PromoCode } from '../services/promoCodes.service';
import { useNavigate } from 'react-router-dom';

export function PromoCodes() {
  const [promoCodes, setPromoCodes] = useState<PromoCode[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean; id: string | null; code: string }>({ open: false, id: null, code: '' });
  const [deleting, setDeleting] = useState(false);
  const navigate = useNavigate();

  const load = async () => {
    setLoading(true);
    try {
      const params: any = {};
      if (statusFilter !== 'all') {
        params.isActive = statusFilter === 'active' ? 'true' : 'false';
      }
      if (search) {
        params.search = search;
      }
      const data = await promoCodesService.getPromoCodes(params);
      setPromoCodes(data);
    } catch (e) {
      console.error('Failed to load promo codes:', e);
      setPromoCodes([]);
    }
    setLoading(false);
  };

  useEffect(() => { load(); }, [statusFilter]);
  useEffect(() => { const t = setTimeout(() => load(), 300); return () => clearTimeout(t); }, [search]);

  const handleDelete = async () => {
    if (!deleteDialog.id) return;
    setDeleting(true);
    try {
      await promoCodesService.deletePromoCode(deleteDialog.id);
      setDeleteDialog({ open: false, id: null, code: '' });
      load();
    } catch (e: any) {
      alert(e?.response?.data?.message || 'Failed to delete promo code');
    }
    setDeleting(false);
  };

  const formatDiscount = (promo: PromoCode): string => {
    if (promo.discountType === 'percentage') {
      return `${promo.discountValue}%`;
    } else {
      // discountValue is in paise, convert to rupees
      return `₹${Math.round(promo.discountValue / 100)}`;
    }
  };

  const formatAmount = (amount: number): string => {
    return `₹${Math.round(amount / 100)}`;
  };

  const isExpired = (promo: PromoCode): boolean => {
    return new Date(promo.validUntil) < new Date();
  };

  const isUpcoming = (promo: PromoCode): boolean => {
    return new Date(promo.validFrom) > new Date();
  };

  const getStatus = (promo: PromoCode): 'active' | 'inactive' | 'expired' | 'upcoming' => {
    if (!promo.isActive) return 'inactive';
    if (isExpired(promo)) return 'expired';
    if (isUpcoming(promo)) return 'upcoming';
    if (promo.usageLimit && promo.usageCount >= promo.usageLimit) return 'expired';
    return 'active';
  };

  return (
    <Box>
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
            Promo Codes
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Manage discount codes and promotional offers
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/promo-codes/new')}
          sx={{
            bgcolor: '#28BC79',
            '&:hover': { bgcolor: '#22a066' },
          }}
        >
          Create Promo Code
        </Button>
      </Box>

      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0', display: 'flex', gap: 2, flexWrap: 'wrap' }}>
          <TextField
            size="small"
            placeholder="Search promo codes..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ color: '#94a3b8' }} />
                </InputAdornment>
              ),
            }}
            sx={{ flexGrow: 1, minWidth: 250 }}
          />
          <Box sx={{ display: 'flex', gap: 1 }}>
            {(['all', 'active', 'inactive'] as const).map((filter) => (
              <Button
                key={filter}
                variant={statusFilter === filter ? 'contained' : 'outlined'}
                onClick={() => setStatusFilter(filter)}
                sx={{
                  textTransform: 'capitalize',
                  ...(statusFilter === filter && {
                    bgcolor: '#28BC79',
                    '&:hover': { bgcolor: '#22a066' },
                  }),
                }}
              >
                {filter}
              </Button>
            ))}
          </Box>
        </Box>

        {loading ? (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <CircularProgress />
          </Box>
        ) : promoCodes.length === 0 ? (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography color="text.secondary">No promo codes found</Typography>
          </Box>
        ) : (
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ bgcolor: '#f8fafc' }}>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Code</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Discount</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Valid Period</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Usage</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Status</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Applicable To</TableCell>
                  <TableCell sx={{ fontWeight: 600, color: '#475569', textAlign: 'right' }}>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {promoCodes.map((promo) => {
                  const status = getStatus(promo);
                  return (
                    <TableRow key={promo._id} hover sx={{ '&:hover': { bgcolor: '#f8fafc' } }}>
                      <TableCell>
                        <Typography sx={{ fontWeight: 600, fontFamily: 'monospace' }}>{promo.code}</Typography>
                        {promo.description && (
                          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                            {promo.description}
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell>
                        <Typography sx={{ fontWeight: 500 }}>{formatDiscount(promo)}</Typography>
                        {promo.minAmount && (
                          <Typography variant="body2" color="text.secondary">
                            Min: {formatAmount(promo.minAmount)}
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {new Date(promo.validFrom).toLocaleDateString()} - {new Date(promo.validUntil).toLocaleDateString()}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {promo.usageCount} {promo.usageLimit ? `/ ${promo.usageLimit}` : ''}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={status}
                          size="small"
                          sx={{
                            bgcolor:
                              status === 'active'
                                ? '#d1fae5'
                                : status === 'expired'
                                ? '#fee2e2'
                                : status === 'upcoming'
                                ? '#dbeafe'
                                : '#f3f4f6',
                            color:
                              status === 'active'
                                ? '#065f46'
                                : status === 'expired'
                                ? '#991b1b'
                                : status === 'upcoming'
                                ? '#1e40af'
                                : '#374151',
                            fontWeight: 500,
                            textTransform: 'capitalize',
                          }}
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" sx={{ textTransform: 'capitalize' }}>
                          {promo.applicableTo}
                        </Typography>
                        {promo.applicableBoostType && promo.applicableBoostType !== 'all' && (
                          <Typography variant="body2" color="text.secondary" sx={{ textTransform: 'capitalize' }}>
                            {promo.applicableBoostType}
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell sx={{ textAlign: 'right' }}>
                        <IconButton size="small" onClick={() => navigate(`/promo-codes/${promo._id}`)}>
                          <VisibilityIcon fontSize="small" />
                        </IconButton>
                        <IconButton size="small" onClick={() => navigate(`/promo-codes/${promo._id}/edit`)}>
                          <EditIcon fontSize="small" />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => setDeleteDialog({ open: true, id: promo._id, code: promo.code })}
                          sx={{ color: '#dc2626' }}
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Card>

      <Dialog open={deleteDialog.open} onClose={() => setDeleteDialog({ open: false, id: null, code: '' })}>
        <DialogTitle>Delete Promo Code</DialogTitle>
        <DialogContent>
          <Typography>Are you sure you want to delete promo code <strong>{deleteDialog.code}</strong>? This action cannot be undone.</Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialog({ open: false, id: null, code: '' })} disabled={deleting}>
            Cancel
          </Button>
          <Button onClick={handleDelete} color="error" variant="contained" disabled={deleting}>
            {deleting ? 'Deleting...' : 'Delete'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
