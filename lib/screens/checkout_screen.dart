import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? userPhone;
  String? userAddress;
  bool isLoadingAddress = true;
  bool hasError = false;
  String errorMessage = '';
  String selectedPayment = 'COD';
  String promoCode = '';
  double discount = 0.0;
  double deliveryFee = 10.0;
  bool isPromoClaimed = false;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserPhoneAndAddress();
    });
  }

  Future<void> fetchUserPhoneAndAddress() async {
    try {
      setState(() {
        isLoadingAddress = true;
        hasError = false;
      });

      final prefs = await SharedPreferences.getInstance();
      userPhone = prefs.getString('userPhone');

      if (userPhone == null || userPhone!.isEmpty) {
        throw Exception('User phone number not found');
      }

      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userPhone');
      
      // Use .once() instead of .get() for better error handling
      final addressSnap = await userRef.child('location/address').once();
      final promoSnap = await userRef.child('promoClaimed').once();

      if (!mounted) return;

      setState(() {
        userAddress = addressSnap.snapshot.exists 
            ? addressSnap.snapshot.value.toString() 
            : 'No address found. Please update in profile.';
        isPromoClaimed = promoSnap.snapshot.exists && promoSnap.snapshot.value == true;
        isLoadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingAddress = false;
        hasError = true;
        errorMessage = 'Failed to load user data: ${e.toString()}';
      });
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

    try {
      if (promoCode == 'MUBARAKOFF30') {
        if (isPromoClaimed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Promo code already used'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          double percentageDiscount = itemsTotal * 0.30;
          double appliedDiscount = percentageDiscount > 30 ? 30 : percentageDiscount;

          await FirebaseDatabase.instance
              .ref('users/$userPhone/promoClaimed')
              .set(true);

          if (!mounted) return;
          setState(() {
            discount = appliedDiscount;
            isPromoClaimed = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Promo code applied!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          discount = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid promo code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply promo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (isPlacingOrder) return;
    
    setState(() {
      isPlacingOrder = true;
    });

    try {
      final orderTimestamp = DateTime.now().toIso8601String();
      double itemsTotal = cart.totalAmount;
      double totalAmount = itemsTotal + deliveryFee - discount;

      Map<String, dynamic> orderData = {
        'userPhone': userPhone,
        'userAddress': userAddress,
        'paymentMethod': selectedPayment,
        'promoCode': promoCode,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'status': 'pending',
        'items': cart.items.values.map((item) {
          return {
            'itemName': item.title,
            'quantity': item.quantity,
            'price': item.price,
            'totalPrice': item.price * item.quantity,
          };
        }).toList(),
        'timestamp': orderTimestamp,
      };

      await FirebaseDatabase.instance
          .ref('orders/$orderTimestamp')
          .set(orderData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order Placed Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      cart.clear();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
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
      body: _buildBody(cart, itemsTotal, totalAmount),
    );
  }

  Widget _buildBody(CartProvider cart, double itemsTotal, double totalAmount) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchUserPhoneAndAddress,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoadingAddress) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your information...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressSection(),
          const SizedBox(height: 20),
          _buildItemsSection(cart),
          const SizedBox(height: 20),
          _buildPromoCodeSection(itemsTotal),
          const SizedBox(height: 20),
          _buildPaymentMethodSection(),
          const SizedBox(height: 30),
          _buildOrderSummarySection(cart, itemsTotal, totalAmount),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userAddress ?? 'Address not available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Phone: ${userPhone ?? 'Not available'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported),
              ),
              title: Text(item.title),
              subtitle: Text('₹${item.price} x ${item.quantity}'),
              trailing: Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeSection(double itemsTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apply Promo Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) => promoCode = value,
          decoration: InputDecoration(
            labelText: 'Enter Promo Code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.green.shade50,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: IconButton(
              icon: const Icon(Icons.discount),
              onPressed: () => applyPromoCode(itemsTotal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ],
    );
  }

  Widget _buildOrderSummarySection(
    CartProvider cart, 
    double itemsTotal, 
    double totalAmount
  ) {
    return Container(
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
          _summaryRow('Items Total', '₹${itemsTotal.toStringAsFixed(2)}'),
          _summaryRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
          _summaryRow(
            'Promo Code Discount',
            '- ₹${discount.toStringAsFixed(2)}',
            color: discount > 0 ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const Divider(),
          _summaryRow(
            'Total Amount',
            '₹${totalAmount.toStringAsFixed(2)}',
            isBold: true,
            color: Colors.green.shade900,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isPlacingOrder ? null : () => _placeOrder(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade900,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isPlacingOrder
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'PLACE ORDER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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