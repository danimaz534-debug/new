import { useEffect, useMemo, useState } from 'react';
import { fetchOrders, subscribeToTables, updateOrder } from '../lib/commerce';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';
import useUiStore from '../store/useUiStore';

const statuses = ['Preparing', 'Shipped', 'On the way', 'Delivered'];

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const { searchQuery, pushToast } = useUiStore();

  useEffect(() => {
    const load = () => fetchOrders().then(setOrders).catch(console.error);
    load();
    return subscribeToTables('orders-live', ['orders'], load);
  }, []);

  const filteredOrders = useMemo(
    () => orders.filter((order) => [order.id, order.tracking_code, order.profiles?.full_name, order.profiles?.email].join(' ').toLowerCase().includes(searchQuery.toLowerCase())),
    [orders, searchQuery],
  );

  const save = async (id, patch) => {
    try {
      await updateOrder(id, patch);
      pushToast({ tone: 'success', message: 'Order updated.' });
    } catch (error) {
      pushToast({ tone: 'danger', message: error.message });
    }
  };

  return (
    <div className="page-grid">
      <PageHeader eyebrow="Sales workspace" title="Orders" subtitle="Track fulfillment, update status, and manage tracking codes." />
      <SectionCard title="Order table" subtitle="Scrollable on mobile and synchronized with Supabase">
        <div className="table-wrap">
          <table className="data-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>User</th>
                <th>Email</th>
                <th>Price</th>
                <th>Status</th>
                <th>Tracking code</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.map((order) => (
                <tr key={order.id}>
                  <td>{order.id.slice(0, 8)}</td>
                  <td>{order.profiles?.full_name ?? 'Customer'}</td>
                  <td>{order.profiles?.email ?? 'No email'}</td>
                  <td>${Number(order.total_amount).toFixed(2)}</td>
                  <td>
                    <select value={order.status} onChange={(event) => save(order.id, { status: event.target.value })}>
                      {statuses.map((status) => <option key={status} value={status}>{status}</option>)}
                    </select>
                  </td>
                  <td>
                    <input value={order.tracking_code} onChange={(event) => save(order.id, { tracking_code: event.target.value })} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </SectionCard>
    </div>
  );
}
