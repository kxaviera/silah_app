import { useState, useEffect } from 'react';
import {
  Box, Typography, TextField, Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  IconButton, Chip, TablePagination, Button, InputAdornment, Card, CircularProgress,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import BlockIcon from '@mui/icons-material/Block';
import LockOpenIcon from '@mui/icons-material/LockOpen';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { usersService } from '../services/users.service';
import type { User, UsersResponse } from '../services/users.service';
import { useNavigate } from 'react-router-dom';

export function Users() {
  const [data, setData] = useState<UsersResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const navigate = useNavigate();

  const load = async () => {
    setLoading(true);
    try {
      const res = await usersService.getUsers({ page: page + 1, limit: rowsPerPage, search: search || undefined, status: status || undefined });
      setData(res);
    } catch { 
      setData({ users: [], total: 0, page: 1, limit: 10 }); 
    }
    setLoading(false);
  };

  useEffect(() => { load(); }, [page, rowsPerPage, status]);
  useEffect(() => { const t = setTimeout(() => load(), 300); return () => clearTimeout(t); }, [search]);

  const handleBlock = async (u: User) => {
    try {
      if (u.isBlocked) await usersService.unblockUser(u._id);
      else await usersService.blockUser(u._id);
      load();
    } catch (e) { alert((e as Error)?.message || 'Failed'); }
  };

  const handleVerify = async (id: string) => {
    try { await usersService.verifyUser(id); load(); } catch (e) { alert((e as Error)?.message || 'Failed'); }
  };

  const users = data?.users || [];

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Users
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Manage and monitor all platform users
        </Typography>
      </Box>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', mb: 3 }}>
        <Box sx={{ p: 3, display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center', borderBottom: '1px solid #e2e8f0' }}>
          <TextField 
            size="small" 
            placeholder="Search by name or email" 
            value={search} 
            onChange={(e) => setSearch(e.target.value)} 
            InputProps={{ 
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ color: '#64748b' }} />
                </InputAdornment>
              ) 
            }} 
            sx={{ 
              minWidth: 280,
              '& .MuiOutlinedInput-root': {
                bgcolor: '#f8fafc',
              }
            }} 
          />
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            {['', 'active', 'blocked', 'verified', 'boosted'].map((s) => (
              <Button 
                key={s || 'all'} 
                variant={status === s ? 'contained' : 'outlined'} 
                size="small" 
                onClick={() => setStatus(s)} 
                sx={{ 
                  minWidth: 90,
                  textTransform: 'capitalize',
                  ...(status === s ? {
                    bgcolor: '#28BC79',
                    '&:hover': { bgcolor: '#1E8A5A' }
                  } : {
                    borderColor: '#e2e8f0',
                    color: '#64748b',
                    '&:hover': { borderColor: '#cbd5e1', bgcolor: '#f8fafc' }
                  })
                }}
              >
                {s || 'All'}
              </Button>
            ))}
          </Box>
        </Box>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f8fafc' }}>
                <TableCell sx={{ fontWeight: 600, color: '#475569', py: 2 }}>Name</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Email</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Role</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600, color: '#475569' }}>Boost</TableCell>
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
              ) : users.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center" sx={{ py: 4, color: '#64748b' }}>
                    No users found
                  </TableCell>
                </TableRow>
              ) : (
                users.map((u) => (
                  <TableRow 
                    key={u._id} 
                    hover
                    sx={{ 
                      '&:hover': { bgcolor: '#f8fafc' },
                      '&:last-child td': { borderBottom: 0 }
                    }}
                  >
                    <TableCell sx={{ py: 2, fontWeight: 500 }}>{u.fullName}</TableCell>
                    <TableCell sx={{ color: '#64748b' }}>{u.email}</TableCell>
                    <TableCell>
                      {u.role ? (
                        <Chip 
                          label={u.role} 
                          size="small" 
                          sx={{ 
                            bgcolor: u.role === 'bride' ? '#fce7f3' : '#dbeafe',
                            color: u.role === 'bride' ? '#be185d' : '#1e40af',
                            fontWeight: 500,
                            textTransform: 'capitalize',
                          }} 
                        />
                      ) : (
                        <Chip 
                          label="Not Set" 
                          size="small" 
                          sx={{ 
                            bgcolor: '#fef3c7',
                            color: '#92400e',
                            fontWeight: 500,
                          }} 
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                        {u.isBlocked ? (
                          <Chip label="Blocked" size="small" sx={{ bgcolor: '#fee2e2', color: '#dc2626', fontWeight: 500 }} />
                        ) : (
                          <Chip label="Active" size="small" sx={{ bgcolor: '#d1fae5', color: '#065f46', fontWeight: 500 }} />
                        )}
                        {u.isVerified && <VerifiedUserIcon fontSize="small" sx={{ color: '#28BC79', ml: 0.5 }} />}
                      </Box>
                    </TableCell>
                    <TableCell>
                      {u.boostStatus === 'active' ? (
                        <Chip label="Active" size="small" sx={{ bgcolor: '#dbeafe', color: '#1e40af', fontWeight: 500 }} />
                      ) : (
                        <Typography variant="body2" color="text.secondary">-</Typography>
                      )}
                    </TableCell>
                    <TableCell align="right">
                      <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'flex-end' }}>
                        <IconButton 
                          size="small" 
                          onClick={() => navigate(`/users/${u._id}`)}
                          sx={{ color: '#64748b', '&:hover': { bgcolor: '#f1f5f9', color: '#28BC79' } }}
                        >
                          <VisibilityIcon fontSize="small" />
                        </IconButton>
                        <IconButton 
                          size="small" 
                          onClick={() => handleBlock(u)} 
                          title={u.isBlocked ? 'Unblock' : 'Block'}
                          sx={{ color: '#64748b', '&:hover': { bgcolor: '#fee2e2', color: '#dc2626' } }}
                        >
                          {u.isBlocked ? <LockOpenIcon fontSize="small" /> : <BlockIcon fontSize="small" />}
                        </IconButton>
                        {!u.isVerified && (
                          <IconButton 
                            size="small" 
                            onClick={() => handleVerify(u._id)}
                            sx={{ color: '#64748b', '&:hover': { bgcolor: '#dbeafe', color: '#1e40af' } }}
                          >
                            <VerifiedUserIcon fontSize="small" />
                          </IconButton>
                        )}
                      </Box>
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
              sx={{ borderTop: '1px solid #e2e8f0' }}
            />
          </Box>
        )}
      </Card>
    </Box>
  );
}
