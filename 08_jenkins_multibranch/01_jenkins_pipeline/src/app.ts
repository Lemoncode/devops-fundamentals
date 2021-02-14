import express from 'express';
import cors from 'cors';
import { envConstants } from './env.constants';
import { api } from './api';

const app = express();
app.use(cors());
app.use('/api', api);

app.listen(envConstants.PORT, () => {
  console.log(`App ready on port: ${envConstants.PORT}`);
});
