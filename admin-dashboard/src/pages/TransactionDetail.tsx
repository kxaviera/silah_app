import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box, Typography, Card, CardContent, Button, CircularProgress } from '@mui/material';
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
      <Button startIcon={<ArrowBackIcon />} onClick={() => navigate('/transactions')} sx={{ mb: 2 }}>Back</Button>
      <Typography variant="h5" fontWeight="bold" gutterBottom>Transaction Details</Typography>
      <Card sx={{ maxWidth: 500 }}>
        <CardContent>
          <Typography><strong>User:</strong> {tx.user?.fullName || tx.userId}</Typography>
          <Typography><strong>Amount:</strong> ₹{tx.amount}</Typography>
          <Typography><strong>Type:</strong> {tx.boostType || tx.type || '-'}</Typography>
          <Typography><strong>Status:</strong> {tx.status}</Typography>
          <Typography><strong>Payment Method:</strong> {tx.paymentMethod || '-'}</Typography>
          <Typography><strong>Date:</strong> {new Date(tx.createdAt).toLocaleString()}</Typography>
          {tx.status === 'completed' && (
            <Button variant="outlined" color="error" onClick={handleRefund} sx={{ mt: 2 }}>Process Refund</Button>
          )}
        </CardContent>
      </Card>
    </Box>
  );
}
