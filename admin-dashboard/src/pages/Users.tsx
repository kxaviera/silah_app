import { useState, useEffect } from 'react';
import {
  Box, Typography, TextField, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper,
  IconButton, Chip, TablePagination, Button, InputAdornment,
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
    } catch { setData({ success: false, users: [], total: 0, page: 1, limit: 10 }); }
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
      <Typography variant="h5" fontWeight="bold" gutterBottom>Users</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 2, flexWrap: 'wrap' }}>
        <TextField size="small" placeholder="Search by name or email" value={search} onChange={(e) => setSearch(e.target.value)} InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> }} sx={{ minWidth: 220 }} />
        <Box sx={{ display: 'flex', gap: 1 }}>
          {['', 'active', 'blocked', 'verified', 'boosted'].map((s) => (
            <Button key={s || 'all'} variant={status === s ? 'contained' : 'outlined'} size="small" onClick={() => setStatus(s)} sx={{ minWidth: 90 }}>{s || 'All'}</Button>
          ))}
        </Box>
      </Box>
      <TableContainer component={Paper} sx={{ boxShadow: 2 }}>
        <Table size="small">
          <TableHead><TableRow sx={{ bgcolor: '#f5f5f5' }}>
            <TableCell>Name</TableCell><TableCell>Email</TableCell><TableCell>Role</TableCell><TableCell>Status</TableCell><TableCell>Boost</TableCell><TableCell align="right">Actions</TableCell>
          </TableRow></TableHead>
          <TableBody>
            {loading ? <TableRow><TableCell colSpan={6} align="center">Loading...</TableCell></TableRow> :
              users.map((u) => (
                <TableRow key={u._id} hover>
                  <TableCell>{u.fullName}</TableCell>
                  <TableCell>{u.email}</TableCell>
                  <TableCell><Chip label={u.role} size="small" color={u.role === 'bride' ? 'secondary' : 'primary'} /></TableCell>
                  <TableCell>
                    {u.isBlocked ? <Chip label="Blocked" size="small" color="error" /> : <Chip label="Active" size="small" color="success" />}
                    {u.isVerified && <VerifiedUserIcon fontSize="small" color="primary" sx={{ ml: 0.5 }} />}
                  </TableCell>
                  <TableCell>{u.boostStatus === 'active' ? 'Active' : '-'}</TableCell>
                  <TableCell align="right">
                    <IconButton size="small" onClick={() => navigate(`/users/${u._id}`)}><VisibilityIcon /></IconButton>
                    <IconButton size="small" onClick={() => handleBlock(u)} title={u.isBlocked ? 'Unblock' : 'Block'}>{u.isBlocked ? <LockOpenIcon /> : <BlockIcon />}</IconButton>
                    {!u.isVerified && <IconButton size="small" onClick={() => handleVerify(u._id)}><VerifiedUserIcon /></IconButton>}
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
