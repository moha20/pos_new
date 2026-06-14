import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/domain/entities/product_entity.dart';
import '../widgets/cart_widget.dart';
import '../../../../widgets/responsive_layout.dart';
import '../../../../services/barcode_service.dart';
import '../../../../core/di/di.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = true;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    // Load inventory and refresh POS next invoice count
    context.read<InventoryBloc>().add(LoadInventory());
    context.read<POSBloc>().add(POSInit());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 950;

    final mainContent = Column(
      children: [
        // Search & Scan Actions
        Padding(
          padding: EdgeInsets.all(12.0.r),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) {
                    context.read<InventoryBloc>().add(SearchInventory(val));
                  },
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () => setState(() => _isGridView = !_isGridView),
                tooltip: _isGridView ? 'view_list'.tr() : 'grid_view'.tr(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  padding: EdgeInsets.all(12.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton.icon(
                onPressed: () => _triggerBarcodeScanner(context),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text('barcode'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
        ),

        // Product Grid / List
        Expanded(
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, invState) {
              if (invState is InventoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (invState is InventoryLoaded) {
                final products = invState.filteredProducts.where((p) => p.isActive).toList();
                if (products.isEmpty) {
                  return Center(child: Text('no_data'.tr()));
                }
                if (_isGridView) {
                  return GridView.builder(
                    padding: EdgeInsets.all(12.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return _buildProductCard(context, p, theme);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(12.r),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return _buildProductListTile(context, p, theme);
                    },
                  );
                }
              }
              return Center(child: Text('no_data'.tr()));
            },
          ),
        ),
      ],
    );

    return BlocBuilder<POSBloc, POSState>(
      builder: (context, state) {
        return ResponsiveLayout(
          title: 'pos'.tr(),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: mainContent),
                    const Expanded(flex: 3, child: CartWidget()),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<int>(
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: theme.colorScheme.primary,
                            selectedForegroundColor: Colors.white,
                          ),
                          segments: [
                            ButtonSegment<int>(
                              value: 0,
                              icon: const Icon(Icons.grid_view_rounded),
                              label: Text('products'.tr()),
                            ),
                            ButtonSegment<int>(
                              value: 1,
                              icon: Badge(
                                label: Text('${state.cartItems.length}'),
                                isLabelVisible: state.cartItems.isNotEmpty,
                                child: const Icon(Icons.shopping_cart_rounded),
                              ),
                              label: Text('cart'.tr()),
                            ),
                          ],
                          selected: {_activeTab},
                          onSelectionChanged: (value) {
                            setState(() => _activeTab = value.first);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _activeTab == 0
                            ? mainContent
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CartWidget(),
                              ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.red),
        ),
      );
    } else if (path.startsWith('data:image/')) {
      try {
        final base64String = path.split(',').last;
        final bytes = base64.decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, color: Colors.red),
          ),
        );
      } catch (_) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.red),
        );
      }
    } else {
      if (kIsWeb) {
        return const Center(
          child: Icon(Icons.image, color: Colors.grey),
        );
      }
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.red),
        ),
      );
    }
  }

  Widget _buildProductPlaceholder(String name, ThemeData theme) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.6),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product, ThemeData theme) {
    final currencySymbol = 'currency_symbol'.tr();
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.isOutOfStock;

    Color cardBorderColor = theme.dividerColor.withOpacity(0.15);
    Color badgeColor = Colors.green;
    String badgeText = '${'stock'.tr()}: ${product.stock}';

    if (isOutOfStock) {
      cardBorderColor = Colors.red;
      badgeColor = Colors.red;
      badgeText = 'out_of_stock'.tr();
    } else if (isLowStock) {
      cardBorderColor = Colors.orange;
      badgeColor = Colors.orange;
      badgeText = 'low_stock'.tr() + ' (${product.stock})';
    }

    return InkWell(
      onTap: isOutOfStock
          ? null
          : () {
              context.read<POSBloc>().add(POSAddProduct(product));
            },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: cardBorderColor, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(12.0.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image or Placeholder
              Container(
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? _buildProductImage(product.imagePath!)
                    : _buildProductPlaceholder(product.name, theme),
              ),
              SizedBox(height: 8.h),

              // Product Name
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4.h),

              // Category & Brand
              Text(
                '${product.brand} • ${product.category}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),

              // Price (Retail is standard)
              Text(
                '${product.priceFor('retail').toStringAsFixed(2)} $currencySymbol',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),

              // Stock Status Badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListTile(BuildContext context, ProductEntity product, ThemeData theme) {
    final currencySymbol = 'currency_symbol'.tr();
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.isOutOfStock;

    Color cardBorderColor = theme.dividerColor.withOpacity(0.15);
    Color badgeColor = Colors.green;
    String badgeText = '${'stock'.tr()}: ${product.stock}';

    if (isOutOfStock) {
      cardBorderColor = Colors.red;
      badgeColor = Colors.red;
      badgeText = 'out_of_stock'.tr();
    } else if (isLowStock) {
      cardBorderColor = Colors.orange;
      badgeColor = Colors.orange;
      badgeText = 'low_stock'.tr() + ' (${product.stock})';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: cardBorderColor, width: 1.2),
      ),
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                context.read<POSBloc>().add(POSAddProduct(product));
              },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: Row(
            children: [
              // Product Image or Placeholder
              Container(
                height: 60.r,
                width: 60.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? _buildProductImage(product.imagePath!)
                    : _buildProductPlaceholder(product.name, theme),
              ),
              SizedBox(width: 12.w),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${product.brand} • ${product.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${product.priceFor('retail').toStringAsFixed(2)} $currencySymbol',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Add button / icon
              IconButton(
                icon: Icon(Icons.add_shopping_cart, color: isOutOfStock ? Colors.grey : theme.colorScheme.primary),
                onPressed: isOutOfStock
                    ? null
                    : () {
                        context.read<POSBloc>().add(POSAddProduct(product));
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerBarcodeScanner(BuildContext context) async {
    final barcodeService = Gravity.find<BarcodeService>();
    final code = await barcodeService.scanBarcode(context);
    if (code != null && code.isNotEmpty) {
      if (mounted) {
        context.read<POSBloc>().add(POSScanBarcode(code));
      }
    }
  }
}
