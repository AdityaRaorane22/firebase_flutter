import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  final Map<String, String> orderStates = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<OrderModel>> fetchOrders() async {
    final snapshot = await FirebaseFirestore.instance.collection('orders').get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap({
              ...doc.data(),
              'orderId': doc.id, // 🔥 assign Firestore doc ID to orderId
            }))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, {String? message}) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      if (message != null) 'message': message,
    });
  }

  void handleAccept(String orderId) async {
    setState(() {
      orderStates[orderId] = 'Accepted';
    });
    await updateOrderStatus(orderId, 'Accepted');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Order accepted successfully"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void handleReject(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedReason;
        final TextEditingController customReasonController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Reason for Rejection',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A55A2),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(
                    'Out of stock',
                    style: GoogleFonts.poppins(),
                  ),
                  value: 'Out of stock',
                  groupValue: selectedReason,
                  activeColor: const Color(0xFF4A55A2),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedReason = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Customer canceled',
                    style: GoogleFonts.poppins(),
                  ),
                  value: 'Customer canceled',
                  groupValue: selectedReason,
                  activeColor: const Color(0xFF4A55A2),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedReason = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Other',
                    style: GoogleFonts.poppins(),
                  ),
                  value: 'Other',
                  groupValue: selectedReason,
                  activeColor: const Color(0xFF4A55A2),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedReason = value;
                    });
                  },
                ),
                if (selectedReason == 'Other')
                  TextField(
                    controller: customReasonController,
                    decoration: InputDecoration(
                      hintText: 'Enter custom reason',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A55A2), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String reasonToSave = '';
                  if (selectedReason == 'Other') {
                    reasonToSave = customReasonController.text.trim();
                  } else {
                    reasonToSave = selectedReason ?? '';
                  }

                  if (reasonToSave.isNotEmpty) {
                    Navigator.of(context).pop();
                    setState(() {
                      orderStates[orderId] = 'Rejected';
                    });
                    await updateOrderStatus(orderId, 'Rejected', message: reasonToSave);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Order rejected successfully"),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A55A2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4A55A2),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF4A55A2),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: FutureBuilder<List<OrderModel>>(
              future: fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A55A2),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A55A2), Color(0xFF7895CB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A55A2).withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No orders found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A55A2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your order list is empty',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderState = orderStates[order.orderId] ?? order.status;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: orderState == 'Accepted'
                                  ? Colors.green.withOpacity(0.1)
                                  : orderState == 'Rejected'
                                      ? Colors.red.withOpacity(0.1)
                                      : const Color(0xFF4A55A2).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: orderState == 'Accepted'
                                            ? Colors.green.withOpacity(0.2)
                                            : orderState == 'Rejected'
                                                ? Colors.red.withOpacity(0.2)
                                                : const Color(0xFF4A55A2).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        orderState == 'Accepted'
                                            ? Icons.check_circle
                                            : orderState == 'Rejected'
                                                ? Icons.cancel
                                                : Icons.pending,
                                        color: orderState == 'Accepted'
                                            ? Colors.green
                                            : orderState == 'Rejected'
                                                ? Colors.red
                                                : const Color(0xFF4A55A2),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order #${order.orderId.substring(0, 8)}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        Text(
                                          'Status: $orderState',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: orderState == 'Accepted'
                                                ? Colors.green
                                                : orderState == 'Rejected'
                                                    ? Colors.red
                                                    : const Color(0xFF4A55A2),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${order.totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: const Color(0xFF4A55A2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Order Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  'Customer ID:',
                                  order.userId,
                                  Icons.person,
                                ),
                                _buildInfoRow(
                                  'Payment Method:',
                                  order.paymentMethod,
                                  Icons.payment,
                                ),
                                _buildInfoRow(
                                  'Paid:',
                                  order.isPaid ? "Yes" : "No",
                                  Icons.attach_money,
                                  textColor: order.isPaid ? Colors.green : Colors.red,
                                ),
                                _buildInfoRow(
                                  'Order Date:',
                                  order.orderDate.toString(),
                                  Icons.calendar_today,
                                ),
                                _buildInfoRow(
                                  'Delivery Address:',
                                  '${order.deliveryAddress.city}, ${order.deliveryAddress.state}',
                                  Icons.location_on,
                                ),
                                
                                if (order.message != null && order.message!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info, color: Colors.red, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Reason: ${order.message}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 16),
                                
                                // Order Items
                                Text(
                                  'Order Items',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'x${item.quantity}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '₹${item.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4A55A2),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                
                                const SizedBox(height: 12),
                                
                                // Total
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A55A2).withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount:',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '₹${order.totalAmount.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: const Color(0xFF4A55A2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Action Buttons
                                orderState == 'Pending' ? Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          onPressed: () => handleAccept(order.orderId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            'Accept',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          onPressed: () => handleReject(order.orderId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            'Reject',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ) : SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle view details or other action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A55A2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      'View Details',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF4A55A2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor ?? Colors.grey.shade900,
                    ),
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