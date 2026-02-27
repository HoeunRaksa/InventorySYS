const sql = require("mssql");
require("dotenv").config();

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        encrypt: false,
        trustServerCertificate: true,
        instanceName: process.env.DB_INSTANCE,
    },
    connectionTimeout: 30000,
    requestTimeout: 30000,
};

if (process.env.DB_PORT) {
    config.port = parseInt(process.env.DB_PORT);
}

console.log('Database Config:', {
    server: config.server,
    port: config.port || 'dynamic',
    instanceName: config.options.instanceName,
    database: config.database,
    user: config.user
});

const poolPromise = new sql.ConnectionPool(config)
    .connect()
    .then((pool) => {
        console.log("Connected to SQL Server");
        return pool;
    })
    .catch((err) => {
        console.log("Database Connection Failed!", err);
        throw err;
    });

module.exports = { sql, poolPromise };