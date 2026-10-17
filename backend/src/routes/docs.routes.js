import { Router } from 'express';
const router = Router();

router.get('/docs', (_req, res) => {
  res.json({
    success: true,
    apiVersion: 'v1',
    routes: [
      { method: 'GET', path: '/api/v1/health', description: 'Health check' },
      { method: 'GET', path: '/api/v1/products?page=1&limit=10&search=phone&category=Electronics&sort=price&order=asc', description: 'List, search, filter, sort, paginate' },
      { method: 'POST', path: '/api/v1/products', description: 'Create product (201)' },
      { method: 'GET', path: '/api/v1/products/:id', description: 'Get one product' },
      { method: 'PUT', path: '/api/v1/products/:id', description: 'Replace editable product fields' },
      { method: 'PATCH', path: '/api/v1/products/:id', description: 'Partially update product' },
      { method: 'DELETE', path: '/api/v1/products/:id', description: 'Delete product (204)' },
      { method: 'GET', path: '/api/v1/categories', description: 'Get available categories' }
    ],
    listQueryParameters: {
      page: '1-based page number; default 1',
      limit: '1-100; default 10',
      search: 'Matches name or description',
      category: 'Exact category filter',
      minPrice: 'Minimum price inclusive',
      maxPrice: 'Maximum price inclusive',
      sort: 'name | price | stock | created_at',
      order: 'asc | desc'
    }
  });
});
export default router;
