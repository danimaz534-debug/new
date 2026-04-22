import { useEffect, useMemo, useState } from 'react';
import Modal from '../components/ui/Modal';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';
import { deleteProduct, fetchProducts, saveProduct, subscribeToTables } from '../lib/commerce';
import { supabase } from '../lib/supabase';
import useUiStore from '../store/useUiStore';

const emptyForm = {
  name: '',
  brand: '',
  category: 'Phones',
  price: '',
  discount_percent: '',
  stock: '',
  image_url: '',
  description: '',
  tags: '',
  is_best_seller: false,
  is_featured: false,
  is_hot_deal: false,
};

export default function ProductsPage() {
  const [products, setProducts] = useState([]);
  const [editing, setEditing] = useState(emptyForm);
  const [open, setOpen] = useState(false);
  const [uploading, setUploading] = useState(false);
  const { searchQuery, pushToast } = useUiStore();

  const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    setUploading(true);
    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `${Date.now()}_${Math.random()}.${fileExt}`;
      
      const { error } = await supabase.storage
        .from('product-images')
        .upload(fileName, file);

      if (error) throw error;

      const { data: publicUrlData } = supabase.storage
        .from('product-images')
        .getPublicUrl(fileName);

      setEditing((current) => ({ ...current, image_url: publicUrlData.publicUrl }));
      pushToast({ tone: 'success', message: 'Image uploaded!' });
    } catch (error) {
      pushToast({ tone: 'danger', message: 'Upload failed: ' + error.message });
    } finally {
      setUploading(false);
    }
  };

  useEffect(() => {
    const load = () => fetchProducts().then(setProducts).catch(console.error);
    load();
    return subscribeToTables('products-live', ['products'], load);
  }, []);

  const filteredProducts = useMemo(
    () => products.filter((product) => [product.name, product.brand, product.category].join(' ').toLowerCase().includes(searchQuery.toLowerCase())),
    [products, searchQuery],
  );

  const submit = async (event) => {
    event.preventDefault();
    try {
      await saveProduct(editing);
      setOpen(false);
      setEditing(emptyForm);
      pushToast({ tone: 'success', message: editing.id ? 'Product updated.' : 'Product added.' });
    } catch (error) {
      pushToast({ tone: 'danger', message: error.message });
    }
  };

  const handleDelete = async (id) => {
    try {
      await deleteProduct(id);
      pushToast({ tone: 'success', message: 'Product deleted.' });
    } catch (error) {
      pushToast({ tone: 'danger', message: error.message });
    }
  };

  return (
    <div className="page-grid">
      <PageHeader
        eyebrow="Marketing workspace"
        title="Products"
        subtitle="Manage the live catalog shared with the mobile app."
        actions={<button className="primary-button" type="button" onClick={() => { setEditing(emptyForm); setOpen(true); }}>Add product</button>}
      />

      <SectionCard title="Catalog" subtitle="Grid cards with low-stock visibility">
        <div className="product-grid">
          {filteredProducts.map((product) => (
            <article key={product.id} className="product-card">
              <div className="product-media" style={{ backgroundImage: `url(${product.image_url || ''})` }} />
              <div className="product-body">
                <div className="product-heading">
                  <div>
                    <span className="eyebrow">{product.category}</span>
                    <h3>{product.name}</h3>
                    <p>{product.brand}</p>
                  </div>
                  <strong>${Number(product.price).toFixed(2)}</strong>
                </div>
                <div className="tag-row">
                  {(product.tags ?? []).map((tag) => <span key={tag} className="tag">{tag}</span>)}
                </div>
                <div className="product-flags">
                  <span className={`status-pill ${Number(product.stock) < 5 ? 'danger' : 'success'}`}>Stock {product.stock}</span>
                  {product.is_hot_deal && <span className="status-pill warning">Hot deal</span>}
                  {product.is_featured && <span className="status-pill primary">Featured</span>}
                  {product.is_best_seller && <span className="status-pill neutral">Best seller</span>}
                </div>
                <div className="table-actions">
                  <button className="ghost-button" type="button" onClick={() => { setEditing({ ...product, tags: (product.tags ?? []).join(', ') }); setOpen(true); }}>Edit</button>
                  <button className="ghost-button" type="button" onClick={() => handleDelete(product.id)}>Delete</button>
                </div>
              </div>
            </article>
          ))}
        </div>
      </SectionCard>

      <Modal
        open={open}
        title={editing.id ? 'Edit product' : 'Add product'}
        onClose={() => setOpen(false)}
        footer={<button className="primary-button" type="submit" form="product-form">{editing.id ? 'Save changes' : 'Create product'}</button>}
      >
        <form id="product-form" className="form-grid" onSubmit={submit}>
          <input value={editing.name} onChange={(event) => setEditing((current) => ({ ...current, name: event.target.value }))} placeholder="Name" />
          <input value={editing.brand} onChange={(event) => setEditing((current) => ({ ...current, brand: event.target.value }))} placeholder="Brand" />
          <select value={editing.category} onChange={(event) => setEditing((current) => ({ ...current, category: event.target.value }))}>
            <option value="Phones">Phones</option>
            <option value="Accessories">Accessories</option>
          </select>
          <input value={editing.price} onChange={(event) => setEditing((current) => ({ ...current, price: event.target.value }))} placeholder="Price" type="number" />
          <input value={editing.discount_percent} onChange={(event) => setEditing((current) => ({ ...current, discount_percent: event.target.value }))} placeholder="Discount" type="number" />
          <input value={editing.stock} onChange={(event) => setEditing((current) => ({ ...current, stock: event.target.value }))} placeholder="Stock" type="number" />
          <div className="file-upload-field">
            <label htmlFor="product-image">Product Image</label>
            <input id="product-image" type="file" onChange={handleFileUpload} accept="image/*" disabled={uploading} />
            {uploading && <span>Uploading...</span>}
            {editing.image_url && <img src={editing.image_url} alt="Preview" width="100" style={{ marginTop: '10px' }} />}
          </div>
          <input value={editing.tags} onChange={(event) => setEditing((current) => ({ ...current, tags: event.target.value }))} placeholder="Tags separated by commas" />
          <textarea value={editing.description} onChange={(event) => setEditing((current) => ({ ...current, description: event.target.value }))} placeholder="Description" />
          <label className="checkbox-field"><input type="checkbox" checked={editing.is_best_seller} onChange={(event) => setEditing((current) => ({ ...current, is_best_seller: event.target.checked }))} />Best seller</label>
          <label className="checkbox-field"><input type="checkbox" checked={editing.is_featured} onChange={(event) => setEditing((current) => ({ ...current, is_featured: event.target.checked }))} />Featured</label>
          <label className="checkbox-field"><input type="checkbox" checked={editing.is_hot_deal} onChange={(event) => setEditing((current) => ({ ...current, is_hot_deal: event.target.checked }))} />Hot deal</label>
        </form>
      </Modal>
    </div>
  );
}
