# 🗄️ Databases

> Database configuration and schemas for the CS02 E-Commerce Platform

## 📋 Overview

The CS02 platform uses a polyglot persistence approach with multiple database technologies optimized for different use cases:

| Database | Purpose | Services |
|----------|---------|----------|
| **PostgreSQL** | Transactional data | User Identity, Orders, Support (warranty), Analytics |
| **MongoDB** | Document storage | Products, Content, Notifications, Cart/Wishlist, Support (tickets) |
| **Redis** | Session/Cache | Shopping Cart |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Microservices                             │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   PostgreSQL    │  │     MongoDB     │  │      Redis      │
│   (Port 5432)   │  │   (Port 27017)  │  │   (Port 6379)   │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ • users_db      │  │ • CSO2_product  │  │ • Cart sessions │
│ • orders_db     │  │   _catalogue    │  │ • Session data  │
│ • analytics_db  │  │ • CSO2_content  │  │                 │
│ • support_db    │  │ • CSO2_notif    │  │                 │
│                 │  │ • CSO2_support  │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 📊 PostgreSQL Databases

### 1. Users Database (`users_db` / `CSO2_user_identity_service`)

**Service**: User Identity Service (Port 8081)

#### Tables

##### users
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| email | VARCHAR(255) | User email (unique) |
| password_hash | VARCHAR(255) | BCrypt hashed password |
| name | VARCHAR(255) | Display name |
| phone | VARCHAR(20) | Phone number |
| role | VARCHAR(50) | CUSTOMER, ADMIN |
| loyalty_points | INTEGER | Reward points |
| tier | VARCHAR(20) | bronze, silver, gold, platinum |
| is_active | BOOLEAN | Account status |
| email_verified | BOOLEAN | Email verification status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

##### addresses
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID (FK) | Reference to users |
| name | VARCHAR(100) | Address label |
| street | VARCHAR(255) | Street address |
| city | VARCHAR(100) | City |
| state | VARCHAR(100) | State/Province |
| zip_code | VARCHAR(20) | Postal code |
| country | VARCHAR(100) | Country |
| phone | VARCHAR(20) | Contact phone |
| is_default | BOOLEAN | Default address flag |

##### payment_methods
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID (FK) | Reference to users |
| type | VARCHAR(50) | CREDIT_CARD, DEBIT_CARD, PAYPAL |
| brand | VARCHAR(50) | visa, mastercard, amex |
| last4 | VARCHAR(4) | Last 4 digits |
| expiry_month | INTEGER | Expiration month |
| expiry_year | INTEGER | Expiration year |
| is_default | BOOLEAN | Default payment flag |

##### refresh_tokens
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID (FK) | Reference to users |
| token | VARCHAR(500) | Refresh token (unique) |
| expires_at | TIMESTAMP | Token expiration |

##### recently_viewed
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID (FK) | Reference to users |
| product_id | VARCHAR(100) | Product ID |
| viewed_at | TIMESTAMP | View timestamp |

---

### 2. Orders Database (`CSO2_order_service`)

**Service**: Order Service (Port 8083)

#### Tables

##### orders
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID | User reference |
| order_number | VARCHAR(50) | Human-readable order number |
| subtotal | DECIMAL(10,2) | Pre-tax amount |
| tax | DECIMAL(10,2) | Tax amount |
| shipping_cost | DECIMAL(10,2) | Shipping fee |
| discount | DECIMAL(10,2) | Discount applied |
| total | DECIMAL(10,2) | Final amount |
| status | VARCHAR(20) | PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED |
| payment_method | VARCHAR(20) | Payment type |
| payment_status | VARCHAR(20) | PENDING, PAID, REFUNDED |
| tracking_number | VARCHAR(100) | Shipping tracking |
| created_at | TIMESTAMP | Order timestamp |
| updated_at | TIMESTAMP | Last update |

##### order_items
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| order_id | UUID (FK) | Reference to orders |
| product_id | VARCHAR(100) | Product reference |
| product_name | VARCHAR(255) | Product name snapshot |
| quantity | INTEGER | Quantity ordered |
| price | DECIMAL(10,2) | Unit price |
| image_url | VARCHAR(500) | Product image |

##### shipping_addresses
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| order_id | UUID (FK) | Reference to orders |
| name | VARCHAR(100) | Recipient name |
| street | VARCHAR(255) | Street address |
| city | VARCHAR(100) | City |
| state | VARCHAR(100) | State |
| zip_code | VARCHAR(20) | Postal code |
| country | VARCHAR(100) | Country |
| phone | VARCHAR(20) | Contact phone |

---

### 3. Analytics Database (`CSO2_reporting_and_analysis_service`)

**Service**: Reporting and Analysis Service (Port 8088)

#### Tables

##### daily_sales
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| date | DATE | Sales date (unique) |
| total_orders | INTEGER | Number of orders |
| total_revenue | DECIMAL(12,2) | Total revenue |
| total_items | INTEGER | Items sold |
| average_order_value | DECIMAL(10,2) | AOV |
| new_customers | INTEGER | New customer count |
| returning_customers | INTEGER | Returning count |

##### product_performance
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| product_id | VARCHAR(100) | Product reference |
| product_name | VARCHAR(255) | Product name |
| category | VARCHAR(100) | Category |
| total_sold | INTEGER | Units sold |
| total_revenue | DECIMAL(12,2) | Revenue |
| average_rating | DECIMAL(3,2) | Avg rating |
| period | VARCHAR(10) | Time period (YYYY-MM) |

---

### 4. Support Database (`CSO2_support_service`)

**Service**: Support Service (Port 8085)

#### Tables

##### warranties
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Unique identifier |
| user_id | UUID | User reference |
| product_id | VARCHAR(100) | Product reference |
| product_name | VARCHAR(255) | Product name |
| serial_number | VARCHAR(100) | Serial number (unique) |
| order_id | UUID | Order reference |
| order_number | VARCHAR(50) | Order number |
| purchase_date | DATE | Purchase date |
| expiration_date | DATE | Warranty expiration |
| warranty_type | VARCHAR(20) | STANDARD, EXTENDED, PREMIUM |
| status | VARCHAR(20) | ACTIVE, EXPIRED, CLAIMED, VOID |
| created_at | TIMESTAMP | Registration timestamp |

---

## 📄 MongoDB Collections

### 1. Product Catalogue (`CSO2_product_catalogue_service`)

**Service**: Product Catalogue Service (Port 8082)

#### products
```javascript
{
  "_id": "ObjectId",
  "id": "string",
  "name": "string",
  "sku": "string",
  "price": Number,
  "salePrice": Number,
  "category": "string",
  "subcategory": "string",
  "brand": "string",
  "description": "string",
  "specs": {
    "memory": "string",
    "coreClock": "string",
    // ... dynamic specs
  },
  "compatibility": {
    "socket": "string",
    "formFactor": "string",
    // ... compatibility info
  },
  "imageUrl": "string",
  "images": ["string"],
  "stockLevel": Number,
  "rating": Number,
  "reviewCount": Number,
  "tags": ["string"],
  "isActive": Boolean,
  "isFeatured": Boolean,
  "createdAt": Date,
  "updatedAt": Date
}
```

#### categories
```javascript
{
  "_id": "ObjectId",
  "name": "string",
  "slug": "string",
  "description": "string",
  "imageUrl": "string",
  "parentId": "ObjectId",
  "order": Number,
  "isActive": Boolean
}
```

#### reviews
```javascript
{
  "_id": "ObjectId",
  "productId": "string",
  "userId": "string",
  "userName": "string",
  "rating": Number,
  "title": "string",
  "comment": "string",
  "isVerifiedPurchase": Boolean,
  "isApproved": Boolean,
  "helpfulCount": Number,
  "createdAt": Date
}
```

---

### 2. Content (`CSO2_content_service`)

**Service**: Content Service (Port 8086)

#### blog_posts
```javascript
{
  "_id": "ObjectId",
  "title": "string",
  "slug": "string",
  "content": "string",
  "excerpt": "string",
  "author": "string",
  "imageUrl": "string",
  "category": "string",
  "tags": ["string"],
  "featured": Boolean,
  "published": Boolean,
  "createdAt": Date,
  "updatedAt": Date
}
```

#### faqs
```javascript
{
  "_id": "ObjectId",
  "question": "string",
  "answer": "string",
  "category": "string",
  "order": Number,
  "createdAt": Date
}
```

#### testimonials
```javascript
{
  "_id": "ObjectId",
  "userId": "string",
  "userName": "string",
  "rating": Number,
  "content": "string",
  "approved": Boolean,
  "createdAt": Date
}
```

---

### 3. Notifications (`CSO2_notifications_service`)

**Service**: Notifications Service (Port 8087)

#### notifications
```javascript
{
  "_id": "ObjectId",
  "userId": "string",
  "type": "ORDER_CONFIRMATION | SHIPPING_UPDATE | STOCK_ALERT | PROMOTIONAL",
  "title": "string",
  "message": "string",
  "data": {},
  "read": Boolean,
  "createdAt": Date
}
```

---

### 4. Cart & Wishlist (`CSO2_shoppingcart_wishlist_service`)

**Service**: Shopping Cart & Wishlist Service (Port 8084)

#### wishlists
```javascript
{
  "_id": "ObjectId",
  "userId": "string",
  "products": [{
    "productId": "string",
    "addedAt": Date
  }],
  "createdAt": Date,
  "updatedAt": Date
}
```

#### saved_builds
```javascript
{
  "_id": "ObjectId",
  "userId": "string",
  "name": "string",
  "description": "string",
  "components": {
    "cpu": { "productId": "string", "name": "string", "price": Number },
    "gpu": { "productId": "string", "name": "string", "price": Number },
    // ... other components
  },
  "totalPrice": Number,
  "isPublic": Boolean,
  "likes": Number,
  "createdAt": Date,
  "updatedAt": Date
}
```

---

### 5. Support Tickets (`CSO2_support_service`)

**Service**: Support Service (Port 8085)

#### tickets
```javascript
{
  "_id": "ObjectId",
  "userId": "string",
  "orderNumber": "string",
  "subject": "string",
  "category": "PRODUCT_ISSUE | ORDER_ISSUE | SHIPPING | RETURNS | GENERAL",
  "priority": "LOW | MEDIUM | HIGH | URGENT",
  "status": "OPEN | IN_PROGRESS | WAITING_CUSTOMER | RESOLVED | CLOSED",
  "description": "string",
  "replies": [{
    "userId": "string",
    "userName": "string",
    "isStaff": Boolean,
    "message": "string",
    "createdAt": Date
  }],
  "assignedTo": "string",
  "createdAt": Date,
  "updatedAt": Date
}
```

#### stores
```javascript
{
  "_id": "ObjectId",
  "name": "string",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "country": "string"
  },
  "phone": "string",
  "email": "string",
  "hours": {},
  "coordinates": {
    "latitude": Number,
    "longitude": Number
  },
  "services": ["string"],
  "isActive": Boolean
}
```

---

## 🔴 Redis Data Structures

### Shopping Cart

**Key Pattern**: `cart:{userId}`
**Type**: Hash

```
HSET cart:user123 items '[{"productId":"...","quantity":2}]'
HSET cart:user123 subtotal "599.98"
HSET cart:user123 updatedAt "2024-01-15T10:30:00Z"
EXPIRE cart:user123 604800  # 7 days
```

---

## 🔧 Connection Details

### Docker Compose Configuration

| Service | Container Name | Internal Port | External Port | Credentials |
|---------|---------------|---------------|---------------|-------------|
| postgres-users | cs02-users-db | 5432 | 5432 | postgres/postgres |
| postgres-products | cs02-products-db | 5432 | 5433 | postgres/postgres |
| mongodb | cs02-mongodb | 27017 | 27017 | (no auth) |
| redis | cs02-redis | 6379 | 6379 | (no auth) |

### Connection Strings

```bash
# PostgreSQL Users DB
postgresql://postgres:postgres@localhost:5432/users_db

# PostgreSQL Products DB
postgresql://postgres:postgres@localhost:5433/products_db

# MongoDB
mongodb://localhost:27017/CSO2_product_catalogue_service

# Redis
redis://localhost:6379
```

---

## 📜 Initialization Scripts

### Location

| File | Path | Purpose |
|------|------|---------|
| `init-databases.sql` | `backend/` | Creates all PostgreSQL databases |
| `users_db_schema.sql` | `backend/` | Users database full schema |
| `products_db_schema.sql` | `backend/` | Products database full schema |
| `db-init.sql` | `Databases/` | Alternative initialization |

### Docker Volume Mounts

```yaml
postgres-users:
  volumes:
    - ./backend/init-databases.sql:/docker-entrypoint-initdb.d/init.sql
    - postgres-users-data:/var/lib/postgresql/data

postgres-products:
  volumes:
    - ./backend/products_db_schema.sql:/docker-entrypoint-initdb.d/init.sql
    - postgres-products-data:/var/lib/postgresql/data
```

---

## ✅ Completion Status

| Database | Status | Notes |
|----------|--------|-------|
| PostgreSQL Setup | ✅ Complete | Docker configured |
| MongoDB Setup | ✅ Complete | Docker configured |
| Redis Setup | ✅ Complete | Docker configured |
| Users Schema | ✅ Complete | Full schema defined |
| Products Schema | ✅ Complete | Full schema defined |
| Orders Schema | ✅ Complete | JPA auto-generated |
| Analytics Schema | ✅ Complete | JPA auto-generated |
| Support Schema | ✅ Complete | Hybrid PostgreSQL + MongoDB |
| Init Scripts | ✅ Complete | Volume mounted |
| Demo Data | ⚠️ Partial | Some demo data seeded |

### **Overall Completion: 90%** ✅

---

## ❌ Future Enhancements

| Feature | Priority | Notes |
|---------|----------|-------|
| Database backups | Medium | Automated backup scripts |
| Read replicas | Low | For scaling reads |
| Connection pooling | Medium | PgBouncer for PostgreSQL |
| Data migrations | Medium | Flyway or Liquibase |
| Monitoring | Medium | pg_stat_statements, mongostat |

---

## 🧪 Testing Connections

```bash
# PostgreSQL
psql -h localhost -p 5432 -U postgres -d users_db

# MongoDB
mongosh mongodb://localhost:27017/CSO2_product_catalogue_service

# Redis
redis-cli -h localhost -p 6379
```

---

## 📝 Notes

- MongoDB collections are auto-created by Spring Data MongoDB
- PostgreSQL tables are auto-created by JPA (ddl-auto: update)
- Redis data expires after 7 days for carts
- All databases use UTC timestamps
- UUIDs used for primary keys (PostgreSQL)