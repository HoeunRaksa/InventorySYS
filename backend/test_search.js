const http = require('http');

const searchTerm = 'ទូរស័ព្ទ';
const encodedSearch = encodeURIComponent(searchTerm);
const url = `http://localhost:5000/api/products?search=${encodedSearch}`;

http.get(url, (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
        console.log('Status code:', res.statusCode);
        console.log('Response:', data);
    });
}).on('error', (err) => {
    console.error('Error:', err.message);
});
