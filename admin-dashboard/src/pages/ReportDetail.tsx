import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box, Typography, Card, CardContent, Button, TextField, CircularProgress, Chip } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { reportsService } from '../services/reports.service';

export function ReportDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [notes, setNotes] = useState('');
  const [action, setAction] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!id) return;
    reportsService.getReport(id).then((d) => { setReport(d.report || d); setLoading(false); }).catch(() => setLoading(false));
  }, [id]);

  const handleReview = async () => {
    if (!id) return;
    setSubmitting(true);
    try { await reportsService.reviewReport(id, notes); setReport((r: any) => ({ ...r, status: 'reviewed' })); } catch (e) { alert((e as Error)?.message || 'Failed'); }
    setSubmitting(false);
  };

  const handleResolve = async () => {
    if (!id || !action) return;
    setSubmitting(true);
    try { await reportsService.resolveReport(id, action); setReport((r: any) => ({ ...r, status: 'resolved' })); } catch (e) { alert((e as Error)?.message || 'Failed'); }
    setSubmitting(false);
  };

  if (loading) return <Box display="flex" justifyContent="center" p={4}><CircularProgress /></Box>;
  if (!report) return <Typography>Report not found.</Typography>;

  return (
    <Box>
      <Button 
        startIcon={<ArrowBackIcon />} 
        onClick={() => navigate('/reports')} 
        sx={{ mb: 3, color: '#64748b', '&:hover': { bgcolor: '#f1f5f9' } }}
      >
        Back to Reports
      </Button>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, color: '#1e293b', mb: 0.5 }}>
          Report Details
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Review and resolve user reports
        </Typography>
      </Box>
      <Card sx={{ borderRadius: 3, boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', border: '1px solid #e2e8f0', maxWidth: 800 }}>
        <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
            <Box>
              <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b', mb: 1 }}>
                Report #{report._id.slice(-8)}
              </Typography>
              <Chip 
                label={report.status} 
                sx={{ 
                  bgcolor: report.status === 'pending' ? '#fef3c7' : report.status === 'resolved' ? '#d1fae5' : '#e0e7ff',
                  color: report.status === 'pending' ? '#92400e' : report.status === 'resolved' ? '#065f46' : '#3730a3',
                  fontWeight: 500,
                  textTransform: 'capitalize',
                }} 
              />
            </Box>
            <Typography variant="body2" color="text.secondary">
              {new Date(report.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
            </Typography>
          </Box>
        </Box>
        <CardContent sx={{ p: 3 }}>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Reporter
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {report.reporter?.fullName || report.reporterId}
            </Typography>
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Reported User
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {report.reportedUser?.fullName || report.reportedUserId}
            </Typography>
          </Box>
          <Box sx={{ mb: 3 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              Reason
            </Typography>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {report.reason}
            </Typography>
          </Box>
          {report.description && (
            <Box sx={{ mb: 3 }}>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                Description
              </Typography>
              <Typography variant="body1" sx={{ bgcolor: '#f8fafc', p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
                {report.description}
              </Typography>
            </Box>
          )}
          {report.status === 'pending' && (
            <Box sx={{ mt: 3, pt: 3, borderTop: '1px solid #e2e8f0' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2 }}>
                Review Report
              </Typography>
              <TextField 
                fullWidth 
                multiline 
                rows={4}
                label="Review notes" 
                value={notes} 
                onChange={(e) => setNotes(e.target.value)} 
                sx={{ mb: 2 }}
                placeholder="Add your review notes here..."
              />
              <Button 
                variant="contained" 
                onClick={handleReview} 
                disabled={submitting} 
                sx={{ bgcolor: '#28BC79', '&:hover': { bgcolor: '#1E8A5A' } }}
              >
                {submitting ? 'Processing...' : 'Mark as Reviewed'}
              </Button>
            </Box>
          )}
          {(report.status === 'pending' || report.status === 'reviewed') && (
            <Box sx={{ mt: 3, pt: 3, borderTop: '1px solid #e2e8f0' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 2 }}>
                Resolve Report
              </Typography>
              <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'flex-start' }}>
                <TextField 
                  fullWidth
                  size="medium"
                  label="Resolution action" 
                  value={action} 
                  onChange={(e) => setAction(e.target.value)} 
                  placeholder="e.g. Warning sent, User blocked, Content removed"
                  sx={{ flex: 1, minWidth: 300 }}
                />
                <Button 
                  variant="contained" 
                  startIcon={<CheckCircleIcon />} 
                  onClick={handleResolve} 
                  disabled={submitting || !action}
                  sx={{ 
                    bgcolor: '#28BC79', 
                    '&:hover': { bgcolor: '#1E8A5A' },
                    height: '56px',
                  }}
                >
                  {submitting ? 'Processing...' : 'Resolve'}
                </Button>
              </Box>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
}
