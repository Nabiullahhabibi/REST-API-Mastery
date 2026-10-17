import { pool } from '../../config/database.js';

const columns = ['name', 'description', 'category', 'price', 'stock'];

export class ProductRepository {
  async list({ page, limit, search, category, minPrice, maxPrice, sort, order }) {
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(name LIKE ? OR description LIKE ?)');
      values.push(`%${search}%`, `%${search}%`);
    }
    if (category) {
      conditions.push('category = ?');
      values.push(category);
    }
    if (minPrice !== undefined) {
      conditions.push('price >= ?');
      values.push(minPrice);
    }
    if (maxPrice !== undefined) {
      conditions.push('price <= ?');
      values.push(maxPrice);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const [countRows] = await pool.execute(
      `SELECT COUNT(*) AS total FROM products ${where}`, values
    );

    // sort/order are validated against allowlists before interpolation.
    const allowedSort = ['name', 'price', 'stock', 'created_at'];
    const safeSort = allowedSort.includes(sort) ? sort : 'created_at';
    const safeOrder = order === 'asc' ? 'ASC' : 'DESC';
    const offset = (page - 1) * limit;

    const [rows] = await pool.execute(
      `SELECT id, name, description, category, price, stock, created_at, updated_at
       FROM products ${where}
       ORDER BY ${safeSort} ${safeOrder}, id DESC
       LIMIT ? OFFSET ?`,
      [...values, limit, offset]
    );

    return {
      data: rows,
      pagination: {
        page, limit, total: Number(countRows[0].total),
        totalPages: Math.ceil(Number(countRows[0].total) / limit)
      }
    };
  }

  async findById(id) {
    const [rows] = await pool.execute(
      'SELECT id, name, description, category, price, stock, created_at, updated_at FROM products WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  }

  async create(data) {
    const [result] = await pool.execute(
      'INSERT INTO products (name, description, category, price, stock) VALUES (?, ?, ?, ?, ?)',
      [data.name, data.description ?? null, data.category, data.price, data.stock]
    );
    return this.findById(result.insertId);
  }

  async update(id, data) {
    const keys = Object.keys(data).filter(key => columns.includes(key));
    if (!keys.length) return this.findById(id);
    const assignments = keys.map(key => `${key} = ?`).join(', ');
    const values = keys.map(key => data[key] ?? null);
    await pool.execute(`UPDATE products SET ${assignments} WHERE id = ?`, [...values, id]);
    return this.findById(id);
  }

  async delete(id) {
    const [result] = await pool.execute('DELETE FROM products WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  async findByName(name) {
    const [rows] = await pool.execute('SELECT id FROM products WHERE LOWER(name) = LOWER(?) LIMIT 1', [name]);
    return rows[0] || null;
  }

  async categories() {
    const [rows] = await pool.query('SELECT DISTINCT category FROM products ORDER BY category ASC');
    return rows.map(row => row.category);
  }
}
