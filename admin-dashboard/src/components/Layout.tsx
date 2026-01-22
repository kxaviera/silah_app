import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import {
  Box, AppBar, Toolbar, Typography, IconButton, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import FlagIcon from '@mui/icons-material/Flag';
import ReceiptIcon from '@mui/icons-material/Receipt';
import BarChartIcon from '@mui/icons-material/BarChart';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const DRAWER_WIDTH = 260;
const menu = [
  { path: '/', label: 'Dashboard', icon: <DashboardIcon /> },
  { path: '/users', label: 'Users', icon: <PeopleIcon /> },
  { path: '/reports', label: 'Reports', icon: <FlagIcon /> },
  { path: '/transactions', label: 'Transactions', icon: <ReceiptIcon /> },
  { path: '/analytics', label: 'Analytics', icon: <BarChartIcon /> },
  { path: '/settings', label: 'Settings', icon: <SettingsIcon /> },
];

export function Layout() {
  const [open, setOpen] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();
  const { admin, logout } = useAuth();

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar position="fixed" sx={{ zIndex: (t) => t.zIndex.drawer + 1, bgcolor: '#1a1a2e' }}>
        <Toolbar>
          <IconButton color="inherit" edge="start" onClick={() => setOpen(!open)} sx={{ mr: 2 }}>
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" sx={{ flexGrow: 1 }}>Silah Admin</Typography>
          <Typography variant="body2" sx={{ mr: 2 }}>{admin?.email}</Typography>
          <IconButton color="inherit" onClick={() => logout().then(() => navigate('/login'))}>
            <LogoutIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <Drawer variant="persistent" open={open} sx={{ width: open ? DRAWER_WIDTH : 0, '& .MuiDrawer-paper': { width: DRAWER_WIDTH, top: 64, boxSizing: 'border-box', borderRight: '1px solid #eee' } }}>
        <List sx={{ pt: 2 }}>
          {menu.map((m) => (
            <ListItem key={m.path} disablePadding>
              <ListItemButton selected={location.pathname === m.path} onClick={() => navigate(m.path)}>
                <ListItemIcon>{m.icon}</ListItemIcon>
                <ListItemText primary={m.label} />
              </ListItemButton>
            </ListItem>
          ))}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8, ml: open ? 0 : 0 }}>
        <Outlet />
      </Box>
    </Box>
  );
}
