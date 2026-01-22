import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Typography, Box, CircularProgress, Card, Button } from '@mui/material';
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
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Dashboard
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Overview of your platform statistics and performance
        </Typography>
      </Box>
      <Grid container spacing={3} sx={{ mb: 4 }}>
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
          <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0' }}>
            <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
                Revenue (30 days)
              </Typography>
            </Box>
            <Box sx={{ p: 3, height: 320 }}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={revenue}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#28BC79" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#28BC79" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="date" tick={{ fontSize: 12, fill: '#64748b' }} stroke="#cbd5e1" />
                  <YAxis tick={{ fontSize: 12, fill: '#64748b' }} stroke="#cbd5e1" />
                  <Tooltip 
                    contentStyle={{ 
                      backgroundColor: '#ffffff',
                      border: '1px solid #e2e8f0',
                      borderRadius: 8,
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    }}
                  />
                  <Area type="monotone" dataKey="value" stroke="#28BC79" strokeWidth={2} fill="url(#colorRevenue)" />
                </AreaChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0' }}>
            <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
                User Growth (30 days)
              </Typography>
            </Box>
            <Box sx={{ p: 3, height: 320 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={users}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="date" tick={{ fontSize: 12, fill: '#64748b' }} stroke="#cbd5e1" />
                  <YAxis tick={{ fontSize: 12, fill: '#64748b' }} stroke="#cbd5e1" />
                  <Tooltip 
                    contentStyle={{ 
                      backgroundColor: '#ffffff',
                      border: '1px solid #e2e8f0',
                      borderRadius: 8,
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    }}
                  />
                  <Line type="monotone" dataKey="value" stroke="#28BC79" strokeWidth={3} dot={{ fill: '#28BC79', r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
      </Grid>
      {s.pendingReports > 0 && (
        <Box sx={{ mt: 4 }}>
          <Card sx={{ bgcolor: '#fef3c7', border: '1px solid #fde68a', borderRadius: 3, p: 2.5 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Box>
                <Typography variant="body1" sx={{ fontWeight: 600, color: '#92400e', mb: 0.5 }}>
                  Action Required
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  You have {s.pendingReports} pending report{s.pendingReports > 1 ? 's' : ''} that need review
                </Typography>
              </Box>
              <Button
                variant="contained"
                onClick={() => navigate('/reports?status=pending')}
                sx={{
                  bgcolor: '#28BC79',
                  '&:hover': { bgcolor: '#1E8A5A' },
                }}
              >
                Review Now
              </Button>
            </Box>
          </Card>
        </Box>
      )}
    </Box>
  );
}
