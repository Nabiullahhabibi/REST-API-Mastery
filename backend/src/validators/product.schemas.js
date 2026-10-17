import { z } from 'zod';

const productFields = {
  name: z.string().trim().min(2).max(150),
  description: z.string().trim().max(2000).nullable().optional(),
  category: z.string().trim().min(2).max(80),
  price: z.coerce.number().finite().min(0).max(99999999),
  stock: z.coerce.number().int().min(0).max(1000000)
};

export const createProductSchema = z.object(productFields).strict();

export const replaceProductSchema = z.object({
  name: productFields.name,
  description: productFields.description,
  category: productFields.category,
  price: productFields.price,
  stock: productFields.stock
}).strict();

export const patchProductSchema = z.object({
  name: productFields.name.optional(),
  description: productFields.description,
  category: productFields.category.optional(),
  price: productFields.price.optional(),
  stock: productFields.stock.optional()
}).strict().refine(data => Object.keys(data).length > 0, {
  message: 'Provide at least one field to update'
});

export const listProductsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().trim().max(100).optional(),
  category: z.string().trim().max(80).optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
  sort: z.enum(['name', 'price', 'stock', 'created_at']).default('created_at'),
  order: z.enum(['asc', 'desc']).default('desc')
}).refine(data => data.minPrice === undefined || data.maxPrice === undefined || data.minPrice <= data.maxPrice, {
  message: 'minPrice cannot be greater than maxPrice'
});
