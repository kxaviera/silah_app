import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Box, Card, CardContent, TextField, Button, Typography, Alert } from '@mui/material';
import { useAuth } from '../context/AuthContext';

export function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const from = (location.state as { from?: { pathname: string } })?.from?.pathname || '/';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    const res = await login(email, password);
    setLoading(false);
    if (res.success) navigate(from, { replace: true });
    else setError(res.message || 'Login failed');
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', alignItems: 'center', justifyContent: 'center', bgcolor: '#f5f5f5' }}>
      <Card sx={{ maxWidth: 400, width: '100%', boxShadow: 4 }}>
        <CardContent sx={{ p: 4 }}>
          <Typography variant="h5" align="center" gutterBottom fontWeight="bold" color="#28BC79">Silah Admin</Typography>
          <Typography variant="body2" align="center" color="text.secondary" sx={{ mb: 3 }}>Sign in to the admin dashboard</Typography>
          <form onSubmit={handleSubmit}>
            {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
            <TextField fullWidth label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required sx={{ mb: 2 }} />
            <TextField fullWidth label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required sx={{ mb: 2 }} />
            <Button fullWidth type="submit" variant="contained" disabled={loading} sx={{ bgcolor: '#28BC79', '&:hover': { bgcolor: '#219a6a' } }}>
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </Box>
  );
}
