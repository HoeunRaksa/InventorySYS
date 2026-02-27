const { poolPromise, sql } = require('../config/db');

exports.getCategories = async (req, res) => {
    try {
        const { search } = req.query;
        const pool = await poolPromise;

        let query = `SELECT * FROM Categories`;
        let request = pool.request();

        if (search && search.trim() !== '') {
            const trimmedSearch = search.trim();
            query += " WHERE (name COLLATE Khmer_100_CI_AS LIKE @search OR name_en COLLATE Khmer_100_CI_AS LIKE @search OR description COLLATE Khmer_100_CI_AS LIKE @search)";
            request.input('search', sql.NVarChar, `${trimmedSearch}%`);
            
            // Priority Sort: Starts with name/name_en first
            query += ` ORDER BY 
                CASE 
                    WHEN name COLLATE Khmer_100_CI_AS LIKE @search THEN 1 
                    WHEN name_en COLLATE Khmer_100_CI_AS LIKE @search THEN 1
                    ELSE 2 
                END ASC, name COLLATE Khmer_100_CI_AS`;
        } else {
            query += ' ORDER BY name COLLATE Khmer_100_CI_AS';
        }

        const result = await request.query(query);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};


exports.createCategory = async (req, res) => {
    try {
        const { name, name_en, description } = req.body;
        const pool = await poolPromise;
        const result = await pool.request()
            .input('name', sql.NVarChar, name)
            .input('name_en', sql.NVarChar, name_en)
            .input('description', sql.NVarChar, description)
            .query('INSERT INTO Categories (name, name_en, description) OUTPUT INSERTED.* VALUES (@name, @name_en, @description)');

        res.status(201).json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

exports.updateCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, name_en, description } = req.body;
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('name', sql.NVarChar, name)
            .input('name_en', sql.NVarChar, name_en)
            .input('description', sql.NVarChar, description)
            .query('UPDATE Categories SET name = @name, name_en = @name_en, description = @description OUTPUT INSERTED.* WHERE id = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

 exports.deleteCategory = async (req, res) => {
    try {
        const { id } = req.params;
        const pool = await poolPromise;
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM Categories WHERE id = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }
        res.json({ message: 'Category deleted' });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};
