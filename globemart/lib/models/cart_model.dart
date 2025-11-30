class CartModel {
  final int id;
  final String title;
  final int price;
  final int qty;
  final String image;

  CartModel({
    required this.id,
    required this.title,
    required this.price,
    required this.qty,
    required this.image,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'qty': qty,
        'image': image,
      };

  factory CartModel.fromMap(Map map) => CartModel(
        id: map['id'],
        title: map['title'],
        price: map['price'],
        qty: map['qty'],
        image: map['image'],
      );
}
