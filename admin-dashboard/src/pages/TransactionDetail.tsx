import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box, Typography, Card, CardContent, Button, CircularProgress, Chip } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { transactionsService } from '../services/transactions.service';

export function TransactionDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [tx, setTx] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    transactionsService.getTransaction(id).then((d) => { setTx(d.transaction || d); setLoading(false); }).catch(() => setLoading(false));
  }, [id]);

  const handleRefund = async () => {
    if (!id || !confirm('Process refund for this transaction?')) return;
    try { await transactionsService.refundTransaction(id); setTx((t: any) => ({ ...t, status: 'refunded' })); } catch (e) { alert((e as Error)?.message || 'Failed'); }
  };

  if (loading) return <Box display="flex" justifyContent="center" p={4}><CircularProgress /></Box>;
  if (!tx) return <Typography>Transaction not found.</Typography>;

  return (
    <Box>
      <Button 
        startIcon={<ArrowBackIcon />} 
        onClick={() => navigate('/transactions')} 
        sx={{ mb: 3, color: '#64748b', '&:hover': { bgcolor: '#f1f5f9' } }}
      >
        Back to Transactions
      </Button>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Transaction Details
        </Typography>
        <Typography variant="body2" color="text.secondary">
          View transaction information and process refunds
        </Typography>
      </Box>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', maxWidth: 700 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b', mb: 1 }}>
            Transaction #{tx._id.slice(-8)}
          </Typography>
          <Chip 
            label={tx.status} 
            sx={{ 
              bgcolor: tx.status === 'completed' ? '#d1fae5' : tx.status === 'failed' ? '#fee2e2' : tx.status === 'refunded' ? '#fef3c7' : '#e0e7ff',
              color: tx.status === 'completed' ? '#065f46' : tx.status === 'failed' ? '#dc2626' : tx.status === 'refunded' ? '#92400e' : '#3730a3',
              fontWeight: 500,
              textTransform: 'capitalize',
            }} 
          />
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              User
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {tx.user?.fullName || tx.userId}
            </Typography>
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Amount
            </Typography>
            <Typography variant="h5" sx={{ fontWeight: 700, color: '#1e293b' }}>
              ₹{tx.amount}
            </Typography>
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Type
            </Typography>
            <Chip 
              label={tx.boostType || tx.type || '-'} 
              sx={{ 
                bgcolor: '#dbeafe',
                color: '#1e40af',
                fontWeight: 500,
                textTransform: 'capitalize',
              }} 
            />
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Payment Method
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {tx.paymentMethod || 'Not specified'}
            </Typography>
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Transaction Date
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {new Date(tx.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
            </Typography>
          </Box>
          {tx.status === 'completed' && (
            <Box sx={{ mt: 4, pt: 3, borderTop: '1px solid #e2e8f0' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2, color: '#dc2626' }}>
                Refund Transaction
              </Typography>
              <Button 
                variant="outlined" 
                color="error" 
                onClick={handleRefund}
                sx={{ 
                  borderColor: '#dc2626',
                  color: '#dc2626',
                  '&:hover': { 
                    borderColor: '#b91c1c', 
                    bgcolor: '#fee2e2' 
                  }
                }}
              >
                Process Refund
              </Button>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
}
