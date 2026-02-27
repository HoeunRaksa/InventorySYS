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

        if (search && search.trim() !== '') {
            const searchFilterClause = ` AND (
                p.product_code COLLATE Khmer_100_CI_AS LIKE @search 
                OR p.name COLLATE Khmer_100_CI_AS LIKE @search
                OR p.name_en COLLATE Khmer_100_CI_AS LIKE @search
                OR p.description COLLATE Khmer_100_CI_AS LIKE @search
                OR c.name COLLATE Khmer_100_CI_AS LIKE @search
                OR c.name_en COLLATE Khmer_100_CI_AS LIKE @search
            )`;
            query += searchFilterClause;
            countQuery += searchFilterClause;
        }

        if (category_id) {
            const filter = ' AND p.category_id = @category_id';
            query += filter;
            countQuery += filter;
        }

        // Sorting
        let orderBy = '';
        if (search && search.trim() !== '') {
            // Priority 1: Name starts with search term (either Khmer or English)
            // Priority 2: Product code starts with search term
            // Priority 3: Other matches (though with @search as 'term%' there won't be many "other" matches, 
            // but this helps if we ever re-enable contains)
            orderBy = ` ORDER BY 
                CASE 
                    WHEN p.name COLLATE Khmer_100_CI_AS LIKE @search THEN 1
                    WHEN p.name_en COLLATE Khmer_100_CI_AS LIKE @search THEN 1
                    WHEN p.product_code COLLATE Khmer_100_CI_AS LIKE @search THEN 2
                    ELSE 3 
                END ASC, `;
        } else {
            orderBy = ' ORDER BY ';
        }

        if (sort_by === 'name_asc') orderBy += 'p.name COLLATE Khmer_100_CI_AS ASC';
        else if (sort_by === 'name_desc') orderBy += 'p.name COLLATE Khmer_100_CI_AS DESC';
        else if (sort_by === 'price_asc') orderBy += 'p.price ASC';
        else if (sort_by === 'price_desc') orderBy += 'p.price DESC';
        else orderBy += 'p.id DESC';

        query += orderBy;
        query += ' OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY';

        const mainRequest = pool.request();
        const countRequest = pool.request();

        if (search && search.trim() !== '') {
            const trimmedSearch = search.trim();
            mainRequest.input('search', sql.NVarChar, `${trimmedSearch}%`);
            countRequest.input('search', sql.NVarChar, `${trimmedSearch}%`);
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
