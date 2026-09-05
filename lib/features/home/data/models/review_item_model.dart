class ReviewItemModel {
  final String profileImage; // Path to the profile image
  final String reviewerText; // Text of the review or comment
  final double rating; // Rating value

  ReviewItemModel({
    required this.profileImage,
    required this.reviewerText,
    required this.rating,
  });

// factory ReviewItemModel.fromJson(Map<String, dynamic> json) {
//   return ReviewItemModel(
//     profileImage: json['profileImage'],
//     reviewerText: json['reviewerText'],
//     rating: json['rating'].toDouble(),
//   );
// }
}
