require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const authRoutes = require('./routes/authRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const productRoutes = require('./routes/productRoutes');
const listEndpoints = require('express-list-endpoints');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/products', productRoutes);
//Debug routes list
const endpoints = [
  ...listEndpoints(authRoutes).map(e => ({
    ...e,
    path: '/api/auth' + e.path,
  })),
  ...listEndpoints(categoryRoutes).map(e => ({
    ...e,
    path: '/api/categories' + e.path,
  })),
  ...listEndpoints(productRoutes).map(e => ({
    ...e,
    path: '/api/products' + e.path,
  })),
];

console.log('📌 Available Routes:');
endpoints.forEach(e => console.log(`${e.methods.join(', ')}  ${e.path}`));
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
