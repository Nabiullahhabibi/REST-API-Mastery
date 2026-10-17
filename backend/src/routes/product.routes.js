import { Router } from 'express';
import {
  listProducts, getProduct, createProduct, replaceProduct, patchProduct, deleteProduct, listCategories
} from '../features/products/product.controller.js';

const router = Router();
router.get('/products', listProducts);
router.post('/products', createProduct);
router.get('/products/:id', getProduct);
router.put('/products/:id', replaceProduct);
router.patch('/products/:id', patchProduct);
router.delete('/products/:id', deleteProduct);
router.get('/categories', listCategories);
export default router;
