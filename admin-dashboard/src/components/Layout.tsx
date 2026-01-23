import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import {
  Box, AppBar, Toolbar, Typography, IconButton, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Chip,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import FlagIcon from '@mui/icons-material/Flag';
import ReceiptIcon from '@mui/icons-material/Receipt';
import BarChartIcon from '@mui/icons-material/BarChart';
import SettingsIcon from '@mui/icons-material/Settings';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import LogoutIcon from '@mui/icons-material/Logout';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const DRAWER_WIDTH = 280;
const menu = [
  { path: '/', label: 'Dashboard', icon: <DashboardIcon /> },
  { path: '/users', label: 'Users', icon: <PeopleIcon /> },
  { path: '/reports', label: 'Reports', icon: <FlagIcon /> },
  { path: '/transactions', label: 'Transactions', icon: <ReceiptIcon /> },
  { path: '/promo-codes', label: 'Promo Codes', icon: <LocalOfferIcon /> },
  { path: '/analytics', label: 'Analytics', icon: <BarChartIcon /> },
  { path: '/settings', label: 'Settings', icon: <SettingsIcon /> },
];

export function Layout() {
  const [open, setOpen] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();
  const { admin, logout } = useAuth();

  return (
    <Box sx={{ display: 'flex', bgcolor: '#f8fafc', minHeight: '100vh' }}>
      <AppBar 
        position="fixed" 
        sx={{ 
          zIndex: (t) => t.zIndex.drawer + 1, 
          bgcolor: '#ffffff',
          color: '#1e293b',
          boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
          borderBottom: '1px solid #e2e8f0',
        }}
      >
        <Toolbar sx={{ px: 3 }}>
          <IconButton 
            color="inherit" 
            edge="start" 
            onClick={() => setOpen(!open)} 
            sx={{ 
              mr: 2,
              color: '#64748b',
              '&:hover': { bgcolor: '#f1f5f9' }
            }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 600, color: '#1e293b' }}>
            Silah Admin
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Chip 
              label={admin?.email || 'Admin'} 
              size="small"
              sx={{ 
                bgcolor: '#f1f5f9',
                color: '#475569',
                fontWeight: 500,
                height: 32,
              }}
            />
            <IconButton 
              onClick={() => logout().then(() => navigate('/login'))}
              sx={{ 
                color: '#64748b',
                '&:hover': { bgcolor: '#fee2e2', color: '#dc2626' }
              }}
            >
              <LogoutIcon />
            </IconButton>
          </Box>
        </Toolbar>
      </AppBar>
      <Drawer 
        variant="persistent" 
        open={open} 
        sx={{ 
          width: open ? DRAWER_WIDTH : 0,
          flexShrink: 0,
          '& .MuiDrawer-paper': { 
            width: DRAWER_WIDTH, 
            top: 64, 
            boxSizing: 'border-box',
            borderRight: '1px solid #e2e8f0',
            bgcolor: '#ffffff',
            pt: 2,
          } 
        }}
      >
        <List sx={{ px: 2 }}>
          {menu.map((m) => {
            const isSelected = location.pathname === m.path || (m.path === '/' && location.pathname === '/');
            return (
              <ListItem key={m.path} disablePadding sx={{ mb: 0.5 }}>
                <ListItemButton 
                  selected={isSelected}
                  onClick={() => navigate(m.path)}
                  sx={{
                    borderRadius: 2,
                    py: 1.25,
                    px: 2,
                    '&.Mui-selected': {
                      bgcolor: 'rgba(40, 188, 121, 0.1)',
                      color: '#28BC79',
                      '&:hover': {
                        bgcolor: 'rgba(40, 188, 121, 0.15)',
                      },
                      '& .MuiListItemIcon-root': {
                        color: '#28BC79',
                      },
                    },
                    '&:hover': {
                      bgcolor: '#f8fafc',
                    },
                  }}
                >
                  <ListItemIcon sx={{ minWidth: 40, color: isSelected ? '#28BC79' : '#64748b' }}>
                    {m.icon}
                  </ListItemIcon>
                  <ListItemText 
                    primary={m.label} 
                    primaryTypographyProps={{
                      fontWeight: isSelected ? 600 : 500,
                      fontSize: '0.9375rem',
                    }}
                  />
                </ListItemButton>
              </ListItem>
            );
          })}
        </List>
      </Drawer>
      <Box 
        component="main" 
        sx={{ 
          flexGrow: 1, 
          p: 4, 
          mt: 8,
          ml: open ? `${DRAWER_WIDTH}px` : 0,
          transition: 'margin-left 0.3s ease',
          maxWidth: open ? `calc(100% - ${DRAWER_WIDTH}px)` : '100%',
        }}
      >
        <Outlet />
      </Box>
    </Box>
  );
}
