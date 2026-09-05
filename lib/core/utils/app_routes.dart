import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/route/app_route_seller.dart';

import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/auth/presentation/views/welcome_view.dart';
import '../../features/home/presentation/views/all_review.dart';
import '../../features/home/presentation/views/new_fashion_view.dart';
import '../../features/home/presentation/views/product_details.dart';
import '../../features/home/presentation/views/write_review_screen.dart';
import '../../features/my_cart/presentation/views/checkout_view.dart';
import '../../features/notifications&messages/presentation/views/chat_view.dart';
import '../../features/notifications&messages/presentation/views/notifications_layout.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/profile/presentaion/views/about_app_view.dart';
import '../../features/profile/presentaion/views/add_card_view.dart';
import '../../features/profile/presentaion/views/contact_us_view.dart';
import '../../features/profile/presentaion/views/contact_us_view2.dart';
import '../../features/profile/presentaion/views/create_new_password_view.dart';
import '../../features/profile/presentaion/views/edit_profile_view.dart';
import '../../features/profile/presentaion/views/forgot_password_view.dart';
import '../../features/profile/presentaion/views/help_center.dart';
import '../../features/profile/presentaion/views/otp_verification_view.dart';
import '../../features/profile/presentaion/views/payment_methods_view.dart';
import '../../features/profile/presentaion/views/settings_view.dart';
import '../../features/shared/views/home_layout.dart';
import '../../features/spalsh/splash_screen.dart';

// Define route constants
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String resetPassword = '/resetPassword';
  static const String register = '/register';
  static const String homeLayout = '/homeLayout';
  static const String productDetails = '/productDetails';
  static const String allReview = '/allReview';
  static const String writeReview = '/writeReview';
  static const String checkout = '/checkout';
  static const String newFashion = '/newFashion';
  static const String editProfile = '/editProfile';
  static const String settings = '/settings';
  static const String paymentMethods = '/paymentMethods';
  static const String addCardView = '/addCard';
  static const String helpCenter = '/helpCenter';
  static const String contactUs = '/contactUs';
  static const String contactUs2 = '/contactUs2';
  static const String aboutApp = '/aboutApp';
  static const String forgotPassword = '/forgotPassword';
  static const String otpVerification = '/otpVerification';
  static const String createNewPassword = '/createNewPassword';
  static const String notifications = '/notifications';
  static const String chat = '/chat';
}

final GoRouter router = GoRouter(
  // The seller flow is the app. The UI kit's animated splash renders SVGs from
  // `assets/images/`, which does not exist in this repo, so it cannot be the
  // entry point — SellerBootstrapView decides where to go instead. Every kit
  // route below stays registered and reachable.
  initialLocation: SellerRoutes.bootstrap,
  routes: <RouteBase>[
    // Seller domain routes live in their own file (config/route/).
    ...appRouterSeller,
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const SplashView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const OnboardingView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const WelcomeView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const LoginView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ResetPasswordView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const RegisterView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.homeLayout,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const HomeLayout(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final String images = state.extra! as String;
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: ProductDetails(image: images),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.allReview,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const AllReviewScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.writeReview,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const WriteReviewScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.checkout,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const CheckoutView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.newFashion,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const NewFashionView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const EditProfileView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const SettingsView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentMethods,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const PaymentMethodsView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addCardView,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const AddCardView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.helpCenter,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const HelpCenterView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contactUs,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ContactUsView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contactUs,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ContactUsView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contactUs2,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ContactUsView2(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.aboutApp,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const AboutAppView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ForgotPasswordView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.otpVerification,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const OtpVerificationView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.createNewPassword,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const CreateNewPasswordView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const NotificationsLayout(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chat,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return FadeThroughTransitionPageWrapper(
          transitionKey: state.pageKey,
          page: const ChatView(),
        );
      },
    ),
  ],
);

// Create a reusable FadeThroughTransitionPageWrapper
class FadeThroughTransitionPageWrapper extends Page {
  const FadeThroughTransitionPageWrapper({
    required this.page,
    required this.transitionKey,
  }) : super(key: transitionKey);

  final Widget page;
  final ValueKey transitionKey;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
    );
  }
}
