import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../widgets/product_form.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../widgets/responsive_layout.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthBloc>().currentUser;
    final isCashier = user?.isCashier ?? true;
    final isViewer = user?.isViewer ?? false;
    final canModify = !isViewer;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth <= 600;

    return ResponsiveLayout(
      title: 'inventory'.tr(),
      actions: [
        if (_selectedProductIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: isCompact
                ? Badge(
                    label: Text('${_selectedProductIds.length}'),
                    child: IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.red),
                      onPressed: () => _confirmDeleteSelected(context),
                      tooltip: 'delete'.tr(),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _confirmDeleteSelected(context),
                    icon: const Icon(Icons.delete_sweep, color: Colors.white),
                    label: Text('${'delete'.tr()} (${_selectedProductIds.length})', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        if (canModify)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8.0 : 16.0),
            child: isCompact
                ? IconButton(
                    icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 28),
                    onPressed: () {
                      final searchQuery = _searchController.text.trim();
                      showDialog(
                        context: context,
                        builder: (context) => ProductForm(
                          initialBarcode: searchQuery.isNotEmpty ? searchQuery : null,
                        ),
                      );
                    },
                    tooltip: 'add_product'.tr(),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      final searchQuery = _searchController.text.trim();
                      showDialog(
                        context: context,
                        builder: (context) => ProductForm(
                          initialBarcode: searchQuery.isNotEmpty ? searchQuery : null,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text('add_product'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
          )
      ],
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.0.r),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onChanged: (val) {
                context.read<InventoryBloc>().add(SearchInventory(val));
              },
            ),
          ),

          // Inventory Table
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is InventoryLoaded) {
                  final products = state.filteredProducts;
                  if (products.isEmpty) {
                    return Center(child: Text('no_data'.tr()));
                  }

                  return Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    notificationPredicate: (notification) =>
                        notification.metrics.axis == Axis.vertical,
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      notificationPredicate: (notification) =>
                          notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            showCheckboxColumn: true,
                            columns: [
                              DataColumn(label: Text('product_name'.tr())),
                              DataColumn(label: Text('barcode'.tr())),
                              DataColumn(label: Text('category'.tr())),
                              DataColumn(label: Text('stock'.tr())),
                              DataColumn(label: Text('price_retail'.tr())),
                              if (!isCashier) DataColumn(label: Text('cost_price'.tr())),
                              DataColumn(label: Text('settings'.tr())),
                            ],
                            rows: products.map((p) {
                              final isLowStock = p.isLowStock;
                              final isOutOfStock = p.isOutOfStock;
                              Color stockColor = Colors.green;
                              if (isOutOfStock) {
                                stockColor = Colors.red;
                              } else if (isLowStock) {
                                stockColor = Colors.orange;
                              }

                              return DataRow(
                                selected: _selectedProductIds.contains(p.id),
                                onSelectChanged: canModify
                                    ? (selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedProductIds.add(p.id);
                                          } else {
                                            _selectedProductIds.remove(p.id);
                                          }
                                        });
                                      }
                                    : null,
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 36.w,
                                          height: 36.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.r),
                                            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: p.imagePath != null && p.imagePath!.isNotEmpty
                                              ? (p.imagePath!.startsWith('http://') || p.imagePath!.startsWith('https://')
                                                  ? Image.network(
                                                      p.imagePath!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 18, color: Colors.red),
                                                    )
                                                  : (p.imagePath!.startsWith('data:image/')
                                                      ? Builder(builder: (context) {
                                                          try {
                                                            final base64String = p.imagePath!.split(',').last;
                                                            final bytes = base64.decode(base64String);
                                                            return Image.memory(
                                                              bytes,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 18, color: Colors.red),
                                                            );
                                                          } catch (_) {
                                                            return const Icon(Icons.broken_image, size: 18, color: Colors.red);
                                                          }
                                                        })
                                                      : (kIsWeb
                                                          ? const Icon(Icons.image, size: 18, color: Colors.grey)
                                                          : Image.file(
                                                              File(p.imagePath!),
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 18, color: Colors.red),
                                                            ))))
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        theme.colorScheme.primary.withOpacity(0.6),
                                                        theme.colorScheme.secondary.withOpacity(0.6),
                                                      ],
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                                  ),
                                                ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(p.name),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(p.barcode)),
                                  DataCell(Text(p.category)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: stockColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        '${p.stock} (${p.unit.split(' / ').first})',
                                        style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${p.priceFor('retail').toStringAsFixed(2)} EGP')),
                                  if (!isCashier) DataCell(Text('${p.costPrice.toStringAsFixed(2)} EGP')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: canModify
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => ProductForm(product: p),
                                                  );
                                                }
                                              : null, // disables for cashiers
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: canModify
                                              ? () => _confirmDelete(context, p.id)
                                              : null, // disables for cashiers
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (state is InventoryError) {
                  return Center(child: Text(state.message));
                }
                return Center(child: Text('no_data'.tr()));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text('confirm_delete'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<InventoryBloc>().add(DeleteProductEvent(id));
                setState(() {
                  _selectedProductIds.remove(id);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('delete'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text(
            context.locale.languageCode == 'ar'
                ? 'هل أنت متأكد من حذف ${_selectedProductIds.length} من المنتجات المحددة؟'
                : 'Are you sure you want to delete ${_selectedProductIds.length} selected product(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<InventoryBloc>().add(DeleteMultipleProductsEvent(_selectedProductIds.toList()));
                setState(() {
                  _selectedProductIds.clear();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('delete'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
