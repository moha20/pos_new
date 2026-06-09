class CustomerEntity {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double totalPurchases;
  final double balance;
  final DateTime createdAt;
  final String priceLevel; // 'retail' | 'salesman' | 'company' | 'wholesale'

  CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalPurchases,
    required this.balance,
    required this.createdAt,
    required this.priceLevel,
  });
}
