import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper,
  Chip, TablePagination, FormControl, InputLabel, Select, MenuItem,
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
      <Typography variant="h5" fontWeight="bold" gutterBottom>Transactions</Typography>
      <Box sx={{ mb: 2 }}>
        <FormControl size="small" sx={{ minWidth: 180 }}>
          <InputLabel>Status</InputLabel>
          <Select value={status} label="Status" onChange={(e) => setStatus(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            <MenuItem value="completed">Completed</MenuItem>
            <MenuItem value="pending">Pending</MenuItem>
            <MenuItem value="failed">Failed</MenuItem>
            <MenuItem value="refunded">Refunded</MenuItem>
          </Select>
        </FormControl>
      </Box>
      <TableContainer component={Paper} sx={{ boxShadow: 2 }}>
        <Table size="small">
          <TableHead><TableRow sx={{ bgcolor: '#f5f5f5' }}>
            <TableCell>User</TableCell><TableCell>Amount</TableCell><TableCell>Type</TableCell><TableCell>Status</TableCell><TableCell>Date</TableCell><TableCell align="right">Actions</TableCell>
          </TableRow></TableHead>
          <TableBody>
            {loading ? <TableRow><TableCell colSpan={6} align="center">Loading...</TableCell></TableRow> :
              transactions.map((t) => (
                <TableRow key={t._id} hover>
                  <TableCell>{t.user?.fullName || t.userId}</TableCell>
                  <TableCell>₹{t.amount}</TableCell>
                  <TableCell>{t.boostType || t.type || '-'}</TableCell>
                  <TableCell><Chip label={t.status} size="small" color={t.status === 'completed' ? 'success' : t.status === 'failed' ? 'error' : 'default'} /></TableCell>
                  <TableCell>{new Date(t.createdAt).toLocaleString()}</TableCell>
                  <TableCell align="right">
                    <Typography component="button" onClick={() => navigate(`/transactions/${t._id}`)} sx={{ color: '#28BC79', textDecoration: 'underline', cursor: 'pointer', border: 'none', background: 'none', fontSize: 'inherit' }}>View</Typography>
                  </TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
        {data && <TablePagination component="div" count={data.total} page={page} onPageChange={(_, p) => setPage(p)} rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }} />}
      </TableContainer>
    </Box>
  );
}
