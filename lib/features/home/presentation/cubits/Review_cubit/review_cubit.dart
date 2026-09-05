import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../data/models/review_item_model.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit() : super(ReviewInitial());

  static ReviewCubit get(context) => BlocProvider.of(context);

  int reviewIndex = 0;

  TextEditingController messageController = TextEditingController();

  // Method to change review index and emit the state
  void changeReviewIndex(int index) {
    reviewIndex = index;
    emit(ChangeReviewIndexState());
  }

  final List<ReviewItemModel> reviewItemsAll = [
    ReviewItemModel(
      profileImage: AppImages.person1,
      reviewerText: 'Great product! The delivery was on time.',
      rating: 2,
    ),
    ReviewItemModel(
      profileImage: AppImages.person2,
      reviewerText: 'Not satisfied with the packaging.',
      rating: 3,
    ),
    ReviewItemModel(
      profileImage: AppImages.person3,
      reviewerText: 'Excellent customer service, very responsive.',
      rating: 4.0,
    ),
    ReviewItemModel(
      profileImage: AppImages.person4,
      reviewerText: 'Excellent customer service, very responsive.',
      rating: 5.0,
    ),
    ReviewItemModel(
      profileImage: AppImages.person5,
      reviewerText: 'Excellent customer service, very responsive.',
      rating: 2.0,
    ),
    ReviewItemModel(
      profileImage: AppImages.person,
      reviewerText: 'Excellent customer service, very responsive.',
      rating: 3,
    ),
  ];

  void getAllReview(int index) {}
}
