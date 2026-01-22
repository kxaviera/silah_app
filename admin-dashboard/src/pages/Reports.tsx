import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Chip, TablePagination, Button, Select, MenuItem, FormControl, InputLabel, Card, CircularProgress,
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
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Reports
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Review and manage user reports
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
              <MenuItem value="pending">Pending</MenuItem>
              <MenuItem value="reviewed">Reviewed</MenuItem>
              <MenuItem value="resolved">Resolved</MenuItem>
            </Select>
          </FormControl>
        </Box>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f8fafc' }}>
                <TableCell sx={{ fontWeight: 600, color: '#475569', py: 2 }}>Reporter</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Reported User</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Reason</TableCell>
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
              ) : reports.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center" sx={{ py: 4, color: '#64748b' }}>
                    No reports found
                  </TableCell>
                </TableRow>
              ) : (
                reports.map((r) => (
                  <TableRow 
                    key={r._id} 
                    hover
                    sx={{ 
                      '&:hover': { bgcolor: '#f8fafc' },
                      '&:last-child td': { borderBottom: 0 }
                    }}
                  >
                    <TableCell sx={{ py: 2, fontWeight: 500 }}>{r.reporter?.fullName || r.reporterId}</TableCell>
                    <TableCell sx={{ fontWeight: 500 }}>{r.reportedUser?.fullName || r.reportedUserId}</TableCell>
                    <TableCell sx={{ color: '#64748b' }}>{r.reason}</TableCell>
                    <TableCell>
                      <Chip 
                        label={r.status} 
                        size="small" 
                        sx={{ 
                          bgcolor: r.status === 'pending' ? '#fef3c7' : r.status === 'resolved' ? '#d1fae5' : '#e0e7ff',
                          color: r.status === 'pending' ? '#92400e' : r.status === 'resolved' ? '#065f46' : '#3730a3',
                          fontWeight: 500,
                          textTransform: 'capitalize',
                        }} 
                      />
                    </TableCell>
                    <TableCell sx={{ color: '#64748b' }}>{new Date(r.createdAt).toLocaleDateString()}</TableCell>
                    <TableCell align="right">
                      <Button 
                        size="small" 
                        startIcon={<VisibilityIcon />} 
                        onClick={() => navigate(`/reports/${r._id}`)}
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
