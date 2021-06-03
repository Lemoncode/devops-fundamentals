const express = require('express');
const app = express();
const port = 3000;
const host = '0.0.0.0';

app.get('/alerts', (req, res) => {
    res.json([{ id: 1, title: 'Hola' }, { id: 2, title: 'Adios' }]);
});

app.listen(port, host, () => {
    console.log(`app listening on http://${host}:${port}`);
});
