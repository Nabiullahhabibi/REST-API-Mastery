import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { env } from './config/env.js';
import { checkDatabase } from './config/database.js';
import { requestContext } from './middleware/request-context.js';
import { notFound } from './middleware/not-found.js';
import { errorHandler } from './middleware/error-handler.js';
import productRoutes from './routes/product.routes.js';
import docsRoutes from './routes/docs.routes.js';

export const app = express();
app.use(helmet());
app.use(cors({ origin: env.frontendOrigin === '*' ? true : env.frontendOrigin.split(',').map(s => s.trim()) }));
app.use(express.json({ limit: '1mb' }));
app.use(requestContext);

app.get(`${env.apiPrefix}/health`, async (_req, res, next) => {
  try {
    await checkDatabase();
    res.status(200).json({ success: true, status: 'ok', database: 'connected' });
  } catch (error) {
    // A dependency outage is a service-availability problem.
    error.statusCode = 503;
    error.code = 'DATABASE_UNAVAILABLE';
    next(error);
  }
});

app.use(env.apiPrefix, productRoutes);
app.use(env.apiPrefix, docsRoutes);
app.use(notFound);
app.use(errorHandler);
