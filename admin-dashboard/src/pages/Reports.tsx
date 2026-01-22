import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper,
  Chip, TablePagination, Button, Select, MenuItem, FormControl, InputLabel,
} from '@mui/material';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { reportsService } from '../services/reports.service';
import type { ReportsResponse } from '../services/reports.service';
import { useNavigate, useSearchParams } from 'react-router-dom';

export function Reports() {
  const [data, setData] = useState<ReportsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [status, setStatus] = useState<string>('');
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  const load = async () => {
    setLoading(true);
    try {
      const s = status || searchParams.get('status') || undefined;
      const res = await reportsService.getReports({ page: page + 1, limit: rowsPerPage, status: s });
      setData(res);
    } catch { setData({ success: false, reports: [], total: 0, page: 1, limit: 10 }); }
    setLoading(false);
  };

  useEffect(() => { load(); }, [page, rowsPerPage, status, searchParams]);

  const reports = data?.reports || [];

  return (
    <Box>
      <Typography variant="h5" fontWeight="bold" gutterBottom>Reports</Typography>
      <Box sx={{ mb: 2 }}>
        <FormControl size="small" sx={{ minWidth: 180 }}>
          <InputLabel>Status</InputLabel>
          <Select value={status} label="Status" onChange={(e) => setStatus(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            <MenuItem value="pending">Pending</MenuItem>
            <MenuItem value="reviewed">Reviewed</MenuItem>
            <MenuItem value="resolved">Resolved</MenuItem>
          </Select>
        </FormControl>
      </Box>
      <TableContainer component={Paper} sx={{ boxShadow: 2 }}>
        <Table size="small">
          <TableHead><TableRow sx={{ bgcolor: '#f5f5f5' }}>
            <TableCell>Reporter</TableCell><TableCell>Reported User</TableCell><TableCell>Reason</TableCell><TableCell>Status</TableCell><TableCell>Date</TableCell><TableCell align="right">Actions</TableCell>
          </TableRow></TableHead>
          <TableBody>
            {loading ? <TableRow><TableCell colSpan={6} align="center">Loading...</TableCell></TableRow> :
              reports.map((r) => (
                <TableRow key={r._id} hover>
                  <TableCell>{r.reporter?.fullName || r.reporterId}</TableCell>
                  <TableCell>{r.reportedUser?.fullName || r.reportedUserId}</TableCell>
                  <TableCell>{r.reason}</TableCell>
                  <TableCell><Chip label={r.status} size="small" color={r.status === 'pending' ? 'warning' : r.status === 'resolved' ? 'success' : 'default'} /></TableCell>
                  <TableCell>{new Date(r.createdAt).toLocaleDateString()}</TableCell>
                  <TableCell align="right">
                    <Button size="small" startIcon={<VisibilityIcon />} onClick={() => navigate(`/reports/${r._id}`)}>View</Button>
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
