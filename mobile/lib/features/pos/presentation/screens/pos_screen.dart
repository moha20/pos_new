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
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventory());
    context.read<POSBloc>().add(POSInit());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 950;
    final isTablet = width >= 650 && width <= 950;
    final isMobile = width < 650;

    final mainContent = Column(
      children: [
        // Top Search & Category Filter Header
        Container(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input + Scanner + Grid Toggle
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search'.tr(),
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<InventoryBloc>().add(SearchInventory(''));
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {});
                        context.read<InventoryBloc>().add(SearchInventory(val));
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      padding: EdgeInsets.all(12.r),
                    ),
                    icon: Icon(
                      _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 20.r,
                    ),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    tooltip: _isGridView ? 'view_list'.tr() : 'grid_view'.tr(),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.88),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _triggerBarcodeScanner(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'barcode'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Category Pills
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, invState) {
                  List<String> categories = ['all'];
                  if (invState is InventoryLoaded) {
                    final cats = invState.allProducts
                        .map((p) => p.category.trim())
                        .where((c) => c.isNotEmpty)
                        .toSet()
                        .toList();
                    cats.sort();
                    categories.addAll(cats);
                  }

                  return SizedBox(
                    height: 34.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 6.w),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory == cat;
                        final label = cat == 'all' ? (context.locale.languageCode == 'ar' ? 'الكل' : 'All') : cat;

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          showCheckmark: false,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5.sp,
                          ),
                          backgroundColor: isDark
                              ? const Color(0xFF131D31)
                              : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Product Catalog (Grid / List)
        Expanded(
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, invState) {
              if (invState is InventoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (invState is InventoryLoaded) {
                var products = invState.filteredProducts.where((p) => p.isActive).toList();
                if (_selectedCategory != 'all') {
                  products = products.where((p) => p.category.trim() == _selectedCategory).toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48.r,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'no_data'.tr(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: EdgeInsets.all(12.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 2),
                      childAspectRatio: 0.76,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
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
        final totalItemsCount = state.cartItems.fold<int>(0, (sum, item) => sum + item.qty);
        final isArabic = context.locale.languageCode == 'ar';
        final currencySymbol = isArabic ? 'ج.م' : 'EGP';

        Widget bodyContent;
        if (isDesktop) {
          bodyContent = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: mainContent),
              Container(
                width: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              const Expanded(flex: 3, child: CartWidget()),
            ],
          );
        } else if (isTablet) {
          bodyContent = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6, child: mainContent),
              Container(
                width: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              const Expanded(flex: 4, child: CartWidget()),
            ],
          );
        } else {
          bodyContent = Stack(
            children: [
              Column(
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
              if (isMobile && _activeTab == 0 && state.cartItems.isNotEmpty)
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(16.r),
                    color: theme.colorScheme.primary,
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 1),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Badge(
                              label: Text('$totalItemsCount'),
                              backgroundColor: Colors.white,
                              textColor: theme.colorScheme.primary,
                              child: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${'cart'.tr()} ($totalItemsCount)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${state.total.toStringAsFixed(2)} $currencySymbol',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isArabic ? 'عرض السلة ←' : 'View Cart →',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return ResponsiveLayout(
          title: 'pos'.tr(),
          child: bodyContent,
        );
      },
    );
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    } else if (path.startsWith('data:image/')) {
      try {
        final base64String = path.split(',').last;
        final bytes = base64.decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.red)),
        );
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.red));
      }
    } else {
      if (kIsWeb) {
        return const Center(child: Icon(Icons.image, color: Colors.grey));
      }
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    }
  }

  Widget _buildProductPlaceholder(String name, ThemeData theme) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.6),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductEntity product,
    ThemeData theme,
  ) {
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = isArabic ? 'ج.م' : 'EGP';
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.isOutOfStock;

    Color badgeColor = const Color(0xFF10B981);
    String badgeText = '${'stock'.tr()}: ${product.stock}';

    if (isOutOfStock) {
      badgeColor = const Color(0xFFEF4444);
      badgeText = 'out_of_stock'.tr();
    } else if (isLowStock) {
      badgeColor = const Color(0xFFF59E0B);
      badgeText = '${'low_stock'.tr()} (${product.stock})';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                context.read<POSBloc>().add(POSAddProduct(product));
              },
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image container
              Container(
                height: 76.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4.h),

              // Category & Brand
              Text(
                '${product.brand} • ${product.category}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),

              // Price & Stock Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${product.priceFor('retail').toStringAsFixed(2)} $currencySymbol',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5.sp,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListTile(
    BuildContext context,
    ProductEntity product,
    ThemeData theme,
  ) {
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = isArabic ? 'ج.م' : 'EGP';
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.isOutOfStock;

    Color badgeColor = const Color(0xFF10B981);
    String badgeText = '${'stock'.tr()}: ${product.stock}';

    if (isOutOfStock) {
      badgeColor = const Color(0xFFEF4444);
      badgeText = 'out_of_stock'.tr();
    } else if (isLowStock) {
      badgeColor = const Color(0xFFF59E0B);
      badgeText = '${'low_stock'.tr()} (${product.stock})';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 6.h),
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                context.read<POSBloc>().add(POSAddProduct(product));
              },
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Row(
            children: [
              Container(
                height: 52.r,
                width: 52.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? _buildProductImage(product.imagePath!)
                    : _buildProductPlaceholder(product.name, theme),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${product.brand} • ${product.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Text(
                          '${product.priceFor('retail').toStringAsFixed(2)} $currencySymbol',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.sp,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: isOutOfStock ? Colors.grey : theme.colorScheme.primary,
                  size: 24.r,
                ),
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
