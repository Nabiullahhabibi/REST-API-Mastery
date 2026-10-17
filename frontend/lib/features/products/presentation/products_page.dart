import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../data/product.dart';
import '../data/product_repository.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.repository});

  final ProductRepository repository;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Product> _products = [];
  List<String> _categories = [];

  String? _category;
  String _sort = 'created_at';
  String _order = 'desc';

  int _page = 1;
  int _totalPages = 1;
  int _total = 0;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.repository.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
      });
    } catch (_) {
      // The product list can still work without category metadata.
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.repository.getProducts(
        page: _page,
        search: _searchController.text.trim(),
        category: _category,
        sort: _sort,
        order: _order,
      );

      if (!mounted) return;

      setState(() {
        _products = result.items;
        _total = result.total;
        _totalPages = result.totalPages < 1 ? 1 : result.totalPages;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '${e.message} (HTTP ${e.statusCode})';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not connect. Check the API URL and backend.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _page = 1;
      });

      _loadProducts();
    });
  }

  Future<void> _showCreateDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProductFormDialog(repository: widget.repository),
    );

    if (!mounted || saved != true) return;

    setState(() {
      _page = 1;
    });

    await _loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product created successfully')),
    );
  }

  Future<void> _showEditDialog(Product product) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _ProductFormDialog(repository: widget.repository, product: product),
    );

    if (!mounted || saved != true) return;

    await _loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully')),
    );
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await widget.repository.deleteProduct(product.id);

      if (!mounted) return;

      if (_products.length == 1 && _page > 1) {
        setState(() {
          _page--;
        });
      }

      await _loadProducts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not delete product')));
    }
  }

  void _changePage(int page) {
    if (_loading || page < 1 || page > _totalPages) return;

    setState(() {
      _page = page;
    });

    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Mastery'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton.extended(
          onPressed: _showCreateDialog,
          icon: const Icon(Icons.add),
          label: const Text('Create'),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _debounce?.cancel();
                    _searchController.clear();

                    setState(() {
                      _page = 1;
                    });

                    _loadProducts();
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'All categories',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<String?>(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                        _page = 1;
                      });

                      _loadProducts();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _sort,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'created_at',
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'stock', child: Text('Stock')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _sort = value;
                        _page = 1;
                      });

                      _loadProducts();
                    },
                  ),
                ),
                IconButton(
                  tooltip: _order == 'asc' ? 'Ascending' : 'Descending',
                  onPressed: () {
                    setState(() {
                      _order = _order == 'asc' ? 'desc' : 'asc';
                      _page = 1;
                    });

                    _loadProducts();
                  },
                  icon: Icon(
                    _order == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('$_total products • page $_page of $_totalPages'),
            ),
          ),

          if (_loading) const LinearProgressIndicator(),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),

          Expanded(
            child: _loading && _products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.separated(
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = _products[index];

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.category} • '
                          'Stock: ${product.stock}\n'
                          '\$${product.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,

                        // Edit and delete actions.
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit product',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showEditDialog(product),
                            ),
                            IconButton(
                              tooltip: 'Delete product',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _page > 1 && !_loading
                        ? () => _changePage(_page - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                  Text('Page $_page'),
                  OutlinedButton.icon(
                    onPressed: _page < _totalPages && !_loading
                        ? () => _changePage(_page + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared form used for both creating and editing products.
class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({required this.repository, this.product});

  final ProductRepository repository;
  final Product? product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _categoryController = TextEditingController(
      text: product?.category ?? 'Electronics',
    );
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '10.00',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '1',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final name = _nameController.text.trim();
      final category = _categoryController.text.trim();
      final price = double.parse(_priceController.text);
      final stock = int.parse(_stockController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      if (_isEditing) {
        await widget.repository.updateProduct(
          id: widget.product!.id,
          name: name,
          category: category,
          price: price,
          stock: stock,
          description: description,
        );
      } else {
        await widget.repository.createProduct(
          name: name,
          category: category,
          price: price,
          stock: stock,
          description: description,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = _isEditing
            ? 'Could not update product. Please try again.'
            : 'Could not create product. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit product' : 'Create product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Enter at least 2 characters'
                    : null,
              ),
              TextFormField(
                controller: _categoryController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Enter a category'
                    : null,
              ),
              TextFormField(
                controller: _priceController,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  final price = double.tryParse(value ?? '');

                  if (price == null || !price.isFinite || price < 0) {
                    return 'Enter a valid non-negative price';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
                validator: (value) {
                  final stock = int.tryParse(value ?? '');

                  if (stock == null || stock < 0) {
                    return 'Enter a non-negative integer';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                enabled: !_saving,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveProduct,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save changes' : 'Create'),
        ),
      ],
    );
  }
}
