import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Box, CircularProgress } from '@mui/material';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { admin, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }
  if (!admin) return <Navigate to="/login" state={{ from: location }} replace />;
  return <>{children}</>;
}
