
import '../../../core/network/api_client.dart';
import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Product> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;

    return ProductPage(
      items: (json['data'] as List<dynamic>)
          .map(
            (item) => Product.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: (pagination['page'] as num).toInt(),
      limit: (pagination['limit'] as num).toInt(),
      total: (pagination['total'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
    );
  }
}

class ProductRepository {
  ProductRepository(this._client);

  final ApiClient _client;

  Future<ProductPage> getProducts({
    int page = 1,
    int limit = 10,
    String search = '',
    String? category,
    String sort = 'created_at',
    String order = 'desc',
  }) async {
    final json = await _client.get(
      '/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.isNotEmpty)
          'category': category,
        'sort': sort,
        'order': order,
      },
    ) as Map<String, dynamic>;

    return ProductPage.fromJson(json);
  }

  Future<List<String>> getCategories() async {
    final json = await _client.get('/categories')
        as Map<String, dynamic>;

    return (json['data'] as List<dynamic>).cast<String>();
  }

  Future<Product> createProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
    String? description,
  }) async {
    final json = await _client.post(
      '/products',
      data: {
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'description': description,
      },
    ) as Map<String, dynamic>;

    return Product.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }

  /// PUT: replace all editable product fields.
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String category,
    required double price,
    required int stock,
    String? description,
  }) async {
    final json = await _client.put(
      '/products/$id',
      data: {
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'description': description,
      },
    ) as Map<String, dynamic>;

    return Product.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }

  /// PATCH: send only the fields that should change.
  Future<Product> patchProduct({
    required int id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? description,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (category != null) data['category'] = category;
    if (price != null) data['price'] = price;
    if (stock != null) data['stock'] = stock;
    if (description != null) data['description'] = description;

    final json = await _client.patch(
      '/products/$id',
      data: data,
    ) as Map<String, dynamic>;

    return Product.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteProduct(int id) {
    return _client.delete('/products/$id');
  }
}
