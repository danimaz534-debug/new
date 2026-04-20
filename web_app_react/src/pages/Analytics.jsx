import { useEffect, useState } from 'react';
import { Bar, BarChart, CartesianGrid, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';
import { fetchAnalyticsData, subscribeToTables } from '../lib/commerce';

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState(null);

  useEffect(() => {
    const load = () => fetchAnalyticsData().then(setAnalytics).catch(console.error);
    load();
    return subscribeToTables('analytics-live', ['orders', 'products', 'order_items'], load);
  }, []);

  return (
    <div className="page-grid">
      <PageHeader eyebrow="Admin analysis" title="Analytics" subtitle="Order cadence and product mix from live records." />
      {analytics && (
        <div className="content-grid two-up">
          <SectionCard title="Orders per day" subtitle="Past week">
            <div className="chart-box">
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={analytics.ordersByDay}>
                  <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                  <XAxis dataKey="day" stroke="var(--text-soft)" />
                  <YAxis stroke="var(--text-soft)" />
                  <Tooltip />
                  <Bar dataKey="orders" fill="#2563EB" radius={[8, 8, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </SectionCard>
          <SectionCard title="Category mix" subtitle="Current catalog split">
            <div className="chart-box">
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie data={analytics.categoryMix} dataKey="value" nameKey="name" outerRadius={90} fill="#2563EB" />
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </SectionCard>
        </div>
      )}
    </div>
  );
}
