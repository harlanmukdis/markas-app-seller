import '../../../utils/json_parse.dart';

/// `GET /offers/{id}/reviews` (v2.2).
///
/// A buyer-side feature, but it matters to a store: rating feeds the buyer's
/// `min_rating` filter and the `sort=popular` ordering, so it directly affects
/// whether the store's listing is found at all.
class OfferReviews {
  const OfferReviews({
    this.reviewCount = 0,
    this.averageRating = 0,
    this.items = const <Review>[],
  });

  final int reviewCount;
  final double averageRating;
  final List<Review> items;

  factory OfferReviews.fromJson(Map<String, dynamic> json) {
    final summary = asMap(json['summary']);
    return OfferReviews(
      reviewCount: asInt(summary['review_count']),
      averageRating: asDouble(summary['avg_rating']),
      items: asModelList(json['items'], Review.fromJson),
    );
  }

  bool get hasReviews => reviewCount > 0;

  /// `4.00` -> `4,0`, matching the decimal comma used elsewhere in the app.
  String get ratingLabel =>
      averageRating.toStringAsFixed(1).replaceAll('.', ',');
}

class Review {
  const Review({
    required this.id,
    required this.rating,
    this.offerId,
    this.buyerId,
    this.buyerName,
    this.comment,
    this.createdAt,
  });

  final int id;
  final int rating;
  final int? offerId;
  final int? buyerId;
  final String? buyerName;
  final String? comment;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: asInt(json['id']),
        rating: asInt(json['rating']),
        offerId: asIntOrNull(json['offer_id']),
        buyerId: asIntOrNull(json['buyer_id']),
        buyerName: asStringOrNull(json['buyer_name']),
        comment: asStringOrNull(json['comment']),
        createdAt: asCreatedDate(json),
      );
}
