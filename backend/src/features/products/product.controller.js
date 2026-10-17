import { AppError } from '../../utils/app-error.js';
import {
  createProductSchema, replaceProductSchema, patchProductSchema, listProductsSchema
} from '../../validators/product.schemas.js';
import { ProductService } from './product.service.js';

const service = new ProductService();

function parseId(value) {
  if (!/^[1-9]\d*$/.test(value)) throw new AppError(400, 'id must be a positive integer', 'INVALID_ID');
  const id = Number(value);
  if (!Number.isSafeInteger(id)) throw new AppError(400, 'id is outside the supported range', 'INVALID_ID');
  return id;
}

export async function listProducts(req, res, next) {
  try {
    const query = listProductsSchema.parse(req.query);
    const result = await service.list(query);
    res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function getProduct(req, res, next) {
  try {
    res.status(200).json({ success: true, data: await service.get(parseId(req.params.id)) });
  } catch (error) { next(error); }
}

export async function createProduct(req, res, next) {
  try {
    const body = createProductSchema.parse(req.body);
    const data = await service.create(body);
    res.location(`/api/v1/products/${data.id}`).status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

export async function replaceProduct(req, res, next) {
  try {
    const id = parseId(req.params.id);
    const body = replaceProductSchema.parse(req.body);
    res.status(200).json({ success: true, data: await service.replace(id, body) });
  } catch (error) { next(error); }
}

export async function patchProduct(req, res, next) {
  try {
    const id = parseId(req.params.id);
    const body = patchProductSchema.parse(req.body);
    res.status(200).json({ success: true, data: await service.patch(id, body) });
  } catch (error) { next(error); }
}

export async function deleteProduct(req, res, next) {
  try {
    await service.remove(parseId(req.params.id));
    res.status(204).end();
  } catch (error) { next(error); }
}

export async function listCategories(_req, res, next) {
  try { res.status(200).json({ success: true, data: await service.categories() }); }
  catch (error) { next(error); }
}
