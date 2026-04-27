import { useEffect, useState, useMemo } from 'react';
import { PageHeader } from '../components/ui/SectionCard';
import { supabase } from '../lib/supabase';
import useUiStore from '../store/useUiStore';
import { t } from '../lib/i18n';

export default function FavoritesPage() {
  const [favorites, setFavorites] = useState([]);
  const [products, setProducts] = useState([]);
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [viewMode, setViewMode] = useState('byProduct'); // 'byProduct' or 'byUser'
  const { pushToast, language } = useUiStore();

  useEffect(() => {
    let isMounted = true;

    const load = async () => {
      if (!isMounted) return;
      setIsLoading(true);
      setError(null);

      try {
        // Fetch favorites with product and user details
        const { data: favData, error: favError } = await supabase
          .from('favorites')
          .select(`
            id,
            created_at,
            user:user_id (id, email, full_name),
            product:product_id (id, name, price, discount_percent, category, image_url)
          `)
          .order('created_at', { ascending: false });

        if (favError) throw favError;

        // Fetch all products for stats
        const { data: productsData, error: productsError } = await supabase
          .from('products')
          .select('id, name, price, category, image_url, stock');

        if (productsError) throw productsError;

        // Fetch all users for reference
        const { data: usersData, error: usersError } = await supabase
          .from('profiles')
          .select('id, email, full_name');

        if (usersError) throw usersError;

        if (isMounted) {
          setFavorites(favData || []);
          setProducts(productsData || []);
          setUsers(usersData || []);
        }
      } catch (err) {
        console.error('Failed to load favorites:', err);
        if (isMounted) {
          setError(err.message);
          pushToast({ tone: 'danger', message: `Failed to load: ${err.message}` });
        }
      } finally {
        if (isMounted) setIsLoading(false);
      }
    };

    load();

    // Subscribe to favorites changes
    const channel = supabase.channel('favorites-live');
    channel.on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'favorites' },
      () => load()
    );
    channel.subscribe();

    return () => {
      isMounted = false;
      supabase.removeChannel(channel);
    };
  }, [pushToast]);

  // Group favorites by product
  const favoritesByProduct = useMemo(() => {
    const grouped = {};
    favorites.forEach(fav => {
      const productId = fav.product_id;
      if (!grouped[productId]) {
        grouped[productId] = {
          product: fav.product,
          count: 0,
          users: [],
          latestAdd: fav.created_at,
        };
      }
      grouped[productId].count++;
      grouped[productId].users.push(fav.user);
      if (new Date(fav.created_at) > new Date(grouped[productId].latestAdd)) {
        grouped[productId].latestAdd = fav.created_at;
      }
    });
    return Object.values(grouped).sort((a, b) => b.count - a.count);
  }, [favorites]);

  // Group favorites by user
  const favoritesByUser = useMemo(() => {
    const grouped = {};
    favorites.forEach(fav => {
      const userId = fav.user_id;
      if (!grouped[userId]) {
        grouped[userId] = {
          user: fav.user,
          count: 0,
          products: [],
          latestAdd: fav.created_at,
        };
      }
      grouped[userId].count++;
      grouped[userId].products.push(fav.product);
      if (new Date(fav.created_at) > new Date(grouped[userId].latestAdd)) {
        grouped[userId].latestAdd = fav.created_at;
      }
    });
    return Object.values(grouped).sort((a, b) => b.count - a.count);
  }, [favorites]);

  // Top favorited products
  const topFavorited = favoritesByProduct.slice(0, 5);

  if (isLoading) {
    return (
      <div className="page-grid">
        <PageHeader
          eyebrow={t('admin', language)}
          title={t('favorites', language) || 'Favorites'}
          subtitle="Loading favorites data..."
        />
        <div className="loading-state">
          <div className="spinner" style={{ width: '40px', height: '40px' }}></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-grid">
        <PageHeader
          eyebrow={t('admin', language)}
          title={t('favorites', language) || 'Favorites'}
          subtitle="Error loading data"
        />
        <div className="section-card" style={{ textAlign: 'center', padding: '60px' }}>
          <p style={{ color: 'var(--danger)', marginBottom: '20px' }}>{error}</p>
          <button className="primary-button" onClick={() => window.location.reload()}>
            {t('retry', language) || 'Retry'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="page-grid">
      <PageHeader
        eyebrow={t('admin', language)}
        title={t('favorites', language) || 'Favorites'}
        subtitle={`${favorites.length} total favorites from ${users.length} users`}
      />

      {/* Summary Stats */}
      <div className="stats-grid">
        <div className="stat-card tone-primary">
          <span className="label">Total Favorites</span>
          <span className="value">{favorites.length}</span>
          <span className="meta">Across all users</span>
        </div>
        <div className="stat-card tone-success">
          <span className="label">Products Favorited</span>
          <span className="value">{favoritesByProduct.length}</span>
          <span className="meta">Unique products</span>
        </div>
        <div className="stat-card tone-warning">
          <span className="label">Users Active</span>
          <span className="value">{favoritesByUser.length}</span>
          <span className="meta">Users with favorites</span>
        </div>
        <div className="stat-card tone-danger">
          <span className="label">Top Product</span>
          <span className="value" style={{ fontSize: '1.2rem' }}>
            {topFavorited[0]?.product?.name || 'None'}
          </span>
          <span className="meta">{topFavorited[0]?.count || 0} times</span>
        </div>
      </div>

      {/* View Mode Toggle */}
      <div className="page-actions" style={{ marginBottom: '16px' }}>
        <div className="search-bar" style={{ maxWidth: '400px' }}>
          <button
            className={`ghost-button ${viewMode === 'byProduct' ? 'active' : ''}`}
            onClick={() => setViewMode('byProduct')}
            style={{ borderRadius: 'var(--radius-md) 0 0 var(--radius-md)', marginRight: '-1px' }}
          >
            By Product
          </button>
          <button
            className={`ghost-button ${viewMode === 'byUser' ? 'active' : ''}`}
            onClick={() => setViewMode('byUser')}
            style={{ borderRadius: '0 var(--radius-md) var(--radius-md) 0' }}
          >
            By User
          </button>
        </div>
      </div>

      {/* Top Favorited Products Widget */}
      {viewMode === 'byProduct' && (
        <div className="section-card">
          <div className="section-head">
            <h2>Top Favorited Products</h2>
            <span className="muted-copy">Most popular favorites</span>
          </div>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Category</th>
                  <th>Price</th>
                  <th>Favorite Count</th>
                  <th>Latest Add</th>
                  <th>Stock</th>
                </tr>
              </thead>
              <tbody>
                {favoritesByProduct.map((item, index) => (
                  <tr key={item.product?.id || index}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        {item.product?.image_url ? (
                          <img 
                            src={item.product.image_url} 
                            alt={item.product.name}
                            style={{ width: '32px', height: '32px', borderRadius: '4px', objectFit: 'cover' }}
                          />
                        ) : (
                          <div style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '4px',
                            background: 'var(--bg-muted)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '0.7rem',
                            color: 'var(--text-faint)'
                          }}>
                            {index + 1}
                          </div>
                        )}
                        <div>
                          <strong>{item.product?.name || 'Deleted Product'}</strong>
                          <br />
                          <small style={{ color: 'var(--text-faint)' }}>
                            ID: {item.product?.id?.slice(0, 8) || 'N/A'}
                          </small>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span className="tag">{item.product?.category || 'N/A'}</span>
                    </td>
                    <td>
                      {item.product?.discount_percent > 0 ? (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
                          <strong className="price-tag-gold" style={{ fontSize: '1rem' }}>
                            ${(item.product.price * (1 - item.product.discount_percent / 100)).toFixed(2)}
                          </strong>
                          <span className="discount-badge-premium" style={{ padding: '1px 6px', fontSize: '0.65rem', alignSelf: 'flex-start' }}>
                            -{item.product.discount_percent}%
                          </span>
                        </div>
                      ) : (
                        <strong className="price-tag-gold">${item.product?.price || 'N/A'}</strong>
                      )}
                    </td>
                    <td>
                      <span className="status-pill primary">{item.count} users</span>
                    </td>
                    <td>
                      <small>{new Date(item.latestAdd).toLocaleDateString()}</small>
                    </td>
                    <td>
                      <span className={`status-pill ${item.product?.stock > 10 ? 'success' : item.product?.stock > 0 ? 'warning' : 'danger'}`}>
                        {item.product?.stock || 0} left
                      </span>
                    </td>
                  </tr>
                ))}
                {favoritesByProduct.length === 0 && (
                  <tr>
                    <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-faint)' }}>
                      No favorites yet
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Favorites by User */}
      {viewMode === 'byUser' && (
        <div className="section-card">
          <div className="section-head">
            <h2>Favorites by User</h2>
            <span className="muted-copy">Users and their favorite products</span>
          </div>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Email</th>
                  <th>Favorite Count</th>
                  <th>Latest Favorite</th>
                  <th>Products</th>
                </tr>
              </thead>
              <tbody>
                {favoritesByUser.map((item, index) => (
                  <tr key={item.user?.id || index}>
                    <td>
                      <strong>{item.user?.full_name || 'Unknown User'}</strong>
                    </td>
                    <td>{item.user?.email || 'N/A'}</td>
                    <td>
                      <span className="status-pill primary">{item.count} items</span>
                    </td>
                    <td>
                      <small>{new Date(item.latestAdd).toLocaleDateString()}</small>
                    </td>
                    <td>
                      <div className="tag-row" style={{ maxWidth: '300px' }}>
                        {item.products.slice(0, 3).map((prod, i) => (
                          <span key={i} className="tag" title={prod?.name}>
                            {prod?.name?.slice(0, 15) || 'Deleted'}...
                          </span>
                        ))}
                        {item.products.length > 3 && (
                          <span className="tag">+{item.products.length - 3} more</span>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
                {favoritesByUser.length === 0 && (
                  <tr>
                    <td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-faint)' }}>
                      No users with favorites yet
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
