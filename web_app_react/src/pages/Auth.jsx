import { useState, useEffect } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import useAuthStore from '../store/useAuthStore';

export default function AuthPage() {
  const { user, signIn, error, isLoading, checkSession } = useAuthStore();
  const [form, setForm] = useState({ email: '', password: '' });
  const [localError, setLocalError] = useState('');
  const navigate = useNavigate();

  // Check session on mount
  useEffect(() => {
    checkSession().catch(() => {});
  }, [checkSession]);

  // Redirect if already logged in
  if (user) {
    return <Navigate to="/dashboard" replace />;
  }

  const submit = async (event) => {
    event.preventDefault();
    
    if (isLoading) return;
    
    // Validate form
    if (!form.email.trim() || !form.password.trim()) {
      setLocalError('Please enter both email and password');
      return;
    }
    
    setLocalError('');
    
    try {
      const success = await signIn(form.email, form.password);
      if (success) {
        navigate('/dashboard', { replace: true });
      }
    } catch (err) {
      // Error is handled in store
      console.error('Sign in error:', err);
    }
  };

  const displayError = localError || error;

  return (
    <div className="auth-shell">
      <section className="auth-card">
        <div className="auth-header">
          <div className="auth-logo">
            <div className="icon">VD</div>
            <span>VoltDash</span>
          </div>
          <span className="eyebrow">Staff Access</span>
          <h1>Sign In</h1>
          <p className="auth-description">
            Admin, Sales, and Marketing portal only.
            <br />
            Retail users use the mobile app.
          </p>
        </div>
        
        <form className="auth-form" onSubmit={submit}>
          <label>
            <span>Email</span>
            <input
              type="email"
              value={form.email}
              onChange={(event) => {
                setForm((current) => ({ ...current, email: event.target.value }));
                setLocalError('');
              }}
              placeholder="admin@company.com"
              disabled={isLoading}
              autoComplete="email"
            />
          </label>
          
          <label>
            <span>Password</span>
            <input
              type="password"
              value={form.password}
              onChange={(event) => {
                setForm((current) => ({ ...current, password: event.target.value }));
                setLocalError('');
              }}
              placeholder="Enter your password"
              disabled={isLoading}
              autoComplete="current-password"
            />
          </label>
          
          {displayError && (
            <div className="form-error">
              <span className="error-icon">⚠</span>
              {displayError}
            </div>
          )}
          
          <button 
            className="primary-button auth-submit" 
            type="submit" 
            disabled={isLoading || !form.email || !form.password}
          >
            {isLoading ? (
              <>
                <span className="spinner"></span>
                Signing in...
              </>
            ) : (
              'Sign In'
            )}
          </button>
        </form>
        
        <div className="auth-footer">
          <p>Protected area. Authorized personnel only.</p>
        </div>
      </section>
    </div>
  );
}
