import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Chip, TablePagination, FormControl, InputLabel, Select, MenuItem, Card, CircularProgress, Button,
} from '@mui/material';
import { transactionsService } from '../services/transactions.service';
import type { TransactionsResponse } from '../services/transactions.service';
import { useNavigate } from 'react-router-dom';

export function Transactions() {
  const [data, setData] = useState<TransactionsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [status, setStatus] = useState<string>('');
  const navigate = useNavigate();

  const load = async () => {
    setLoading(true);
    try {
      const res = await transactionsService.getTransactions({ page: page + 1, limit: rowsPerPage, status: status || undefined });
      setData(res);
    } catch { setData({ success: false, transactions: [], total: 0, page: 1, limit: 10 }); }
    setLoading(false);
  };

  useEffect(() => { load(); }, [page, rowsPerPage, status]);

  const transactions = data?.transactions || [];

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Transactions
        </Typography>
        <Typography variant="body2" color="text.secondary">
          View and manage all payment transactions
        </Typography>
      </Box>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <FormControl size="small" sx={{ minWidth: 200 }}>
            <InputLabel>Status</InputLabel>
            <Select 
              value={status} 
              label="Status" 
              onChange={(e) => setStatus(e.target.value)}
              sx={{ bgcolor: '#f8fafc' }}
            >
              <MenuItem value="">All</MenuItem>
              <MenuItem value="completed">Completed</MenuItem>
              <MenuItem value="pending">Pending</MenuItem>
              <MenuItem value="failed">Failed</MenuItem>
              <MenuItem value="refunded">Refunded</MenuItem>
            </Select>
          </FormControl>
        </Box>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f8fafc' }}>
                <TableCell sx={{ fontWeight: 600, color: '#475569', py: 2 }}>User</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Amount</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Type</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Date</TableCell>
                <TableCell align="right" sx={{ fontWeight: 600, color: '#475569' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                    <CircularProgress size={24} />
                  </TableCell>
                </TableRow>
              ) : transactions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center" sx={{ py: 4, color: '#64748b' }}>
                    No transactions found
                  </TableCell>
                </TableRow>
              ) : (
                transactions.map((t) => (
                  <TableRow 
                    key={t._id} 
                    hover
                    sx={{ 
                      '&:hover': { bgcolor: '#f8fafc' },
                      '&:last-child td': { borderBottom: 0 }
                    }}
                  >
                    <TableCell sx={{ py: 2, fontWeight: 500 }}>{t.user?.fullName || t.userId}</TableCell>
                    <TableCell sx={{ fontWeight: 600, color: '#1e293b' }}>₹{t.amount}</TableCell>
                    <TableCell>
                      <Chip 
                        label={t.boostType || t.type || '-'} 
                        size="small" 
                        sx={{ 
                          bgcolor: '#dbeafe',
                          color: '#1e40af',
                          fontWeight: 500,
                          textTransform: 'capitalize',
                        }} 
                      />
                    </TableCell>
                    <TableCell>
                      <Chip 
                        label={t.status} 
                        size="small" 
                        sx={{ 
                          bgcolor: t.status === 'completed' ? '#d1fae5' : t.status === 'failed' ? '#fee2e2' : t.status === 'refunded' ? '#fef3c7' : '#e0e7ff',
                          color: t.status === 'completed' ? '#065f46' : t.status === 'failed' ? '#dc2626' : t.status === 'refunded' ? '#92400e' : '#3730a3',
                          fontWeight: 500,
                          textTransform: 'capitalize',
                        }} 
                      />
                    </TableCell>
                    <TableCell sx={{ color: '#64748b' }}>{new Date(t.createdAt).toLocaleString()}</TableCell>
                    <TableCell align="right">
                      <Button 
                        size="small" 
                        onClick={() => navigate(`/transactions/${t._id}`)}
                        sx={{ 
                          color: '#28BC79',
                          '&:hover': { bgcolor: 'rgba(40, 188, 121, 0.1)' }
                        }}
                      >
                        View
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
        {data && (
          <Box sx={{ borderTop: '1px solid #e2e8f0' }}>
            <TablePagination 
              component="div" 
              count={data.total} 
              page={page} 
              onPageChange={(_, p) => setPage(p)} 
              rowsPerPage={rowsPerPage} 
              onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
            />
          </Box>
        )}
      </Card>
    </Box>
  );
}
