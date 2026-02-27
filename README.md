# Inventory Management System

[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![MSSQL](https://img.shields.io/badge/Database-MSSQL-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/en-us/sql-server)

An inventory management solution featuring a Node.js backend and a responsive Flutter frontend with full Khmer language support.

---

## Features

### Secure Authentication
- JWT-based security for encrypted communication.
- Signup validation, Login, and OTP-based Password Reset via Email.

### Smart Content Management
- Category system for efficient stock grouping.
- Product tracking with Product IDs and Image support.
- Specialized SQL collation for Khmer sorting and searching.

### Powerful Search & Filtering
- Real-time debounced search for Categories and Products (EN/KH).
- Pagination (20 items/page) for optimized performance.
- Dynamic sorting by name, price, or date.

### Premium UX/UI
- Responsive layout for Mobile, Tablet, and Desktop.
- Instant switching between English and Khmer.
- Reactive state management powered by the Provider pattern.

---

## Technical Architecture

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | Flutter | Cross-platform UI (Android, iOS, Desktop). |
| **Backend** | Express.js | RESTful API built on Node.js. |
| **Database** | SQL Server | Relational storage with Unicode/Khmer support. |
| **State** | Provider | Reactive state management for the application. |
| **Auth** | JWT / Bcrypt | Industry-standard security and encryption. |

---

## Setup Instructions

### 1. Database Setup
1. Open your SQL Server instance.
2. Execute the script in `/sql/schema.sql` to create the `InventoryDB` database and tables.
3. The schema uses `Khmer_100_CI_AS` collation for native Khmer support.

### 2. Backend Setup
1. Navigate to the `backend` directory.
2. Run `npm install`.
3. Create a `.env` file based on `.env.example` and configure your credentials:
   ```env
   PORT=5000
   DB_USER=sa
   DB_PASSWORD=your_password
   DB_SERVER=localhost
   DB_NAME=InventoryDB
   JWT_SECRET=your_secret
   EMAIL_USER=your_email
   EMAIL_PASS=your_pass
   ```
4. Run `npm run dev`.

### 3. Frontend Setup
1. Navigate to the `frontend` directory.
2. Run `flutter pub get`.
3. Configure your backend IP address in `lib/services/api_service.dart`.
4. Run `flutter run`.

---

## API Reference

### Authentication
- `POST /api/auth/signup`: Create a new account.
- `POST /api/auth/login`: Authenticate and receive a JWT.
- `POST /api/auth/forgot-password`: Send an OTP for password reset.
- `POST /api/auth/reset-password`: Update password using the received OTP.

### Categories (Authenticated)
- `GET /api/categories`: Retrieve categories (supports `search` query).
- `POST /api/categories`: Create a new category.
- `PUT /api/categories/:id`: Update an existing category.
- `DELETE /api/categories/:id`: Remove a category.

### Products (Authenticated)
- `GET /api/products`: List products with pagination, filtering, and sorting.
- `POST /api/products`: Create a product with image upload (Multer).
- `PUT /api/products/:id`: Update product details and/or image.
- `DELETE /api/products/:id`: Delete a product.

---

## Development Details

- **Localization**: Handled through `LocaleProvider` and `AppTranslations`. Supports dynamic switching between `en` and `km`.
- **File Storage**: Product images are stored locally in `backend/uploads/images/` and served as static files.
- **Search**: Uses SQL `LIKE` queries with `NVARCHAR` support for Unicode characters.
- **Performance**: Debouncing implemented on the frontend to minimize API hits during typing.





