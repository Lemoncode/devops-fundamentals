if (process.env.NODE_ENV !== 'production') {
    const { config } = require('dotenv');
    config();
}

require('./app');
