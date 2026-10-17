import { AppError } from '../../utils/app-error.js';
import { ProductRepository } from './product.repository.js';

export class ProductService {
  constructor(repository = new ProductRepository()) {
    this.repository = repository;
  }

  list(query) {
    return this.repository.list(query);
  }

  async get(id) {
    const product = await this.repository.findById(id);
    if (!product) throw new AppError(404, 'Product not found', 'PRODUCT_NOT_FOUND');
    return product;
  }

  async create(data) {
    if (await this.repository.findByName(data.name)) {
      throw new AppError(409, 'A product with this name already exists', 'PRODUCT_NAME_CONFLICT');
    }
    return this.repository.create(data);
  }

  async replace(id, data) {
    await this.get(id);
    const conflict = await this.repository.findByName(data.name);
    if (conflict && Number(conflict.id) !== Number(id)) {
      throw new AppError(409, 'A product with this name already exists', 'PRODUCT_NAME_CONFLICT');
    }
    return this.repository.update(id, data);
  }

  async patch(id, data) {
    await this.get(id);
    if (data.name) {
      const conflict = await this.repository.findByName(data.name);
      if (conflict && Number(conflict.id) !== Number(id)) {
        throw new AppError(409, 'A product with this name already exists', 'PRODUCT_NAME_CONFLICT');
      }
    }
    return this.repository.update(id, data);
  }

  async remove(id) {
    await this.get(id);
    await this.repository.delete(id);
  }

  categories() {
    return this.repository.categories();
  }
}
