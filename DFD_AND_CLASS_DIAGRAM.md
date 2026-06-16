# VoltCart - Data Flow Diagrams & Class Diagram

---

## DFD Level 0 (Context Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                              VoltCart E-Commerce Platform                       │
│                                                                                 │
│  ┌──────────┐                                                          ┌────────┐│
│  │          │  browse products, add to cart, place orders,            │        ││
│  │ Customer │  manage profile/addresses/favorites, chat, reviews      │ Mobile ││
│  │ (User)   │────────────────────────────────────────────────────────│  App   ││
│  │          │  product catalog, order status, notifications,          │(Flutter)│
│  │          │  chat messages, profile data                            │        ││
│  └──────────┘                                                          └────┬───┘│
│                                                                             │     │
│                                                                             │     │
│                                    ┌────────────────────────────────────────┘     │
│                                    │                                              │
│                                    ▼                                              │
│                           ┌────────────────┐                                      │
│                           │                │                                      │
│                           │   Supabase     │                                      │
│                           │   Backend      │                                      │
│                           │   (PostgreSQL, │                                      │
│                           │    Auth,       │                                      │
│                           │    Storage,    │                                      │
│                           │    Realtime,   │                                      │
│                           │    Edge Funcs) │                                      │
│                           │                │                                      │
│                           └───────┬────────┘                                      │
│                                   │                                               │
│                                   │                                               │
│  ┌──────────┐                     │                     ┌────────┐                │
│  │          │  manage users,      │                     │        │                │
│  │  Admin   │  products, orders,  │                     │  Web   │                │
│  │ (Staff)  │  view analytics,    │─────────────────────│  Admin │                │
│  │          │  chat with users,   │  dashboard data,    │Dashboard│                │
│  │          │  export reports     │  user/product/order │(React) │                │
│  └──────────┘  CRUD operations    │  management         │        │                │
│                                   │                     └────────┘                │
│                                                                                 │
│  ┌──────────┐                                                                   │
│  │          │  AI chat responses                                                │
│  │  Gemini  │───────────────────────────────────────────────────────────────────┤
│  │  AI API  │                                                                   │
│  └──────────┘                                                                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### External Entities:
| Entity | Description |
|---|---|
| **Customer (User)** | End user browsing products, shopping, managing profile |
| **Admin (Staff)** | Admin/sales/marketing staff managing the platform |
| **Gemini AI API** | Google Gemini 2.5 Flash for AI chat responses |

### Data Stores (Level 0):
| Store | Description |
|---|---|
| **Supabase Backend** | PostgreSQL database, Auth, Storage, Realtime subscriptions, Edge Functions |

---

## DFD Level 1

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                         │
│                                    VoltCart Platform                                    │
│                                                                                         │
│  ┌──────────┐         ┌──────────────────────────────────────────────────────────┐      │
│  │          │         │                                                          │      │
│  │ Customer │────┐    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │      │
│  │ (User)   │    │    │  │             │  │             │  │             │      │      │
│  └──────────┘    │    │  │  1.0 Auth   │  │  2.0 Catalog│  │  3.0 Cart   │      │      │
│                  │    │  │  Management │  │  Browsing   │  │  Management │      │      │
│                  ├───►│  │             │  │             │  │             │      │      │
│                  │    │  │ Sign In/Up  │  │ Fetch Prod  │  │ Add/Remove  │      │      │
│                  │    │  │ OAuth       │  │ Filter/Search│ │ Update Qty  │      │      │
│                  │    │  │ Profile CRUD│  │ Categories  │  │ Clear Cart  │      │      │
│                  │    │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │      │
│                  │    │         │                │                │              │      │
│                  │    │         │                │                │              │      │
│                  │    │  ┌──────┴──────┐  ┌──────┴──────┐  ┌──────┴──────┐      │      │
│                  │    │  │             │  │             │  │             │      │      │
│                  │    │  │  4.0 Order  │  │  5.0 Chat   │  │  6.0 Reviews│      │      │
│                  ├───►│  │  Processing │  │  & Support  │  │  & Ratings  │      │      │
│                  │    │  │             │  │             │  │             │      │      │
│                  │    │  │ Checkout    │  │ Send/Recv   │  │ Add Review  │      │      │
│                  │    │  │ View Orders │  │ AI Response │  │ Add Comment │      │      │
│                  │    │  │ Track Order │  │ Admin Reply │  │ View Rating │      │      │
│                  │    │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │      │
│                  │    │         │                │                │              │      │
│                  │    │         │                │                │              │      │
│                  │    │  ┌──────┴──────┐  ┌──────┴──────┐  ┌──────┴──────┐      │      │
│                  │    │  │             │  │             │  │             │      │      │
│                  │    │  │  7.0 User   │  │  8.0 Notif  │  │  9.0 Wholesale│     │      │
│                  ├───►│  │  Profile &  │  │  Management │  │  Program    │      │      │
│                  │    │  │  Addresses  │  │             │  │             │      │      │
│                  │    │  │             │  │ Fetch/Mark  │  │ Check Status│      │      │
│                  │    │  │ CRUD Addr   │  │ Real-time   │  │ Apply       │      │      │
│                  │    │  │ Favorites   │  │ Subscribe   │  │ Role-based  │      │      │
│                  │    │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │      │
│                  │    │         │                │                │              │      │
│                  │    └─────────┼────────────────┼────────────────┼──────────────┘      │
│                  │              │                │                │                     │
│                  │              ▼                ▼                ▼                     │
│                  │    ┌──────────────────────────────────────────────────┐              │
│                  │    │                                                  │              │
│                  │    │              Supabase Backend                    │              │
│                  │    │                                                  │              │
│                  │    │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │              │
│                  │    │  │  profiles  │ │  products  │ │   orders   │  │              │
│                  │    │  └────────────┘ └────────────┘ └────────────┘  │              │
│                  │    │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │              │
│                  │    │  │ cart_items │ │ favorites  │ │   reviews  │  │              │
│                  │    │  └────────────┘ └────────────┘ └────────────┘  │              │
│                  │    │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │              │
│                  │    │  │user_address│ │chat_threads│ │chat_messages│  │              │
│                  │    │  └────────────┘ └────────────┘ └────────────┘  │              │
│                  │    │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │              │
│                  │    │  │notifications│ │product_    │ │  scheduled │  │              │
│                  │    │  └────────────┘ │comments    │ │   _jobs    │  │              │
│                  │    │                 └────────────┘ └────────────┘  │              │
│                  │    └──────────────────────────────────────────────────┘              │
│                  │                              │                                      │
│                  │                              │                                      │
│  ┌──────────┐    │                              │                                      │
│  │          │    │         ┌────────────────────┼──────────────────────────┐           │
│  │  Admin   │    │         │                    │                          │           │
│  │ (Staff)  │────┤         │  ┌─────────────────┼──────────────────────┐   │           │
│  └──────────┘    │         │  │                 │                      │   │           │
│                  │         │  │  10.0 User Mgmt│  11.0 Product Mgmt   │   │           │
│                  │         │  │                 │                      │   │           │
│                  │         │  │ Create/Edit/   │  Create/Edit/Delete  │   │           │
│                  │         │  │ Delete Users   │  Products CRUD        │   │           │
│                  │         │  │ Soft Delete    │  Manage Comments      │   │           │
│                  │         │  │ Role Assignment│                       │   │           │
│                  │         │  └─────────────────┼──────────────────────┘   │           │
│                  │         │                    │                          │           │
│                  │         │  ┌─────────────────┼──────────────────────┐   │           │
│                  │         │  │                 │                      │   │           │
│                  │         │  │  12.0 Order Mgmt│  13.0 Analytics      │   │           │
│                  │         │  │                 │                      │   │           │
│                  │         │  │ View/Update     │  Dashboard Metrics   │   │           │
│                  │         │  │ Order Status    │  Revenue/Orders      │   │           │
│                  │         │  │ Track Orders    │  Export PDF/Word     │   │           │
│                  │         │  └─────────────────┼──────────────────────┘   │           │
│                  │         │                    │                          │           │
│                  │         │  ┌─────────────────┼──────────────────────┐   │           │
│                  │         │  │                 │                      │   │           │
│                  │         │  │  14.0 Chat Mgmt│  15.0 Notif Mgmt     │   │           │
│                  │         │  │                 │                      │   │           │
│                  │         │  │ View Threads   │  View Notifications  │   │           │
│                  │         │  │ Send Messages  │  Mark as Read        │   │           │
│                  │         │  │ Delete Messages│  Clear All           │   │           │
│                  │         │  └─────────────────┼──────────────────────┘   │           │
│                  │         │                    │                          │           │
│                  │         │                    ▼                          │           │
│                  │         │         ┌────────────────────┐                │           │
│                  │         │         │   Supabase Backend │                │           │
│                  │         │         │   (Same as above)  │                │           │
│                  │         │         └────────────────────┘                │           │
│                  │         │                                               │           │
│                  │         │              Web Admin Dashboard               │           │
│                  │         └───────────────────────────────────────────────┘           │
│                  │                                                                     │
│                  │                              │                                      │
│                  │                              ▼                                      │
│                  │                    ┌─────────────────┐                              │
│                  │                    │   Gemini AI API │                              │
│                  │                    │   (Chat Bot)    │                              │
│                  │                    └─────────────────┘                              │
│                  │                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Process Descriptions:

| Process | Description | Inputs | Outputs |
|---|---|---|---|
| **1.0 Auth Management** | User registration, login (email/OAuth), profile CRUD | Email, password, OAuth token | Auth token, profile data |
| **2.0 Catalog Browsing** | Fetch products, filter, search, categories | Filter params, search query | Product list |
| **3.0 Cart Management** | Add/remove/update cart items | Product ID, quantity | Updated cart |
| **4.0 Order Processing** | Checkout, view orders, track status | Cart, address, payment | Order confirmation |
| **5.0 Chat & Support** | User chat, AI responses, admin replies | Message text | Chat messages |
| **6.0 Reviews & Ratings** | Add/view product reviews and ratings | Rating, comment | Review data |
| **7.0 User Profile & Addresses** | Manage profile, addresses, favorites | Profile/address data | Updated profile |
| **8.0 Notification Management** | Fetch/mark notifications, real-time subscribe | User ID | Notifications |
| **9.0 Wholesale Program** | Check wholesale status, apply | User role | Wholesale status |
| **10.0 User Management (Admin)** | CRUD users, soft delete, roles | User data | User list |
| **11.0 Product Management (Admin)** | CRUD products, manage comments | Product data | Product list |
| **12.0 Order Management (Admin)** | View/update orders, tracking | Order updates | Order list |
| **13.0 Analytics (Admin)** | Dashboard metrics, export reports | Aggregated data | Reports (PDF/Word) |
| **14.0 Chat Management (Admin)** | View threads, send messages, delete | Message text | Chat data |
| **15.0 Notification Management (Admin)** | View/mark/clear notifications | Notification ID | Notification list |

### Data Stores:

| Store | Tables | Description |
|---|---|---|
| **Supabase Backend** | profiles, products, orders, order_items, cart_items, favorites, reviews, product_comments, product_ratings, chat_threads, chat_messages, chat_summaries, scheduled_jobs, notifications, user_addresses | All application data |

---

## Class Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                         │
│                                    MOBILE APP (Flutter)                                 │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    SERVICE CLASSES                                      │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│        AuthService          │    │       CartService           │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + currentUser: User         │    │ + fetchCart(): List         │
│ + authChanges: Stream       │    │ + addToCart(productId, qty) │
│ + currentSession: Session   │    │ + updateQuantity(itemId, qty)│
│ + authProvider: String      │    │ + removeItem(itemId)        │
│ + isOAuthUser: bool         │    │ + clearCart()               │
├─────────────────────────────┤    └─────────────────────────────┘
│ + signIn(email, password)   │
│ + signUp(email, password,   │    ┌─────────────────────────────┐
│   fullName)                 │    │      CatalogService         │
│ + signInWithGoogle()        │    ├─────────────────────────────┤
│ + signInWithGitHub()        │    │ + fetchProducts(): List     │
│ + signOut()                 │    │ + fetchProductsPaginated(   │
│ + updatePassword(newPass)   │    │   page, pageSize, category, │
│ + resetPassword(email)      │    │   brand, searchQuery): List │
└─────────────────────────────┘    └─────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│       ChatService           │    │     FavoritesService        │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + ensureThread(): Thread    │    │ + fetchFavoriteIds(): Set   │
│ + fetchThread(threadId)     │    │ + addFavorite(productId)    │
│ + fetchMessages(threadId)   │    │ + removeFavorite(productId) │
│ + sendMessage(threadId, msg)│    └─────────────────────────────┘
│ + triggerAiResponse(threadId)│
└─────────────────────────────┘    ┌─────────────────────────────┐
│       OrderService          │
├─────────────────────────────┤    │      ProfileService         │
│ + fetchOrders(): List       │    ├─────────────────────────────┤
│ + createOrderFromCart(      │    │ + fetchCurrentProfile()     │
│   paymentMethod, address)   │    │ + ensureProfile(role, name) │
└─────────────────────────────┘    │ + updateProfile(name, lang) │
│ + updateAvatar(avatarUrl)   │
┌─────────────────────────────┐    └─────────────────────────────┘
│      ReviewService          │
├─────────────────────────────┤    ┌─────────────────────────────┐
│ + fetchReviews(productId)   │    │    NotificationHandler      │
│ + fetchProductComments(     │    ├─────────────────────────────┤
│   productId, limit, offset) │    │ + instance: singleton       │
│ + fetchProductRating(       │    │ + addListener(callback)     │
│   productId)                │    │ + removeListener(callback)  │
│ + addReview(productId,      │    │ + initialize(userId)        │
│   rating, comment)          │    │ + fetchPendingNotifications()│
│ + submitComment(productId,  │    └─────────────────────────────┘
│   rating, title, comment)   │
└─────────────────────────────┘    ┌─────────────────────────────┐
│     NotificationsService    │
├─────────────────────────────┤    │      AddressService         │
│ + fetchNotifications(): List│    ├─────────────────────────────┤
│ + markAsRead(id)            │    │ + fetchUserAddresses(): List│
└─────────────────────────────┘    │ + createAddress(address)    │
│ + updateAddress(address)    │
│ + deleteAddress(addressId)  │
│ + getDefaultAddress()       │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    MODEL CLASSES                                        │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│          Product            │    │          AppUser            │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + id: String                │    │ + id: String                │
│ + name: String              │    │ + email: String             │
│ + description: String       │    │ + fullName: String          │
│ + category: String          │    │ + avatarUrl: String         │
│ + brand: String             │    │ + role: String              │
│ + price: double             │    │ + isBlocked: bool           │
│ + discountPercent: int      │    │ + preferredLanguage: String │
│ + stock: int                │    │ + createdAt: DateTime       │
│ + tags: List<String>        │    │ + lastSeenAt: DateTime      │
│ + imageUrl: String          │    ├─────────────────────────────┤
│ + isBestSeller: bool        │    │ + isWholesale: bool (getter)│
│ + isFeatured: bool          │    │ + isAdmin: bool (getter)    │
│ + isHotDeal: bool           │    │ + displayName: String (getter)│
│ + slug: String              │    │ + shortRole: String (getter)│
│ + createdAt: DateTime       │    │ + fromMap(map): AppUser     │
├─────────────────────────────┤    └─────────────────────────────┘
│ + discountedPrice: double   │
│ + isLowStock: bool          │    ┌─────────────────────────────┐
│ + isOutOfStock: bool        │    │         CartEntry           │
│ + fromMap(map): Product     │    ├─────────────────────────────┤
└─────────────────────────────┘    │ + id: String                │
│ + product: Product          │
┌─────────────────────────────┐    │ + quantity: int             │
│         ChatThread          │    │ + createdAt: DateTime       │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + id: String                │    │ + total: double (getter)    │
│ + userId: String            │    │ + fromMap(map): CartEntry   │
│ + assignedSalesId: String   │    └─────────────────────────────┘
│ + aiModeActive: bool        │
│ + awaitingAdminResponse:    │    ┌─────────────────────────────┐
│   bool                      │    │        ChatMessage          │
│ + createdAt: DateTime       │    ├─────────────────────────────┤
├─────────────────────────────┤    │ + id: String                │
│ + fromMap(map): ChatThread  │    │ + threadId: String          │
└─────────────────────────────┘    │ + senderId: String          │
│ + senderType: String        │
┌─────────────────────────────┐    │ + message: String           │
│       OrderSummary          │    │ + createdAt: DateTime       │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + id: String                │    │ + isUser: bool (getter)     │
│ + userId: String            │    │ + isAI: bool (getter)       │
│ + paymentMethod: String     │    │ + isAdmin: bool (getter)    │
│ + status: String            │    │ + fromMap(map): ChatMessage │
│ + subtotal: double          │    └─────────────────────────────┘
│ + loyaltyDiscount: double   │
│ + totalAmount: double       │    ┌─────────────────────────────┐
│ + shippingAddress: Map      │    │       UserAddress           │
│ + trackingCode: String      │    ├─────────────────────────────┤
│ + createdAt: DateTime       │    │ + id: String                │
│ + items: List<OrderLineItem>│    │ + userId: String            │
├─────────────────────────────┤    │ + fullName: String          │
│ + fromMap(map): OrderSummary│    │ + phone: String             │
└─────────────────────────────┘    │ + city: String              │
│ + street: String            │
┌─────────────────────────────┐    │ + building: String          │
│       OrderLineItem         │    │ + notes: String             │
├─────────────────────────────┤    │ + isDefault: bool           │
│ + id: String                │    │ + createdAt: DateTime       │
│ + orderId: String           │    ├─────────────────────────────┤
│ + productId: String         │    │ + fromMap(map): UserAddress │
│ + quantity: int             │    │ + toMap(includeId): Map     │
│ + unitPrice: double         │    │ + copyWith(...): UserAddress│
│ + discountPercent: int      │    └─────────────────────────────┘
├─────────────────────────────┤
│ + discountedUnitPrice:      │    ┌─────────────────────────────┐
│   double (getter)           │    │      AppNotification        │
│ + fromMap(map): OrderLineItem    ├─────────────────────────────┤
└─────────────────────────────┘    │ + id: String                │
│ + userId: String            │
┌─────────────────────────────┐    │ + title: String             │
│      ProductComment         │    │ + body: String              │
├─────────────────────────────┤    │ + type: String              │
│ + id: String                │    │ + isRead: bool              │
│ + userId: String            │    │ + createdAt: DateTime       │
│ + productId: String         │    ├─────────────────────────────┤
│ + rating: int               │    │ + fromMap(map): Notification│
│ + title: String             │    └─────────────────────────────┘
│ + comment: String           │
│ + isVerifiedPurchase: bool  │    ┌─────────────────────────────┐
│ + createdAt: DateTime       │    │     ShippingAddress         │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + fromMap(map): Comment     │    │ + toJson(): Map             │
└─────────────────────────────┘    └─────────────────────────────┘

┌─────────────────────────────┐
│      ProductRating          │
├─────────────────────────────┤
│ + productId: String         │
│ + averageRating: double     │
│ + totalReviews: int         │
├─────────────────────────────┤
│ + fromMap(map): Rating      │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    PROVIDER CLASS                                       │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                               AppStateProvider (ChangeNotifier)                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ + currentUser: AppUser                                                                  │
│ + products: List<Product>                                                               │
│ + cart: List<CartEntry>                                                                 │
│ + favorites: Set<String>                                                                │
│ + orders: List<OrderSummary>                                                            │
│ + notifications: List<AppNotification>                                                  │
│ + watchHistory: List<Product>                                                           │
│ + userAddresses: List<UserAddress>                                                      │
│ + chatMessages: List<ChatMessage>                                                       │
│ + isAuthenticated: bool                                                                 │
│ + isWholesale: bool                                                                     │
│ + isBusy: bool                                                                          │
│ + searchQuery: String                                                                   │
│ + selectedCategory: String                                                              │
│ + priceCap: double                                                                      │
│ + sort: String                                                                          │
│ + themeMode: ThemeMode                                                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ + bootstrap()                                                                           │
│ + signIn(email, password)                                                               │
│ + signUp(fullName, email, password)                                                     │
│ + signInWithGoogle()                                                                    │
│ + signInWithGitHub()                                                                    │
│ + signOut() / logout()                                                                  │
│ + loadReviews(productId)                                                                │
│ + addToCart(product, quantity)                                                          │
│ + updateCartItemQuantity(entry, quantity)                                               │
│ + removeCartItem(entry)                                                                 │
│ + updateCartQuantity(productId, quantity)                                               │
│ + removeFromCart(productId)                                                             │
│ + toggleFavorite(product)                                                               │
│ + checkout(paymentMethod, shippingAddress)                                              │
│ + prepareChat(showLoader, markAsRead)                                                   │
│ + sendChatMessage(message)                                                              │
│ + markChatAsRead()                                                                      │
│ + clearBlockedFlag()                                                                    │
│ + markNotificationRead(notificationId)                                                  │
│ + updateProfile(fullName, preferredLanguage)                                            │
│ + changePassword(newPassword)                                                           │
│ + updateAvatar(avatarUrl)                                                               │
│ + setThemeMode(mode)                                                                    │
│ + setSearchQuery(value)                                                                 │
│ + setSelectedCategory(value)                                                            │
│ + setPriceCap(value)                                                                    │
│ + setSort(value)                                                                        │
│ + refreshAll()                                                                          │
│ + loadCart()                                                                            │
│ + loadFavorites()                                                                       │
│ + loadOrders()                                                                          │
│ + loadNotifications()                                                                   │
│ + loadUserAddresses()                                                                   │
│ + createAddress(address)                                                                │
│ + updateAddress(address)                                                                │
│ + deleteAddress(addressId)                                                              │
│ + getProductComments(productId)                                                         │
│ + getProductRating(productId)                                                           │
│ + loadProductComments(productId)                                                        │
│ + loadProductRating(productId)                                                          │
│ + submitProductComment(productId, rating, title, comment)                               │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    WEB APP (React)                                      │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    API MODULES                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│         users.js            │    │        products.js          │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + ensureProfile(role, user) │    │ + fetchProducts(): List     │
│ + fetchCurrentProfile(user) │    │ + saveProduct(product)      │
│ + updateCurrentProfile(patch)│   │ + deleteProduct(id)         │
│ + fetchUsers(): List        │    │ + fetchProductComments():List│
│ + updateUser(id, patch)     │    │ + deleteProductComment(id)  │
│ + deleteUser(id)            │    └─────────────────────────────┘
│ + permanentlyDeleteUser(id) │
│ + restoreUser(id)           │    ┌─────────────────────────────┐
│ + fetchDeletedUsers(): List │    │         orders.js          │
│ + createUser(email, pass,   │    ├─────────────────────────────┤
│   fullName, role)           │    │ + fetchOrders(): List       │
│ + resetUserPassword(userId, │    │ + updateOrder(id, patch)    │
│   newPassword)              │    └─────────────────────────────┘
└─────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│          chat.js            │    │       dashboard.js          │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + fetchChatThreads(): List  │    │ + fetchDashboardData(): Map │
│ + fetchMessages(threadId)   │    │ + fetchAnalyticsData(): Map │
│ + sendSalesMessage(threadId,│    └─────────────────────────────┘
│   message)                  │
│ + deleteChatMessages(       │    ┌─────────────────────────────┐
│   threadId)                 │    │        favorites.js         │
│ + fetchChatSummaries(): List│    ├─────────────────────────────┤
│ + updateChatSummary(id,     │    │ + fetchFavoriteCountsBy     │
│   updates)                  │    │   Product(): Map            │
└─────────────────────────────┘    └─────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│      notifications.js       │    │         client.js           │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + fetchNotifications(): List│    │ + requireClient()           │
│ + markNotificationRead(id)  │    │ + dedupeRequest(key, fn, ms)│
│ + clearAllNotifications()   │    │ + withRetry(fn, maxRetries) │
└─────────────────────────────┘    │ + monthKey(dateValue)       │
│ + monthLabel(dateValue)     │
│ + activityStatus(timestamp) │
│ + activityLabel(timestamp)  │
│ + formatTimestamp(timestamp)│
│ + formatMessageTime(timestamp)│
│ + formatFullDateTime(timestamp)│
│ + touchStaffPresence(force) │
│ + subscribeToTables(name,   │
│   tables, onChange)         │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    ZUSTAND STORES                                       │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│       useAuthStore          │    │        useUiStore           │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + user: User                │    │ + theme: String             │
│ + session: Session          │    │ + language: String          │
│ + profile: Profile          │    │ + sidebarCollapsed: bool    │
│ + isAuthenticated: bool     │    │ + mobileSidebarOpen: bool   │
│ + isLoading: bool           │    │ + searchQuery: String       │
│ + error: String             │    │ + toasts: List              │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + checkSession()            │    │ + setTheme(theme)           │
│ + resetActivityTimer()      │    │ + setLanguage(language)     │
│ + trackActivity()           │    │ + toggleSidebar()           │
│ + signIn(email, password)   │    │ + openMobileSidebar()       │
│ + signOut()                 │    │ + closeMobileSidebar()      │
└─────────────────────────────┘    │ + setSearchQuery(query)     │
│ + pushToast(toast)          │
│ + removeToast(id)           │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    LIB UTILITIES                                        │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│        roles.js             │    │        i18n.js              │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + getRoleLabel(role, lang)  │    │ + t(key, language): String  │
│ + isStaffRole(role): bool   │    └─────────────────────────────┘
│ + canAccess(role, allowed): │
│   bool                      │    ┌─────────────────────────────┐
└─────────────────────────────┘    │      exportUtils.js         │
├─────────────────────────────┤
│      authProviders.js       │    │ + exportAnalyticsToPDF(     │
├─────────────────────────────┤    │   analytics, language)      │
│ + getAuthProvider(user)     │    │ + exportAnalyticsToWord(    │
│ + getProviderMeta(provider) │    │   analytics, language)      │
│ + isOAuthProvider(provider) │    └─────────────────────────────┘
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    EDGE FUNCTIONS                                       │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│    ai-chat-responder        │    │    ai-timeout-processor     │
├─────────────────────────────┤    ├─────────────────────────────┤
│ + serve(req)                │    │ + serve(req)                │
│ + handleUserMessage(        │    └─────────────────────────────┘
│   supabase, payload, key)   │
│ + processTimeout(           │    ┌─────────────────────────────┐
│   supabase, payload, key)   │    │        create-user          │
│ + instantAiReply(           │    ├─────────────────────────────┤
│   supabase, payload, key)   │    │ + serve(req)                │
│ + fetchDatabaseContext(     │    └─────────────────────────────┘
│   supabase)                 │
│ + generateAiReply(          │    ┌─────────────────────────────┐
│   supabase, threadId, key)  │    │    delete-chat-messages     │
└─────────────────────────────┘    ├─────────────────────────────┤
│ + serve(req)                │
┌─────────────────────────────┐    └─────────────────────────────┘
│    permanent-delete-user    │
├─────────────────────────────┤    ┌─────────────────────────────┐
│ + serve(req)                │    │     reset-user-password     │
└─────────────────────────────┘    ├─────────────────────────────┤
│ + serve(req)                │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    DATABASE TABLES                                      │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│         profiles            │    │         products            │
├─────────────────────────────┤    ├─────────────────────────────┤
│ id: uuid (PK)               │    │ id: uuid (PK)               │
│ email: text                 │    │ name: text                  │
│ full_name: text             │    │ description: text           │
│ avatar_url: text            │    │ category: text              │
│ role: text                  │    │ brand: text                 │
│ is_blocked: boolean         │    │ price: numeric              │
│ preferred_language: text    │    │ discount_percent: integer   │
│ created_at: timestamptz     │    │ stock: integer              │
│ last_seen_at: timestamptz   │    │ tags: text[]                │
│ deleted_at: timestamptz     │    │ image_url: text             │
└─────────────────────────────┘    │ is_best_seller: boolean     │
│ is_featured: boolean        │
┌─────────────────────────────┐    │ is_hot_deal: boolean        │
│          orders             │    │ slug: text                  │
├─────────────────────────────┤    │ created_at: timestamptz     │
│ id: uuid (PK)               │    └─────────────────────────────┘
│ user_id: uuid (FK)          │
│ payment_method: text        │    ┌─────────────────────────────┐
│ status: text                │    │        order_items          │
│ subtotal: numeric           │    ├─────────────────────────────┤
│ loyalty_discount: numeric   │    │ id: uuid (PK)               │
│ total_amount: numeric       │    │ order_id: uuid (FK)         │
│ shipping_address: jsonb     │    │ product_id: uuid (FK)       │
│ tracking_code: text         │    │ quantity: integer           │
│ created_at: timestamptz     │    │ unit_price: numeric         │
└─────────────────────────────┘    │ discount_percent: integer   │
└─────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│        cart_items           │    │         favorites           │
├─────────────────────────────┤    ├─────────────────────────────┤
│ id: uuid (PK)               │    │ id: uuid (PK)               │
│ user_id: uuid (FK)          │    │ user_id: uuid (FK)          │
│ product_id: uuid (FK)       │    │ product_id: uuid (FK)       │
│ quantity: integer           │    │ created_at: timestamptz     │
│ created_at: timestamptz     │    └─────────────────────────────┘
└─────────────────────────────┘

┌─────────────────────────────┐    ┌─────────────────────────────┐
│          reviews            │    │      product_comments       │
├─────────────────────────────┤    ├─────────────────────────────┤
│ id: uuid (PK)               │    │ id: uuid (PK)               │
│ user_id: uuid (FK)          │    │ user_id: uuid (FK)          │
│ product_id: uuid (FK)       │    │ product_id: uuid (FK)       │
│ rating: integer             │    │ rating: integer             │
│ comment: text               │    │ title: text                 │
│ created_at: timestamptz     │    │ comment: text               │
└─────────────────────────────┘    │ is_verified_purchase: boolean│
│ created_at: timestamptz     │
┌─────────────────────────────┐    └─────────────────────────────┘
│       chat_threads          │
├─────────────────────────────┤    ┌─────────────────────────────┐
│ id: uuid (PK)               │    │       chat_messages         │
│ user_id: uuid (FK)          │    ├─────────────────────────────┤
│ assigned_sales_id: uuid(FK) │    │ id: uuid (PK)               │
│ ai_mode_active: boolean     │    │ thread_id: uuid (FK)        │
│ awaiting_admin_response:    │    │ sender_id: uuid (FK)        │
│   boolean                   │    │ sender_type: text           │
│ pending_ai_job_id: uuid     │    │ message: text               │
│ last_user_message_at: ts    │    │ created_at: timestamptz     │
│ last_admin_message_at: ts   │    └─────────────────────────────┘
│ last_ai_message_at: ts      │
│ last_sales_reply_at: ts     │    ┌─────────────────────────────┐
│ created_at: timestamptz     │    │       chat_summaries        │
└─────────────────────────────┘    ├─────────────────────────────┤
│ id: uuid (PK)               │
┌─────────────────────────────┐    │ thread_id: uuid (FK, unique)│
│       notifications         │    │ user_id: uuid (FK)          │
├─────────────────────────────┤    │ issue_description: text     │
│ id: uuid (PK)               │    │ resolved_by: uuid (FK)      │
│ user_id: uuid (FK)          │    │ status: text                │
│ title: text                 │    │ created_at: timestamptz     │
│ body: text                  │    │ updated_at: timestamptz     │
│ type: text                  │    └─────────────────────────────┘
│ is_read: boolean            │
│ created_at: timestamptz     │    ┌─────────────────────────────┐
└─────────────────────────────┘    │       scheduled_jobs        │
├─────────────────────────────┤
┌─────────────────────────────┐    │ id: uuid (PK)               │
│       user_addresses        │    │ job_type: text              │
├─────────────────────────────┤    │ thread_id: uuid (FK)        │
│ id: uuid (PK)               │    │ scheduled_at: timestamptz   │
│ user_id: uuid (FK)          │    │ status: text                │
│ full_name: text             │    │ attempts: integer           │
│ phone: text                 │    │ max_attempts: integer       │
│ city: text                  │    │ error_message: text         │
│ street: text                │    │ created_at: timestamptz     │
│ building: text              │    │ processed_at: timestamptz   │
│ notes: text                 │    └─────────────────────────────┘
│ is_default: boolean         │
│ created_at: timestamptz     │
└─────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    RELATIONSHIPS                                        │
└─────────────────────────────────────────────────────────────────────────────────────────┘

AppUser ──────────────< OrderSummary (1 user : many orders)
AppUser ──────────────< CartEntry (1 user : many cart items)
AppUser ──────────────< Favorite (1 user : many favorites)
AppUser ──────────────< Review (1 user : many reviews)
AppUser ──────────────< UserAddress (1 user : many addresses)
AppUser ──────────────< ChatThread (1 user : many threads)
AppUser ──────────────< Notification (1 user : many notifications)

Product ──────────────< OrderLineItem (1 product : many order items)
Product ──────────────< CartEntry (1 product : many cart items)
Product ──────────────< Favorite (1 product : many favorites)
Product ──────────────< Review (1 product : many reviews)
Product ──────────────< ProductComment (1 product : many comments)

OrderSummary ─────────< OrderLineItem (1 order : many line items)

ChatThread ───────────< ChatMessage (1 thread : many messages)
ChatThread ───────────< ChatSummary (1 thread : 1 summary)

AppStateProvider ───── uses ───> AuthService
AppStateProvider ───── uses ───> CartService
AppStateProvider ───── uses ───> CatalogService
AppStateProvider ───── uses ───> ChatService
AppStateProvider ───── uses ───> FavoritesService
AppStateProvider ───── uses ───> OrderService
AppStateProvider ───── uses ───> ProfileService
AppStateProvider ───── uses ───> ReviewService
AppStateProvider ───── uses ───> AddressService
AppStateProvider ───── uses ───> NotificationsService
AppStateProvider ───── uses ───> NotificationHandler

useAuthStore ───────── uses ───> users.js API
useUiStore ─────────── manages UI state

Web API modules ────── use ───> Supabase client
Mobile Services ────── use ───> Supabase client
Edge Functions ─────── use ───> Supabase admin client
```
