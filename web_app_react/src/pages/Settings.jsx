import { useEffect, useState } from 'react';
import { fetchCurrentProfile, updateCurrentProfile } from '../lib/commerce';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';
import useUiStore from '../store/useUiStore';

export default function SettingsPage() {
  const [profile, setProfile] = useState(null);
  const { theme, setTheme, pushToast } = useUiStore();

  useEffect(() => {
    fetchCurrentProfile().then(setProfile).catch(console.error);
  }, []);

  const submit = async (event) => {
    event.preventDefault();
    try {
      const nextProfile = await updateCurrentProfile({
        full_name: profile.full_name,
        preferred_language: profile.preferred_language,
      });
      setProfile(nextProfile);
      pushToast({ tone: 'success', message: 'Settings saved.' });
    } catch (error) {
      pushToast({ tone: 'danger', message: error.message });
    }
  };

  return (
    <div className="page-grid">
      <PageHeader eyebrow="Preferences" title="Settings" subtitle="Profile data and workspace theme." />
      {profile && (
        <SectionCard title="Profile settings" subtitle="Stored in Supabase profiles">
          <form className="form-grid" onSubmit={submit}>
            <input value={profile.full_name ?? ''} onChange={(event) => setProfile((current) => ({ ...current, full_name: event.target.value }))} placeholder="Full name" />
            <input value={profile.email ?? ''} disabled />
            <select value={profile.preferred_language} onChange={(event) => setProfile((current) => ({ ...current, preferred_language: event.target.value }))}>
              <option value="en">English</option>
              <option value="ar">Arabic</option>
            </select>
            <select value={theme} onChange={(event) => setTheme(event.target.value)}>
              <option value="light">Light</option>
              <option value="dark">Dark</option>
            </select>
            <button className="primary-button" type="submit">Save settings</button>
          </form>
        </SectionCard>
      )}
    </div>
  );
}
