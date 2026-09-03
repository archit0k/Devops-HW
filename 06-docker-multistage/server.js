const express = require('express');
const app = express();

app.get('/', (_req, res) => {
  res.send('<h1>Hello World from Docker multi-stage build</h1>');
});

app.listen(8080, () => console.log('Server is listening on port 8080'));
