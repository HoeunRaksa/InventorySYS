const { poolPromise, sql } = require('../config/db');

class ProductService {
    /**
     * Get products with pagination, search, sorting and category filtering.
     */
    static async getProducts({ page, limit, search, sort_by, category_id }) {
        const offset = (page - 1) * limit;
        const pool = await poolPromise;

        let query = `
            SELECT p.*, c.name as category_name, c.name_en as category_name_en
            FROM Products p
            LEFT JOIN Categories c ON p.category_id = c.id
            WHERE 1=1
        `;

        let countQuery = `
            SELECT COUNT(*) as total 
            FROM Products p
            LEFT JOIN Categories c ON p.category_id = c.id
            WHERE 1=1
        `;

        const searchFilter = ' AND (p.name LIKE @search OR p.name_en LIKE @search OR p.description LIKE @search OR c.name LIKE @search OR c.name_en LIKE @search)';
        const categoryFilter = ' AND p.category_id = @category_id';

        if (search && search.trim() !== '') {
            query += searchFilter;
            countQuery += searchFilter;
        }
        if (category_id) {
            query += categoryFilter;
            countQuery += categoryFilter;
        }

        // Sorting
        let orderBy = ' ORDER BY p.id DESC';
        if (sort_by === 'name_asc') orderBy = ' ORDER BY p.name ASC';
        if (sort_by === 'name_desc') orderBy = ' ORDER BY p.name DESC';
        if (sort_by === 'price_asc') orderBy = ' ORDER BY p.price ASC';
        if (sort_by === 'price_desc') orderBy = ' ORDER BY p.price DESC';

        query += orderBy;
        query += ' OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY';

        const mainRequest = pool.request();
        const countRequest = pool.request();

        if (search && search.trim() !== '') {
            mainRequest.input('search', sql.NVarChar(sql.MAX), `%${search}%`);
            countRequest.input('search', sql.NVarChar(sql.MAX), `%${search}%`);
        }
        if (category_id) {
            mainRequest.input('category_id', sql.Int, parseInt(category_id));
            countRequest.input('category_id', sql.Int, parseInt(category_id));
        }
        mainRequest.input('offset', sql.Int, offset);
        mainRequest.input('limit', sql.Int, limit);

        const [results, totalResult] = await Promise.all([
            mainRequest.query(query),
            countRequest.query(countQuery),
        ]);

        return {
            products: results.recordset,
            totalCount: totalResult.recordset[0].total
        };
    }

    static async createProduct({ product_code, name, name_en, description, category_id, price, image_url }) {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('product_code', sql.NVarChar, product_code)
            .input('name', sql.NVarChar, name)
            .input('name_en', sql.NVarChar, name_en)
            .input('description', sql.NVarChar, description || '')
            .input('category_id', sql.Int, parseInt(category_id))
            .input('price', sql.Decimal(10, 2), parseFloat(price))
            .input('image_url', sql.NVarChar, image_url)
            .query('INSERT INTO Products (product_code, name, name_en, description, category_id, price, image_url) OUTPUT INSERTED.id VALUES (@product_code, @name, @name_en, @description, @category_id, @price, @image_url)');

        const newId = result.recordset[0].id;

        // Fetch the full product with joined category data
        const fullResult = await pool.request()
            .input('id', sql.Int, newId)
            .query(`
                SELECT p.*, c.name as category_name, c.name_en as category_name_en
                FROM Products p
                LEFT JOIN Categories c ON p.category_id = c.id
                WHERE p.id = @id
            `);

        return fullResult.recordset[0];
    }

    static async updateProduct(id, { product_code, name, name_en, description, category_id, price, image_url }) {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('product_code', sql.NVarChar, product_code)
            .input('name', sql.NVarChar, name)
            .input('name_en', sql.NVarChar, name_en)
            .input('description', sql.NVarChar, description || '')
            .input('category_id', sql.Int, parseInt(category_id))
            .input('price', sql.Decimal(10, 2), parseFloat(price))
            .input('image_url', sql.NVarChar, image_url)
            .query(`
                UPDATE Products 
                SET product_code = @product_code, 
                    name = @name, 
                    name_en = @name_en, 
                    description = @description, 
                    category_id = @category_id, 
                    price = @price, 
                    image_url = @image_url
                OUTPUT INSERTED.id
                WHERE id = @id
            `);

        if (result.recordset.length === 0) return null;

        const updatedId = result.recordset[0].id;

        const fullResult = await pool.request()
            .input('id', sql.Int, updatedId)
            .query(`
                SELECT p.*, c.name as category_name, c.name_en as category_name_en
                FROM Products p
                LEFT JOIN Categories c ON p.category_id = c.id
                WHERE p.id = @id
            `);

        return fullResult.recordset[0];
    }

    static async deleteProduct(id) {
        const pool = await poolPromise;
        return await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM Products WHERE id = @id');
    }
}

module.exports = ProductService;
