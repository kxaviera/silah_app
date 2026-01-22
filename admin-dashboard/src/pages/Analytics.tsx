import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Box, Typography, Card, CircularProgress } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { dashboardService } from '../services/dashboard.service';
import type { ChartDataPoint } from '../services/dashboard.service';

export function Analytics() {
  const [revenue, setRevenue] = useState<ChartDataPoint[]>([]);
  const [users, setUsers] = useState<ChartDataPoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([dashboardService.getRevenueChart(30), dashboardService.getUserGrowthChart(30)])
      .then(([r, u]) => { setRevenue(r); setUsers(u); })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Box display="flex" justifyContent="center" p={4}><CircularProgress /></Box>;

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Analytics
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Detailed analytics and insights for your platform
        </Typography>
      </Box>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0' }}>
            <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
                Revenue (30 days)
              </Typography>
            </Box>
            <Box sx={{ p: 3, height: 360 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={revenue}>
                  <defs>
                    <linearGradient id="colorRevenueLine" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#28BC79" stopOpacity={0.8}/>
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
                  <Line type="monotone" dataKey="value" stroke="#28BC79" strokeWidth={3} dot={{ fill: '#28BC79', r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
        <Grid item xs={12}>
          <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0' }}>
            <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
                User Growth (30 days)
              </Typography>
            </Box>
            <Box sx={{ p: 3, height: 360 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={users}>
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
                  <Bar dataKey="value" fill="#28BC79" radius={[8, 8, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
