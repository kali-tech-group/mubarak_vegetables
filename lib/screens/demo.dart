import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';

class demo extends StatefulWidget {
  static const routeName = '/checkout';

  @override
  State<demo> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<demo> {
  String? userPhone;
  String? userAddress;
  bool isLoadingAddress = true;
  bool isPlacingOrder = false;
  String selectedPayment = 'COD';
  String promoCode = '';
  double discount = 0.0;
  double deliveryFee = 10.0;
  bool isPromoClaimed = false;

  @override
  void initState() {
    super.initState();
    fetchUserPhoneAndAddress();
  }

  Future<void> fetchUserPhoneAndAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userPhone = prefs.getString('userPhone');

      if (userPhone != null) {
        DatabaseReference userRef = FirebaseDatabase.instance.ref(
          'users/$userPhone',
        );
        final addressSnap = await userRef.child('location/address').get();
        final promoSnap = await userRef.child('promoClaimed').get();

        if (mounted) {
          setState(() {
            userAddress =
                addressSnap.exists
                    ? addressSnap.value.toString()
                    : 'No address found. Please update in profile.';
            isPromoClaimed = promoSnap.exists ? promoSnap.value as bool : false;
            isLoadingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingAddress = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingAddress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading address: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void applyPromoCode(double itemsTotal) async {
    if (promoCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (promoCode.toUpperCase() == 'MUBARAKOFF30') {
      if (isPromoClaimed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promo code already used'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        try {
          double percentageDiscount = itemsTotal * 0.30;
          double appliedDiscount =
              percentageDiscount > 30 ? 30 : percentageDiscount;

          if (mounted) {
            setState(() {
              discount = appliedDiscount;
            });
          }

          if (userPhone != null) {
            await FirebaseDatabase.instance
                .ref('users/$userPhone/promoClaimed')
                .set(true);
          }

          if (mounted) {
            setState(() {
              isPromoClaimed = true;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Promo code applied!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error applying promo: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          discount = 0.0;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> placeOrder(CartProvider cart) async {
    if (userPhone == null || userPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userAddress == null ||
        userAddress!.isEmpty ||
        userAddress == 'No address found. Please update in profile.') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please update your address before placing order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Prepare order data
      final orderData = {
        'fields': {
          'User Phone': userPhone,
          'Address': userAddress,
          'Items': json.encode(
            cart.items.values
                .map(
                  (item) => {
                    'title': item.title,
                    'price': item.price,
                    'quantity': item.quantity,
                    'imageUrl': item.imageUrl,
                  },
                )
                .toList(),
          ),
          'Payment Method': selectedPayment,
          'Subtotal': cart.totalAmount,
          'Delivery Fee': deliveryFee,
          'Discount': discount,
          'Total': cart.totalAmount + deliveryFee - discount,
          'Status': 'Pending',
          'Order Time': DateTime.now().toIso8601String(),
        },
      };

      // Replace with your Airtable API details
      const airtableBaseId = 'YOUR_AIRTABLE_BASE_ID';
      const airtableApiKey = 'YOUR_AIRTABLE_API_KEY';
      const airtableTableName = 'orders';

      final url = Uri.parse(
        'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $airtableApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        // Order successfully placed
        cart.clearCart();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
          'Failed to place order. Status code: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    double itemsTotal = cart.totalAmount;
    double totalAmount = itemsTotal + deliveryFee - discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          isLoadingAddress
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '$userAddress\nPhone: $userPhone',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...cart.items.values.map(
                      (item) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Image.network(
                            item.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.title),
                          subtitle: Text('₹${item.price} x ${item.quantity}'),
                          trailing: Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Apply Promo Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          promoCode = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Promo Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.green.shade50,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => applyPromoCode(itemsTotal),
                      child: const Text('Apply Promo Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.money, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildSummaryRow(
                            'Items Total',
                            '₹${itemsTotal.toStringAsFixed(2)}',
                          ),
                          _buildSummaryRow(
                            'Delivery Fee',
                            '₹${deliveryFee.toStringAsFixed(2)}',
                          ),
                          _buildSummaryRow(
                            'Promo Code Discount',
                            '- ₹${discount.toStringAsFixed(2)}',
                            color:
                                discount > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Total Amount',
                            '₹${totalAmount.toStringAsFixed(2)}',
                            isBold: true,
                            color: Colors.green.shade900,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isPlacingOrder ? null : () => placeOrder(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isPlacingOrder
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : const Text(
                      'PLACE ORDER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
