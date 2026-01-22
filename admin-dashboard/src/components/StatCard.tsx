import { Card, CardContent, Typography, Box } from '@mui/material';

interface StatCardProps {
  title: string;
  value: string | number;
  icon?: React.ReactNode;
  subtitle?: string;
  color?: string;
}

export function StatCard({ title, value, icon, subtitle, color = '#28BC79' }: StatCardProps) {
  return (
    <Card sx={{ height: '100%', borderRadius: 2, boxShadow: 2 }}>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box>
            <Typography color="text.secondary" variant="body2" gutterBottom>{title}</Typography>
            <Typography variant="h5" fontWeight="bold">{value}</Typography>
            {subtitle && <Typography variant="caption" color="text.secondary">{subtitle}</Typography>}
          </Box>
          {icon && <Box sx={{ color }}>{icon}</Box>}
        </Box>
      </CardContent>
    </Card>
  );
}
