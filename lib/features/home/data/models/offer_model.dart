class OfferModel {
  String id;
  String title;
  int percent;
  String productID;
  List<String> color;
  String description;
  String imageCover;
  String createdAt;
  String updatedAt;
  int v;

  OfferModel({
    required this.id,
    required this.title,
    required this.percent,
    required this.productID,
    required this.color,
    required this.description,
    required this.imageCover,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['_id'],
      title: json['title'],
      percent: json['percent'],
      productID: json['productID'],
      color: List<String>.from(json['color']),
      description: json['description'],
      imageCover: json['imageCover'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class OfferList {
  List<OfferModel> offers;

  OfferList({required this.offers});

  factory OfferList.fromJson(List<dynamic> json) {
    List<OfferModel> offerList = [];
    offerList = json.map((offer) => OfferModel.fromJson(offer)).toList();
    return OfferList(offers: offerList);
  }
}
