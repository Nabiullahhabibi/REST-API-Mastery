import 'package:flutter/material.dart';
import 'core/network/api_client.dart';
import 'features/products/data/product_repository.dart';
import 'features/products/presentation/products_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RestApiMasteryApp(
    repository: ProductRepository(ApiClient()),
  ));
}

class RestApiMasteryApp extends StatelessWidget {
  const RestApiMasteryApp({super.key, required this.repository});
  final ProductRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST API Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: ProductsPage(repository: repository),
    );
  }
}
