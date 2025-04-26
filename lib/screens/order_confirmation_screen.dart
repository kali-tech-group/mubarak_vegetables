import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final double totalAmount;
  final String userAddress;
  final List<dynamic> cartItems;

  const OrderConfirmationScreen({
    Key? key,
    required this.totalAmount,
    required this.userAddress,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display user address and order details
            Text(
              'Shipping Address: $userAddress',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Order Details:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (ctx, index) {
                  final product = cartItems[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text('₹${product['price']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Amount: ₹$totalAmount',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement payment gateway logic here
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Payment Successful'),
                        content: const Text('Thank you for your order!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context); // Go back to home screen
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
