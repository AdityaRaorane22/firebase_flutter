import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String paymentMethod;
  final String status;
  final String? message; // <-- NEW
  final bool isPaid;
  final DateTime orderDate;
  final double totalAmount;
  final DeliveryAddress deliveryAddress;
  final List<Item> items;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.paymentMethod,
    required this.status,
    this.message = '',
    required this.isPaid,
    required this.orderDate,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data) {
    List<Item> itemList = [];
    final itemsData = data['items'];
    if (itemsData is List) {
      itemList = itemsData.map<Item>((item) => Item.fromMap(item)).toList();
    }

    return OrderModel(
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? '',
      message: data['message'], // <-- NEW
      isPaid: data['isPaid'] ?? false,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      deliveryAddress: DeliveryAddress.fromMap(data['deliveryAddress']),
      items: itemList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'status': status,
      'message': message, // <-- NEW
      'isPaid': isPaid,
      'orderDate': orderDate,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class DeliveryAddress {
  final String city;
  final String state;

  DeliveryAddress({required this.city, required this.state});

  factory DeliveryAddress.fromMap(Map<String, dynamic> data) {
    return DeliveryAddress(
      city: data['city'] ?? '',
      state: data['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'state': state,
    };
  }
}

class Item {
  final String itemId;
  final String name;
  final double price;
  final int quantity;

  Item({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory Item.fromMap(Map<String, dynamic> data) {
    return Item(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
