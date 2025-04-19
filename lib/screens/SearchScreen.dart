import 'package:flutter/material.dart';
import 'package:mubarak_vegetables/widgets/product_card.dart';
import 'package:mubarak_vegetables/widgets/product_grid_item.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final theme = Theme.of(context);

    // Filter products based on search query
    final filteredProducts =
        productsProvider.featuredProducts
            .where(
              (product) => product.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Products", style: theme.textTheme.titleLarge),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 20),

            // Displaying filtered products
            Expanded(
              child:
                  filteredProducts.isEmpty
                      ? Center(
                        child: Text(
                          "No products found.",
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (ctx, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
