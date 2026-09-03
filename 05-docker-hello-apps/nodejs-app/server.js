const express = require('express');
const app = express();
app.get('/', (_req, res) => res.send('<h1>Hello World from Node.js!</h1>'));
app.listen(3000, () => console.log('Node.js app listening on port 3000'));
