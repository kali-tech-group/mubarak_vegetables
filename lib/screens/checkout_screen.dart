import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  String? _paymentMethod;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      await Provider.of<OrdersProvider>(context, listen: false).addOrder(
        cart.items.values.toList(),
        amount: cart.totalAmount,
        address: _addressController.text,
        paymentMethod: _paymentMethod!,
        items: [],
      );

      cart.clear(); // Clear the cart items after placing the order
      Navigator.pushReplacementNamed(context, '/order-success');
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: const [
                  DropdownMenuItem(
                    value: 'cod',
                    child: Text('Cash on Delivery'),
                  ),
                  DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _submitOrder(context),
                child: const Text(
                  'PLACE ORDER',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
