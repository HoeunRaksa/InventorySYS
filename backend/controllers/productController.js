const ProductService = require('../services/productService');

exports.getProducts = async (req, res) => {
    try {
        let { page, limit, search, sort_by, category_id } = req.query;
        page = parseInt(page) || 1;
        limit = parseInt(limit) || 20;

        const { products, totalCount } = await ProductService.getProducts({
            page, limit, search, sort_by, category_id
        });

        res.json({
            data: products,
            pagination: {
                total: totalCount,
                page,
                limit,
                total_pages: Math.ceil(totalCount / limit),
            },
        });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

exports.createProduct = async (req, res) => {
    try {
        const { product_code, name, name_en, description, category_id, price } = req.body;
        const image_url = req.file ? req.file.filename : `${product_code}.jpg`;

        const product = await ProductService.createProduct({
            product_code, name, name_en, description, category_id, price, image_url
        });

        res.status(201).json(product);
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

exports.updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const { product_code, name, name_en, description, category_id, price } = req.body;

        // Use existing image if no new file is uploaded
        // This assumes we might pass the old image name in the body or fetch it
        // For now, let's keep it simple: if file is present, use it. 
        // If not, we might need the previous image_url from the body.
        const image_url = req.file ? req.file.filename : req.body.image_url;

        const updatedProduct = await ProductService.updateProduct(id, {
            product_code, name, name_en, description, category_id, price, image_url
        });

        if (!updatedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }

        res.json(updatedProduct);
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};

exports.deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        await ProductService.deleteProduct(id);
        res.status(200).json({ message: 'Product deleted' });
    } catch (err) {
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
};
