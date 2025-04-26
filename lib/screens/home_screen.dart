import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mubarak_vegetables/widgets/product_grid_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/products_provider.dart';
import '../screens/product_detail_screen.dart';
import '../screens/shared_prefs_helper.dart';
import '../widgets/CategoryChip.dart';
import '../widgets/PromoBanner.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Hi there!";
  String userPhone = "";
  String userAddress = "Address not available";
  int _selectedCategoryIndex = 0;

  final List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadData();
    });
  }

  Future<void> _loadUserData() async {
    final name = await SharedPrefsHelper.getUserName() ?? '';
    final phone = await SharedPrefsHelper.getUserPhone() ?? '';

    setState(() {
      userName = name.isNotEmpty ? "Hi, $name!" : "Hi there!";
      userPhone = phone;
    });

    if (userPhone.isNotEmpty) {
      Object fetchedAddress = await _fetchUserAddressFromFirebase(userPhone);
      setState(() {
        userAddress = fetchedAddress as String;
      });
    }
  }

  Future<Object> _fetchUserAddressFromFirebase(String phone) async {
    final ref = FirebaseDatabase.instance.ref().child('users');
    DataSnapshot snapshot = await ref.child(phone).get();

    if (snapshot.exists) {
      Object address =
          snapshot.child('location')?.child('address').value ??
          "Address not available";
      return address;
    } else {
      return "Address not available";
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body:
          productsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productsProvider.error != null
              ? Center(child: Text(productsProvider.error!))
              : CustomScrollView(
                slivers: [
                  // ✅ Beautiful SliverAppBar with username + address
                  SliverAppBar(
                    expandedHeight: size.height * 0.13,
                    pinned: true,
                    backgroundColor: Colors.green.shade700,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0f4c3a), Color(0xFF1cb279)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 60,
                              left: 16,
                              right: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 3,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        userAddress,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1.5, 1.5),
                                              blurRadius: 3,
                                              color: Colors.black45,
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Promo Banner + Categories
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const PromoBanner(
                          title: '30% OFF',
                          subtitle: 'USE PROMO CODE MUBARAKOFF30',
                          buttonText: 'Order Now',
                          imagePath: 'assets/images/vegi.jpeg',
                        ),
                        const SizedBox(height: 24),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Vegetables',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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

                  // ✅ Product Grid
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
