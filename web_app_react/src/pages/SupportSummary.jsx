import { useEffect, useState } from 'react';
import { ShieldCheck, User, Clock, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';
import { fetchChatSummaries, updateChatSummary } from '../lib/api';
import useAuthStore from '../store/useAuthStore';
import useUiStore from '../store/useUiStore';
import { t } from '../lib/i18n';

export default function SupportSummary() {
  const [summaries, setSummaries] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuthStore();
  const { language, pushToast } = useUiStore();

  useEffect(() => {
    loadSummaries();
  }, []);

  const loadSummaries = async () => {
    try {
      setIsLoading(true);
      const data = await fetchChatSummaries();
      setSummaries(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResolve = async (id) => {
    try {
      await updateChatSummary(id, { 
        resolution_status: 'Resolved',
        resolved_by: user.id
      });
      pushToast({ message: t('success', language) || 'Resolution marked successfully', tone: 'success' });
      loadSummaries();
    } catch (err) {
      pushToast({ message: err.message, tone: 'error' });
    }
  };

  if (isLoading) return (
    <div className="fullscreen-state">
      <RefreshCw className="spinner" size={32} />
      <p>{t('loading', language) || 'Loading support summaries...'}</p>
    </div>
  );

  if (error) return (
    <div className="fullscreen-state error-state">
      <AlertCircle size={40} className="text-danger" />
      <h2>{t('error', language) || 'Data Fetching Error'}</h2>
      <p>{error}</p>
      <button className="primary-button" onClick={loadSummaries}>Try Again</button>
    </div>
  );

  return (
    <div className="page-grid">
      <header className="PageHeader">
        <div className="header-info">
          <h1>{t('supportSummaries', language) || 'Support Overview'}</h1>
          <p className="text-soft">{t('supportDescription', language) || 'Monitor and resolve automated AI support incidents.'}</p>
        </div>
      </header>

      <section className="SectionCard">
        <div className="card-header">
          <div className="header-title">
            <ShieldCheck size={18} />
            <h2>Incident Queue</h2>
          </div>
        </div>

        <div className="table-container">
          <table className="data-table">
            <thead>
              <tr>
                <th>{t('user', language) || 'User'}</th>
                <th>{t('issue', language) || 'Issue Description'}</th>
                <th>{t('status', language) || 'Status'}</th>
                <th>{t('resolvedBy', language) || 'Resolved By'}</th>
                <th>{t('time', language) || 'Timestamp'}</th>
                <th style={{ textAlign: 'right' }}>{t('actions', language) || 'Actions'}</th>
              </tr>
            </thead>
            <tbody>
              {summaries.length === 0 ? (
                <tr>
                  <td colSpan={6} className="empty-state-cell">
                    <div className="empty-content">
                      <CheckCircle2 size={40} className="text-faint" />
                      <p>All incidents resolved! No pending summaries.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                summaries.map((s) => (
                  <tr key={s.id}>
                    <td>
                      <div className="user-cell">
                        <div className="avatar-small">
                          {s.user?.full_name?.[0] || s.user?.email?.[0] || 'U'}
                        </div>
                        <div className="user-meta">
                          <span className="user-name">{s.user?.full_name || 'Anonymous User'}</span>
                          <span className="user-email-small">{s.user?.email || 'No email'}</span>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div className="issue-text">
                        {s.issue_description}
                      </div>
                    </td>
                    <td>
                      <span className={`status-pill ${s.resolution_status?.toLowerCase() === 'resolved' ? 'success' : 'warning'}`}>
                        {s.resolution_status}
                      </span>
                    </td>
                    <td>
                      {s.resolver ? (
                        <div className="resolver-info">
                          <span className="resolver-name">{s.resolver.full_name}</span>
                        </div>
                      ) : (
                        <span className="text-faint">—</span>
                      )}
                    </td>
                    <td>
                      <div className="time-cell">
                        <Clock size={14} />
                        {new Date(s.created_at).toLocaleDateString()}
                        <span className="time-small">{new Date(s.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                      </div>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      {s.resolution_status !== 'Resolved' && (
                        <button
                          className="primary-button small"
                          onClick={() => handleResolve(s.id)}
                        >
                          <CheckCircle2 size={14} />
                          {t('resolve', language) || 'Resolve'}
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
