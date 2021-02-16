import express from 'express';
import cors from 'cors';
import { envConstants } from './env.constants';
import { api } from './api';
const promBundle = require('express-prom-bundle');
const metricsMiddleware = promBundle({ includeMethod: true });

const app = express();
app.use(cors());
app.use(metricsMiddleware);
app.use('/api', api);

app.listen(envConstants.PORT, () => {
  console.log(`App ready on port: ${envConstants.PORT}`);
});
