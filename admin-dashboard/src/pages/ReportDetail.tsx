import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box, Typography, Card, CardContent, Button, TextField, CircularProgress } from '@mui/material';
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
      <Button startIcon={<ArrowBackIcon />} onClick={() => navigate('/reports')} sx={{ mb: 2 }}>Back</Button>
      <Typography variant="h5" fontWeight="bold" gutterBottom>Report Details</Typography>
      <Card sx={{ maxWidth: 600 }}>
        <CardContent>
          <Typography><strong>Reporter:</strong> {report.reporter?.fullName || report.reporterId}</Typography>
          <Typography><strong>Reported User:</strong> {report.reportedUser?.fullName || report.reportedUserId}</Typography>
          <Typography><strong>Reason:</strong> {report.reason}</Typography>
          {report.description && <Typography><strong>Description:</strong> {report.description}</Typography>}
          <Typography><strong>Status:</strong> {report.status}</Typography>
          <Typography><strong>Date:</strong> {new Date(report.createdAt).toLocaleString()}</Typography>
          {report.status === 'pending' && (
            <Box sx={{ mt: 2 }}>
              <TextField fullWidth multiline label="Review notes" value={notes} onChange={(e) => setNotes(e.target.value)} sx={{ mb: 1 }} />
              <Button variant="contained" onClick={handleReview} disabled={submitting} sx={{ bgcolor: '#28BC79', mr: 1 }}>Mark Reviewed</Button>
            </Box>
          )}
          {(report.status === 'pending' || report.status === 'reviewed') && (
            <Box sx={{ mt: 2 }}>
              <TextField size="small" label="Resolution action" value={action} onChange={(e) => setAction(e.target.value)} placeholder="e.g. Warning sent, User blocked" sx={{ mr: 1, minWidth: 220 }} />
              <Button variant="contained" startIcon={<CheckCircleIcon />} onClick={handleResolve} disabled={submitting || !action} sx={{ bgcolor: '#28BC79' }}>Resolve</Button>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
}
