import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Grid from '@mui/material/GridLegacy';
import { 
  Box, Typography, Card, CardContent, Button, Chip, CircularProgress, 
  Dialog, DialogTitle, DialogContent, DialogActions, TextField, Divider, Alert,
  Select, MenuItem, FormControl, InputLabel
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import BlockIcon from '@mui/icons-material/Block';
import LockOpenIcon from '@mui/icons-material/LockOpen';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import CancelIcon from '@mui/icons-material/Cancel';
import EditIcon from '@mui/icons-material/Edit';
import { usersService } from '../services/users.service';
import type { User } from '../services/users.service';

export function UserDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [verifyDialogOpen, setVerifyDialogOpen] = useState(false);
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [roleDialogOpen, setRoleDialogOpen] = useState(false);
  const [verificationNotes, setVerificationNotes] = useState('');
  const [rejectionReason, setRejectionReason] = useState('');
  const [selectedRole, setSelectedRole] = useState<'bride' | 'groom' | ''>('');
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    if (!id) return;
    usersService.getUser(id).then((d) => { 
      setUser(d.user || d);
      setSelectedRole((d.user || d).role || '');
      setLoading(false); 
    }).catch(() => setLoading(false));
  }, [id]);

  const handleBlock = async () => {
    if (!user) return;
    try {
      if (user.isBlocked) await usersService.unblockUser(user._id);
      else await usersService.blockUser(user._id);
      setUser((u: any) => ({ ...u, isBlocked: !u?.isBlocked }));
      setMessage({ type: 'success', text: user.isBlocked ? 'User unblocked successfully' : 'User blocked successfully' });
    } catch (e) { 
      setMessage({ type: 'error', text: (e as Error)?.message || 'Failed' }); 
    }
  };

  const handleUpdateRole = async () => {
    if (!user || !selectedRole) return;
    setSaving(true);
    try {
      const result = await usersService.updateUserRole(user._id, selectedRole as 'bride' | 'groom');
      setUser(result.user);
      setRoleDialogOpen(false);
      setMessage({ type: 'success', text: 'User role updated successfully' });
    } catch (e) { 
      setMessage({ type: 'error', text: (e as Error)?.message || 'Failed to update role' }); 
    }
    setSaving(false);
  };

  const handleBlock = async () => {
    if (!user) return;
    try {
      if (user.isBlocked) await usersService.unblockUser(user._id);
      else await usersService.blockUser(user._id);
      setUser((u: any) => ({ ...u, isBlocked: !u?.isBlocked }));
      setMessage({ type: 'success', text: user.isBlocked ? 'User unblocked successfully' : 'User blocked successfully' });
    } catch (e) { 
      setMessage({ type: 'error', text: (e as Error)?.message || 'Failed' }); 
    }
  };

  const handleVerify = async () => {
    if (!user) return;
    setSaving(true);
    try {
      const result = await usersService.verifyUser(user._id, verificationNotes);
      setUser(result.user);
      setVerifyDialogOpen(false);
      setVerificationNotes('');
      setMessage({ type: 'success', text: 'User verified successfully' });
    } catch (e) { 
      setMessage({ type: 'error', text: (e as Error)?.message || 'Failed to verify user' }); 
    }
    setSaving(false);
  };

  const handleReject = async () => {
    if (!user || !rejectionReason.trim()) return;
    setSaving(true);
    try {
      const result = await usersService.rejectUser(user._id, rejectionReason);
      setUser(result.user);
      setRejectDialogOpen(false);
      setRejectionReason('');
      setMessage({ type: 'success', text: 'User verification rejected' });
    } catch (e) { 
      setMessage({ type: 'error', text: (e as Error)?.message || 'Failed to reject user' }); 
    }
    setSaving(false);
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
          User Details & Verification
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Review complete profile information and verify user authenticity
        </Typography>
      </Box>

      {message && (
        <Alert 
          severity={message.type} 
          onClose={() => setMessage(null)} 
          sx={{ mb: 3, borderRadius: 2 }}
        >
          {message.text}
        </Alert>
      )}

      {/* Profile Header */}
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)', border: '1px solid #e2e8f0', mb: 3 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
            {user.profilePhoto ? (
              <Box
                component="img"
                src={user.profilePhoto}
                alt={user.fullName}
                sx={{
                  width: 80,
                  height: 80,
                  borderRadius: '50%',
                  objectFit: 'cover',
                  border: '2px solid #e2e8f0',
                }}
              />
            ) : (
              <Box
                sx={{
                  width: 80,
                  height: 80,
                  borderRadius: '50%',
                  bgcolor: '#f1f5f9',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: '2px solid #e2e8f0',
                }}
              >
                <Typography sx={{ fontSize: 32, color: '#94a3b8' }}>
                  {user.fullName.charAt(0).toUpperCase()}
                </Typography>
              </Box>
            )}
            <Box>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
                <Typography variant="h5" sx={{ fontWeight: 600, color: '#1e293b' }}>
                  {user.fullName}
                </Typography>
                {user.isVerified && (
                  <Chip 
                    icon={<VerifiedUserIcon />} 
                    label="Verified" 
                    size="small"
                    sx={{ 
                      bgcolor: '#dbeafe',
                      color: '#1e40af',
                      fontWeight: 500,
                    }} 
                  />
                )}
              </Box>
              <Typography variant="body2" color="text.secondary">
                {user.email}
              </Typography>
            </Box>
          </Box>
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
            <Chip 
              label={user.isProfileComplete ? 'Profile Complete' : 'Profile Incomplete'} 
              sx={{ 
                bgcolor: user.isProfileComplete ? '#d1fae5' : '#fef3c7',
                color: user.isProfileComplete ? '#065f46' : '#92400e',
                fontWeight: 500,
              }} 
            />
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
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', pt: 2 }}>
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
            <Button 
              variant="outlined" 
              startIcon={<EditIcon />} 
              onClick={() => {
                setSelectedRole(user.role || '');
                setRoleDialogOpen(true);
              }}
              sx={{
                borderColor: '#64748b',
                color: '#64748b',
                '&:hover': { borderColor: '#475569', bgcolor: '#f1f5f9' }
              }}
            >
              {user.role ? 'Edit Role' : 'Set Role'}
            </Button>
            {!user.isVerified ? (
              <>
                <Button 
                  variant="contained" 
                  startIcon={<VerifiedUserIcon />} 
                  onClick={() => setVerifyDialogOpen(true)}
                  sx={{
                    bgcolor: '#28BC79',
                    '&:hover': { bgcolor: '#1E8A5A' }
                  }}
                >
                  Verify User
                </Button>
                <Button 
                  variant="outlined" 
                  startIcon={<CancelIcon />} 
                  onClick={() => setRejectDialogOpen(true)}
                  sx={{
                    borderColor: '#dc2626',
                    color: '#dc2626',
                    '&:hover': { borderColor: '#b91c1c', bgcolor: '#fee2e2' }
                  }}
                >
                  Reject Verification
                </Button>
              </>
            ) : (
              <Button 
                variant="outlined" 
                startIcon={<CancelIcon />} 
                onClick={() => setRejectDialogOpen(true)}
                sx={{
                  borderColor: '#dc2626',
                  color: '#dc2626',
                  '&:hover': { borderColor: '#b91c1c', bgcolor: '#fee2e2' }
                }}
              >
                Revoke Verification
              </Button>
            )}
          </Box>
        </CardContent>
      </Card>

      {/* Complete Profile Information */}
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)', border: '1px solid #e2e8f0' }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
            Complete Profile Information
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
            Review all user details for verification
          </Typography>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Grid container spacing={3}>
            {/* Personal Details */}
            <Grid item xs={12}>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                Personal Details
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Full Name</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.fullName || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Email</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.email || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Mobile</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>
                    {user.hideMobile ? 'Hidden' : (user.mobile || '-')}
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Date of Birth</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>
                    {user.dateOfBirth ? new Date(user.dateOfBirth).toLocaleDateString() : '-'}
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Age</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.age ? `${user.age} years` : '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Gender</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.gender || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Height</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.height ? `${user.height} cm` : '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Complexion</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.complexion || '-'}</Typography>
                </Grid>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            {/* Location */}
            <Grid item xs={12}>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                Location
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Country (Home)</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.country || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Living Country</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.livingCountry || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">State</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.state || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">City</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.city || '-'}</Typography>
                </Grid>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            {/* Religion & Community */}
            <Grid item xs={12}>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                Religion & Community
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Religion</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.religion || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Caste</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.caste || '-'}</Typography>
                </Grid>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            {/* Education & Profession */}
            <Grid item xs={12}>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                Education & Profession
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Education</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.education || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Profession</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.profession || '-'}</Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary">Annual Income</Typography>
                  <Typography variant="body1" sx={{ fontWeight: 500 }}>{user.annualIncome || '-'}</Typography>
                </Grid>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            {/* About & Preferences */}
            <Grid item xs={12}>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                About & Preferences
              </Typography>
              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>About</Typography>
                <Typography variant="body1" sx={{ fontWeight: 500, whiteSpace: 'pre-wrap' }}>
                  {user.about || '-'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>Partner Preferences</Typography>
                <Typography variant="body1" sx={{ fontWeight: 500, whiteSpace: 'pre-wrap' }}>
                  {user.partnerPreferences || '-'}
                </Typography>
              </Box>
            </Grid>

            <Divider sx={{ my: 2 }} />

            {/* Verification Status */}
            {user.verifiedAt && (
              <Grid item xs={12}>
                <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 2, color: '#475569' }}>
                  Verification Status
                </Typography>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="body2" color="text.secondary">Verified At</Typography>
                    <Typography variant="body1" sx={{ fontWeight: 500 }}>
                      {new Date(user.verifiedAt).toLocaleDateString('en-US', { 
                        year: 'numeric', 
                        month: 'long', 
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                      })}
                    </Typography>
                  </Grid>
                  {user.verificationNotes && (
                    <Grid item xs={12}>
                      <Typography variant="body2" color="text.secondary">Verification Notes</Typography>
                      <Typography variant="body1" sx={{ fontWeight: 500, whiteSpace: 'pre-wrap' }}>
                        {user.verificationNotes}
                      </Typography>
                    </Grid>
                  )}
                </Grid>
              </Grid>
            )}
          </Grid>
        </CardContent>
      </Card>

      {/* Verify Dialog */}
      <Dialog open={verifyDialogOpen} onClose={() => !saving && setVerifyDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Verify User</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            After reviewing the user's complete profile, verify this user. You can add optional notes.
          </Typography>
          <TextField
            fullWidth
            multiline
            rows={4}
            label="Verification Notes (Optional)"
            value={verificationNotes}
            onChange={(e) => setVerificationNotes(e.target.value)}
            placeholder="e.g., All documents verified, profile authentic"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setVerifyDialogOpen(false)} disabled={saving}>Cancel</Button>
          <Button onClick={handleVerify} variant="contained" disabled={saving} sx={{ bgcolor: '#28BC79', '&:hover': { bgcolor: '#1E8A5A' } }}>
            {saving ? 'Verifying...' : 'Verify User'}
          </Button>
        </DialogActions>
      </Dialog>

          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            {user.role ? (
              <Chip 
                label={user.role} 
                sx={{ 
                  bgcolor: user.role === 'bride' ? '#fce7f3' : '#dbeafe',
                  color: user.role === 'bride' ? '#be185d' : '#1e40af',
                  fontWeight: 500,
                  textTransform: 'capitalize',
                }} 
              />
            ) : (
              <Chip 
                label="Role Not Set" 
                sx={{ 
                  bgcolor: '#fef3c7',
                  color: '#92400e',
                  fontWeight: 500,
                }} 
              />
            )}
            <Chip 
              label={user.isBlocked ? 'Blocked' : 'Active'} 
              sx={{ 
                bgcolor: user.isBlocked ? '#fee2e2' : '#d1fae5',
                color: user.isBlocked ? '#dc2626' : '#065f46',
                fontWeight: 500,
              }} 
            />
            <Chip 
              label={user.isProfileComplete ? 'Profile Complete' : 'Profile Incomplete'} 
              sx={{ 
                bgcolor: user.isProfileComplete ? '#d1fae5' : '#fef3c7',
                color: user.isProfileComplete ? '#065f46' : '#92400e',
                fontWeight: 500,
              }} 
            />
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
          {!user.role && (
            <Alert severity="info" sx={{ mt: 2, borderRadius: 2 }}>
              <Typography variant="body2">
                Role will be set when the user completes their profile. Admin can manually set the role if needed.
              </Typography>
            </Alert>
          )}
