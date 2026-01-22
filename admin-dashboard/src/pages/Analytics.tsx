import { useState, useEffect } from 'react';
import Grid from '@mui/material/GridLegacy';
import { Box, Typography, Card, CardContent, CircularProgress } from '@mui/material';
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
      <Typography variant="h5" fontWeight="bold" gutterBottom>Analytics</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Typography variant="h6" gutterBottom>Revenue (30 days)</Typography>
          <Card><CardContent><Box height={320}><ResponsiveContainer width="100%" height="100%"><LineChart data={revenue}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="date" tick={{ fontSize: 10 }} /><YAxis /><Tooltip /><Line type="monotone" dataKey="value" stroke="#28BC79" strokeWidth={2} /></LineChart></ResponsiveContainer></Box></CardContent></Card>
        </Grid>
        <Grid item xs={12}>
          <Typography variant="h6" gutterBottom>User Growth (30 days)</Typography>
          <Card><CardContent><Box height={320}><ResponsiveContainer width="100%" height="100%"><BarChart data={users}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="date" tick={{ fontSize: 10 }} /><YAxis /><Tooltip /><Bar dataKey="value" fill="#28BC79" /></BarChart></ResponsiveContainer></Box></CardContent></Card>
        </Grid>
      </Grid>
    </Box>
  );
}
