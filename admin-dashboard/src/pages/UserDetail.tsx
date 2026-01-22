import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box, Typography, Card, CardContent, Button, Chip, CircularProgress } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import BlockIcon from '@mui/icons-material/Block';
import LockOpenIcon from '@mui/icons-material/LockOpen';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import { usersService } from '../services/users.service';

export function UserDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    usersService.getUser(id).then((d) => { setUser(d.user || d); setLoading(false); }).catch(() => setLoading(false));
  }, [id]);

  const handleBlock = async () => {
    if (!user) return;
    try {
      if (user.isBlocked) await usersService.unblockUser(user._id);
      else await usersService.blockUser(user._id);
      setUser((u: any) => ({ ...u, isBlocked: !u?.isBlocked }));
    } catch (e) { alert((e as Error)?.message || 'Failed'); }
  };

  const handleVerify = async () => {
    if (!user) return;
    try { await usersService.verifyUser(user._id); setUser((u: any) => ({ ...u, isVerified: true })); } catch (e) { alert((e as Error)?.message || 'Failed'); }
  };

  if (loading) return <Box display="flex" justifyContent="center" p={4}><CircularProgress /></Box>;
  if (!user) return <Typography>User not found.</Typography>;

  return (
    <Box>
      <Button startIcon={<ArrowBackIcon />} onClick={() => navigate('/users')} sx={{ mb: 2 }}>Back</Button>
      <Typography variant="h5" fontWeight="bold" gutterBottom>User Details</Typography>
      <Card sx={{ maxWidth: 600 }}>
        <CardContent>
          <Typography variant="h6">{user.fullName}</Typography>
          <Typography color="text.secondary">{user.email}</Typography>
          <Box sx={{ mt: 2, display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            <Chip label={user.role} />
            <Chip label={user.isBlocked ? 'Blocked' : 'Active'} color={user.isBlocked ? 'error' : 'success'} />
            {user.isVerified && <Chip icon={<VerifiedUserIcon />} label="Verified" color="primary" />}
            {user.boostStatus === 'active' && <Chip label="Boosted" color="info" />}
          </Box>
          <Typography variant="body2" sx={{ mt: 2 }}>Joined: {new Date(user.createdAt).toLocaleDateString()}</Typography>
          <Box sx={{ mt: 2, display: 'flex', gap: 1 }}>
            <Button variant="outlined" startIcon={user.isBlocked ? <LockOpenIcon /> : <BlockIcon />} onClick={handleBlock}>{user.isBlocked ? 'Unblock' : 'Block'}</Button>
            {!user.isVerified && <Button variant="outlined" startIcon={<VerifiedUserIcon />} onClick={handleVerify}>Verify</Button>}
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}
