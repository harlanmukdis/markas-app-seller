class ProductModel {
  String id;
  String name;
  String desc;
  String image;
  double price;
  double beforeDiscount;
  int discountPercentage;

  ProductModel(
      {required this.id,
      required this.name,
      required this.desc,
      required this.image,
      required this.price,
      required this.beforeDiscount,
      required this.discountPercentage});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      image: json['imageCover'],
      price: json['price'].toDouble(),
      beforeDiscount: json['afterDiscount'],
      discountPercentage: json['discountPercentage'],
      desc: json['desc'],
    );
  }
}

class ProductsModels {
  List<ProductModel> products;

  ProductsModels({required this.products});

  factory ProductsModels.fromJson(List<dynamic> json) {
    List<ProductModel> productList = [];
    productList =
        json.map((product) => ProductModel.fromJson(product)).toList();
    return ProductsModels(products: productList);
  }
}
