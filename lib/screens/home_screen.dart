import 'package:flutter/material.dart';
import 'package:mubarak_vegetables/widgets/CategoryChip.dart';
import 'package:mubarak_vegetables/widgets/PromoBanner.dart';
import 'package:mubarak_vegetables/widgets/product_card.dart';

import 'package:mubarak_vegetables/widgets/product_grid_item.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../screens/product_detail_screen.dart'; // Import the product detail screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Nithesh";
  String userLocation = "Chennai, Tamil Nadu";
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'All',
    'Leafy',
    'Root',
    'Fruits',
    'Organic',
    'Seasonal',
    'Herbs',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          productsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productsProvider.error != null
              ? Center(child: Text(productsProvider.error!))
              : CustomScrollView(
                slivers: [
                  // App Bar Sliver
                  SliverAppBar(
                    expandedHeight: size.height * 0.15,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Hi, $userName 👋',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[700]!, Colors.green[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Content Sliver
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Location Row
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              userLocation,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Change',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Promo Banner
                        const PromoBanner(
                          title: '30% OFF',
                          subtitle: 'On your first order',
                          buttonText: 'Order Now',
                          imagePath: 'assets/vegetable_basket.png',
                        ),
                        const SizedBox(height: 24),

                        // Categories Horizontal List
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (ctx, index) {
                              return CategoryChip(
                                label: categories[index],
                                isSelected: _selectedCategoryIndex == index,
                                onSelected: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Vegetables',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See all',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ]),
                    ),
                  ),

                  // Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((
                        BuildContext context,
                        int index,
                      ) {
                        final product =
                            productsProvider.featuredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to ProductDetailScreen
                            Navigator.pushNamed(
                              context,
                              ProductDetailScreen.routeName,
                              arguments: product.id,
                            );
                          },
                          child: ProductCard(product: product),
                        );
                      }, childCount: productsProvider.featuredProducts.length),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
    );
  }
}
