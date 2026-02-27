const { poolPromise, sql } = require('./config/db');

async function checkSchema() {
    try {
        const pool = await poolPromise;
        const productsColumns = await pool.request().query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Products'");
        console.log('Products Columns:', productsColumns.recordset.map(c => c.COLUMN_NAME));

        const categoriesColumns = await pool.request().query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Categories'");
        console.log('Categories Columns:', categoriesColumns.recordset.map(c => c.COLUMN_NAME));
    } catch (err) {
        console.error('Error checking schema:', err);
    } finally {
        process.exit();
    }
}

checkSchema();
