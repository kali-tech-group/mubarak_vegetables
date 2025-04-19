import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mubarak_vegetables/models/order.dart';

class OrderHistoryScreen extends StatelessWidget {
  final List<Order> orders = [
    Order(
      id: '#VEG12345',
      date: DateTime.now().subtract(Duration(days: 2)),
      items: [
        OrderItem(name: 'Organic Tomatoes', quantity: 2, price: 2.99),
        OrderItem(name: 'Fresh Carrots', quantity: 1, price: 1.49),
      ],
      total: 7.47,
      status: OrderStatus.delivered,
      deliveryAddress: '123 Green Park, Chennai, Tamil Nadu',
    ),
    Order(
      id: '#VEG67890',
      date: DateTime.now().subtract(Duration(days: 7)),
      items: [
        OrderItem(name: 'Spinach', quantity: 3, price: 1.99),
        OrderItem(name: 'Bell Peppers', quantity: 2, price: 3.49),
      ],
      total: 12.95,
      status: OrderStatus.delivered,
      deliveryAddress: '123 Green Park, Chennai, Tamil Nadu',
    ),
    Order(
      id: '#VEG24680',
      date: DateTime.now().subtract(Duration(days: 15)),
      items: [
        OrderItem(name: 'Potatoes', quantity: 5, price: 0.99),
        OrderItem(name: 'Onions', quantity: 2, price: 1.29),
      ],
      total: 7.33,
      status: OrderStatus.delivered,
      deliveryAddress: '123 Green Park, Chennai, Tamil Nadu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body:
          orders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Orders Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your order history will appear here',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to home screen
                      },
                      child: Text('Start Shopping'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(context, order),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${dateFormat.format(order.date)} • ${timeFormat.format(order.date)}',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 12),
              ...order.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              if (order.items.length > 2)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${order.items.length - 2} more items',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _reorderItems(context, order),
                      child: Text('Reorder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderDetails(context, order),
                      child: Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.shippped:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return OrderDetailsSheet(order: order);
          },
        );
      },
    );
  }

  void _reorderItems(BuildContext context, Order order) {
    // Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${order.items.length} items to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Orders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All Orders', true),
              _buildFilterOption('Delivered', false),
              _buildFilterOption('Processing', false),
              _buildFilterOption('Cancelled', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Apply'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String text, bool selected) {
    return ListTile(
      title: Text(text),
      trailing: selected ? Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        // Handle filter selection
      },
    );
  }
}

class OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsSheet({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildDetailRow('Order ID', order.id),
            _buildDetailRow(
              'Order Date',
              DateFormat('MMM dd, yyyy - hh:mm a').format(order.date),
            ),
            _buildDetailRow(
              'Status',
              order.status.toString().split('.').last.toUpperCase(),
            ),
            SizedBox(height: 16),
            Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(order.deliveryAddress),
            SizedBox(height: 16),
            Text(
              'Order Items (${order.items.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.shopping_basket, color: Colors.grey),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${item.quantity} x \$${item.price}'),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            _buildDetailRow(
              'Subtotal',
              '\$${(order.total * 0.9).toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Delivery Fee',
              '\$${(order.total * 0.1).toStringAsFixed(2)}',
            ),
            _buildDetailRow('Discount', '-\$0.00'),
            SizedBox(height: 8),
            Divider(thickness: 2),
            SizedBox(height: 8),
            _buildDetailRow(
              'Total Amount',
              '\$${order.total.toStringAsFixed(2)}',
              isBold: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _reorderItems(context, order),
              child: Text('Reorder Items'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _reorderItems(BuildContext context, Order order) {
    Navigator.pop(context); // Close the bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${order.items.length} items to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

enum OrderStatus { delivered, shippped, processing, cancelled }

class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryAddress,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}
