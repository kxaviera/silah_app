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
      <Button 
        startIcon={<ArrowBackIcon />} 
        onClick={() => navigate('/users')} 
        sx={{ mb: 3, color: '#64748b', '&:hover': { bgcolor: '#f1f5f9' } }}
      >
        Back to Users
      </Button>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          User Details
        </Typography>
        <Typography variant="body2" color="text.secondary">
          View and manage user information
        </Typography>
      </Box>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', maxWidth: 800 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Typography variant="h5" sx={{ fontWeight: 600, color: '#1e293b', mb: 1 }}>
            {user.fullName}
          </Typography>
          <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
            {user.email}
          </Typography>
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            <Chip 
              label={user.role} 
              sx={{ 
                bgcolor: user.role === 'bride' ? '#fce7f3' : '#dbeafe',
                color: user.role === 'bride' ? '#be185d' : '#1e40af',
                fontWeight: 500,
                textTransform: 'capitalize',
              }} 
            />
            <Chip 
              label={user.isBlocked ? 'Blocked' : 'Active'} 
              sx={{ 
                bgcolor: user.isBlocked ? '#fee2e2' : '#d1fae5',
                color: user.isBlocked ? '#dc2626' : '#065f46',
                fontWeight: 500,
              }} 
            />
            {user.isVerified && (
              <Chip 
                icon={<VerifiedUserIcon />} 
                label="Verified" 
                sx={{ 
                  bgcolor: '#dbeafe',
                  color: '#1e40af',
                  fontWeight: 500,
                }} 
              />
            )}
            {user.boostStatus === 'active' && (
              <Chip 
                label="Boosted" 
                sx={{ 
                  bgcolor: '#fef3c7',
                  color: '#92400e',
                  fontWeight: 500,
                }} 
              />
            )}
          </Box>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Joined Date
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {new Date(user.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
            </Typography>
          </Box>
          {user.boostExpiresAt && (
            <Box sx={{ mb: 3 }}>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                Boost Expires
              </Typography>
              <Typography variant="body1" sx={{ fontWeight: 500 }}>
                {new Date(user.boostExpiresAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
              </Typography>
            </Box>
          )}
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', pt: 2, borderTop: '1px solid #e2e8f0' }}>
            <Button 
              variant={user.isBlocked ? 'contained' : 'outlined'} 
              startIcon={user.isBlocked ? <LockOpenIcon /> : <BlockIcon />} 
              onClick={handleBlock}
              sx={{
                ...(user.isBlocked ? {
                  bgcolor: '#28BC79',
                  '&:hover': { bgcolor: '#1E8A5A' }
                } : {
                  borderColor: '#dc2626',
                  color: '#dc2626',
                  '&:hover': { borderColor: '#b91c1c', bgcolor: '#fee2e2' }
                })
              }}
            >
              {user.isBlocked ? 'Unblock User' : 'Block User'}
            </Button>
            {!user.isVerified && (
              <Button 
                variant="outlined" 
                startIcon={<VerifiedUserIcon />} 
                onClick={handleVerify}
                sx={{
                  borderColor: '#28BC79',
                  color: '#28BC79',
                  '&:hover': { borderColor: '#1E8A5A', bgcolor: 'rgba(40, 188, 121, 0.1)' }
                }}
              >
                Verify User
              </Button>
            )}
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}
