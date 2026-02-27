const { poolPromise, sql } = require('./config/db');

async function checkHex() {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("SELECT name, CAST(name AS VARBINARY(MAX)) as hex_name FROM Categories WHERE id = 1");
        console.log('Name:', result.recordset[0].name);
        console.log('Hex:', result.recordset[0].hex_name.toString('hex'));
    } catch (err) {
        console.error(err);
    } finally {
        process.exit();
    }
}

checkHex();
