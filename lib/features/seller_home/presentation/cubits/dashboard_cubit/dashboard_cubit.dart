import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/chat/chat.dart';
import '../../../../../core/domain/model/enums.dart';
import '../../../../../core/domain/model/finance/finance.dart';
import '../../../../../core/domain/model/order/order_model.dart';
import '../../../../../core/domain/model/report/reports.dart';
import '../../../../../core/domain/model/seller/seller_model.dart';
import '../../../../../core/domain/repositories/chat_repository.dart';
import '../../../../../core/domain/repositories/finance_repository.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../core/domain/repositories/report_repository.dart';
import '../../../../../core/domain/repositories/seller_repository.dart';
import '../../../../../di/injector.dart';

part 'dashboard_state.dart';

/// The store's home screen.
///
/// Five independent reads, fired together. Only the seller profile is allowed
/// to fail the screen; the rest degrade to a dash, because a store opening the
/// app to check its orders should not be blocked by a broken reports endpoint.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardLoadInProgress());

  static DashboardCubit get(BuildContext context) => BlocProvider.of(context);

  final SellerRepository _sellerRepository = injector<SellerRepository>();
  final FinanceRepository _financeRepository = injector<FinanceRepository>();
  final ReportRepository _reportRepository = injector<ReportRepository>();
  final OrderRepository _orderRepository = injector<OrderRepository>();
  final ChatRepository _chatRepository = injector<ChatRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const DashboardLoadInProgress());

    final results = await Future.wait(<Future<Object>>[
      _sellerRepository.getSeller(),
      _financeRepository.getBalance(),
      _reportRepository.getSellerPerformance(),
      _orderRepository.getSubOrders(),
      _chatRepository.getResponseRate(),
    ]);

    if (isClosed) return;

    final sellerResult = results[0] as DataState<SellerModel>;
    if (sellerResult is DataFailed<SellerModel>) {
      emit(DashboardLoadFailure(sellerResult.failure));
      return;
    }
    if (sellerResult is! DataSuccess<SellerModel>) {
      emit(
        const DashboardLoadFailure(
          DataError(
            code: DataErrorCode.notFound,
            message: 'Data toko tidak ditemukan untuk akun ini.',
          ),
        ),
      );
      return;
    }

    final subOrders = _valueOr<List<SubOrder>>(
      results[3] as DataState<List<SubOrder>>,
      const <SubOrder>[],
    );

    emit(
      DashboardLoadSuccess(
        seller: sellerResult.value,
        balance: _valueOrNull(results[1] as DataState<SellerBalance>),
        performance: _valueOrNull(results[2] as DataState<SellerPerformance>),
        responseRate: _valueOrNull(results[4] as DataState<ChatResponseRate>),
        pendingSubOrders:
            subOrders.where((subOrder) => subOrder.awaitingConfirmation).length,
      ),
    );
  }

  static T? _valueOrNull<T>(DataState<T> state) =>
      state is DataSuccess<T> ? state.value : null;

  static T _valueOr<T>(DataState<T> state, T fallback) =>
      state is DataSuccess<T> ? state.value : fallback;
}
