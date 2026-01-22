import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Box, Card, CardContent, TextField, Button, Typography, Alert, Divider } from '@mui/material';
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

  const handleQuickLogin = async () => {
    setEmail('admin@test.com');
    setPassword('test123');
    setError('');
    setLoading(true);
    const res = await login('admin@test.com', 'test123');
    setLoading(false);
    if (res.success) navigate(from, { replace: true });
    else setError(res.message || 'Quick login failed');
  };

  return (
    <Box sx={{ 
      display: 'flex', 
      minHeight: '100vh', 
      alignItems: 'center', 
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 25%, #28BC79 50%, #667eea 100%)',
      backgroundSize: '400% 400%',
      animation: 'gradient 15s ease infinite',
      position: 'relative',
      '&::before': {
        content: '""',
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(255, 255, 255, 0.1)',
        backdropFilter: 'blur(10px)',
      }
    }}>
      <style>{`
        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
      `}</style>
      <Card sx={{ 
        maxWidth: 440, 
        width: '100%', 
        mx: 2,
        boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
        borderRadius: 3,
        position: 'relative',
        zIndex: 1,
      }}>
        <CardContent sx={{ p: 5 }}>
          <Box sx={{ textAlign: 'center', mb: 4 }}>
            <Typography 
              variant="h4" 
              sx={{ 
                fontWeight: 700, 
                background: 'linear-gradient(135deg, #28BC79 0%, #1E8A5A 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                mb: 1,
              }}
            >
              Silah Admin
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Sign in to access the admin dashboard
            </Typography>
          </Box>
          <form onSubmit={handleSubmit}>
            {error && (
              <Alert 
                severity="error" 
                sx={{ 
                  mb: 3, 
                  borderRadius: 2,
                  '& .MuiAlert-icon': {
                    color: '#ef4444',
                  }
                }}
              >
                {error}
              </Alert>
            )}
            <TextField 
              fullWidth 
              label="Email" 
              type="email" 
              value={email} 
              onChange={(e) => setEmail(e.target.value)} 
              required 
              sx={{ mb: 2.5 }}
              autoComplete="email"
            />
            <TextField 
              fullWidth 
              label="Password" 
              type="password" 
              value={password} 
              onChange={(e) => setPassword(e.target.value)} 
              required 
              sx={{ mb: 3 }}
              autoComplete="current-password"
            />
            <Button 
              fullWidth 
              type="submit" 
              variant="contained" 
              disabled={loading} 
              sx={{ 
                bgcolor: '#28BC79', 
                py: 1.5,
                fontSize: '1rem',
                fontWeight: 600,
                '&:hover': { 
                  bgcolor: '#1E8A5A',
                  transform: 'translateY(-1px)',
                },
                transition: 'all 0.2s',
                mb: 2.5,
              }}
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </form>
          <Divider sx={{ my: 3 }}>
            <Typography variant="caption" color="text.secondary" sx={{ px: 2, bgcolor: 'background.paper' }}>
              OR
            </Typography>
          </Divider>
          <Button 
            fullWidth 
            variant="outlined" 
            onClick={handleQuickLogin} 
            disabled={loading}
            sx={{ 
              borderColor: '#28BC79', 
              color: '#28BC79', 
              py: 1.5,
              fontSize: '0.9375rem',
              fontWeight: 500,
              '&:hover': { 
                borderColor: '#1E8A5A', 
                bgcolor: 'rgba(40, 188, 121, 0.05)',
                transform: 'translateY(-1px)',
              },
              transition: 'all 0.2s',
            }}
          >
            Quick Login (Test Mode)
          </Button>
          <Typography 
            variant="caption" 
            display="block" 
            align="center" 
            color="text.secondary" 
            sx={{ mt: 2, fontSize: '0.75rem' }}
          >
            Test credentials: admin@test.com / test123
          </Typography>
        </CardContent>
      </Card>
    </Box>
  );
}
