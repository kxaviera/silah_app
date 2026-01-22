import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Typography, Box, CircularProgress } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { StatCard } from '../components/StatCard';
import { dashboardService } from '../services/dashboard.service';
import type { DashboardStats, ChartDataPoint } from '../services/dashboard.service';
import PeopleIcon from '@mui/icons-material/People';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import FlagIcon from '@mui/icons-material/Flag';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import ChatIcon from '@mui/icons-material/Chat';
import { useNavigate } from 'react-router-dom';

export function Dashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [revenue, setRevenue] = useState<ChartDataPoint[]>([]);
  const [users, setUsers] = useState<ChartDataPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    (async () => {
      setLoading(true);
      const [s, r, u] = await Promise.all([
        dashboardService.getStats(),
        dashboardService.getRevenueChart(30),
        dashboardService.getUserGrowthChart(30),
      ]);
      setStats(s);
      setRevenue(r);
      setUsers(u);
      setLoading(false);
    })();
  }, []);

  if (loading) return <Box display="flex" justifyContent="center" p={4}><CircularProgress /></Box>;

  const s = stats || dashboardService.getMockStats();

  return (
    <Box>
      <Typography variant="h5" fontWeight="bold" gutterBottom>Dashboard</Typography>
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Total Users" value={s.totalUsers} icon={<PeopleIcon />} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Active Boosts" value={s.activeBoosts} icon={<RocketLaunchIcon />} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Pending Reports" value={s.pendingReports} icon={<FlagIcon />} subtitle="Needs review" /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Today's Revenue" value={`₹${s.todayRevenue}`} icon={<AttachMoneyIcon />} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Total Revenue" value={`₹${s.totalRevenue}`} icon={<AttachMoneyIcon />} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="New Users Today" value={s.newUsersToday} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Active Conversations" value={s.activeConversations} icon={<ChatIcon />} /></Grid>
        <Grid item xs={12} sm={6} md={3}><StatCard title="Total Requests" value={s.totalRequests} /></Grid>
      </Grid>
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" gutterBottom>Revenue (30 days)</Typography>
          <Box height={300}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenue}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="date" tick={{ fontSize: 10 }} /><YAxis /><Tooltip /><Area type="monotone" dataKey="value" stroke="#28BC79" fill="#28BC79" fillOpacity={0.3} /></AreaChart>
            </ResponsiveContainer>
          </Box>
        </Grid>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" gutterBottom>User Growth (30 days)</Typography>
          <Box height={300}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={users}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="date" tick={{ fontSize: 10 }} /><YAxis /><Tooltip /><Line type="monotone" dataKey="value" stroke="#28BC79" strokeWidth={2} /></LineChart>
            </ResponsiveContainer>
          </Box>
        </Grid>
      </Grid>
      <Box sx={{ mt: 3, display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        {s.pendingReports > 0 && (
          <Typography component="button" onClick={() => navigate('/reports?status=pending')} sx={{ color: '#28BC79', textDecoration: 'underline', cursor: 'pointer', border: 'none', background: 'none' }}>
            Review {s.pendingReports} pending report(s) →
          </Typography>
        )}
      </Box>
    </Box>
  );
}
