import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/catalog/product.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/product_list_cubit/product_list_cubit.dart';
import 'widgets/product_card.dart';

/// The active store's catalogue.
class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductListCubit>(
      create: (_) => ProductListCubit()..load(),
      child: const _ProductListBody(),
    );
  }
}

class _ProductListBody extends StatelessWidget {
  const _ProductListBody();

  Future<void> _toggle(BuildContext context, Product product) async {
    final next =
        product.isActive ? ProductStatus.inactive : ProductStatus.active;

    final error = await ProductListCubit.get(context).setStatus(product.id, next);
    if (!context.mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(
      context,
      next == ProductStatus.active
          ? '"${product.name}" sudah terbit.'
          : '"${product.name}" dinonaktifkan.',
    );
  }

  Future<void> _openForm(BuildContext context, {int? productId}) async {
    final cubit = ProductListCubit.get(context);
    await context.push(
      productId == null
          ? SellerRoutes.productCreate
          : SellerRoutes.productEditPath(productId),
    );
    // The form writes through its own cubit, so the list is stale on return —
    // unless this screen was popped while the form was open, in which case the
    // cubit is already closed and emitting into it would throw.
    if (cubit.isClosed) return;
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Produk'),
      floatingActionButton: BlocBuilder<ProductListCubit, ProductListState>(
        builder: (context, state) => state is ProductListNoStore
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Produk'),
              ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProductListCubit, ProductListState>(
          builder: (context, state) => switch (state) {
            ProductListInProgress() => const LoadingIndicatorView(),
            ProductListNoStore() => const EmptyStateView(
                icon: Icons.storefront_outlined,
                message: 'Pilih toko dulu untuk melihat produknya.',
              ),
            ProductListFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => ProductListCubit.get(context).load(),
              ),
            ProductListSuccess() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ProductListSuccess state) {
    if (state.isEmpty) {
      return EmptyStateView(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada produk di toko ini.',
        action: FilledButton(
          onPressed: () => _openForm(context),
          child: const Text('Tambah produk'),
        ),
      );
    }

    final visible = state.visible;

    return Column(
      children: <Widget>[
        _FilterBar(state: state),
        if (state.draftCount > 0) _DraftHint(count: state.draftCount),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ProductListCubit.get(context).load(),
            child: visible.isEmpty
                ? ListView(
                    children: <Widget>[
                      SizedBox(height: context.screenHeight * 0.2),
                      EmptyStateView(
                        message:
                            'Tidak ada produk berstatus "${state.filter.label}".',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => 12.sbh,
                    itemBuilder: (context, index) {
                      final product = visible[index];
                      return ProductCard(
                        product: product,
                        onTap: () =>
                            _openForm(context, productId: product.id),
                        onToggleStatus: product.status == ProductStatus.archived
                            ? null
                            : () => _toggle(context, product),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});

  final ProductListSuccess state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: ProductStatusFilter.values.length,
        separatorBuilder: (_, __) => 8.sbw,
        itemBuilder: (context, index) {
          final filter = ProductStatusFilter.values[index];
          return ChoiceChip(
            label: Text(filter.label),
            selected: state.filter == filter,
            onSelected: (_) => ProductListCubit.get(context).setFilter(filter),
          );
        },
      ),
    );
  }
}

/// A draft is invisible to buyers, and nothing on the server ever says so.
class _DraftHint extends StatelessWidget {
  const _DraftHint({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: 12.pa,
      decoration: BoxDecoration(
        color: kWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              '$count produk masih draf dan belum terlihat pembeli. '
              'Terbitkan supaya bisa dijual.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}
