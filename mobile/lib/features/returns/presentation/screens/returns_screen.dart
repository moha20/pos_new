import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/returns_cubit.dart';
import '../../../../features/inventory/domain/entities/product_entity.dart';
import '../../../../features/customers/domain/entities/customer_entity.dart';
import '../../../../features/suppliers/domain/entities/supplier_entity.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../widgets/responsive_layout.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReturnsCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ResponsiveLayout(
        title: 'returns'.tr(),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3.h,
                    ),
                  ),
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.assignment_return),
                    text: 'sales_returns'.tr(),
                  ),
                  Tab(
                    icon: const Icon(Icons.keyboard_return),
                    text: 'purchase_returns'.tr(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: tabController,
                    builder: (context, child) {
                      return IndexedStack(
                        index: tabController.index,
                        children: const [
                          SalesReturnTab(),
                          PurchaseReturnTab(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SALES RETURN TAB =================
class SalesReturnTab extends StatefulWidget {
  const SalesReturnTab({super.key});

  @override
  State<SalesReturnTab> createState() => _SalesReturnTabState();
}

class _SalesReturnTabState extends State<SalesReturnTab> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  CustomerEntity? _selectedCustomer;
  ProductEntity? _selectedProduct;
  bool _isRefundCash = false;

  final _customerSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _customerSearchController.dispose();
    _productSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedCustomer = null;
      _selectedProduct = null;
      _isRefundCash = false;
      _qtyController.clear();
      _priceController.clear();
      _noteController.clear();
      _customerSearchController.clear();
      _productSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ReturnsCubit, ReturnsState>(
      listener: (context, state) {
        if (state is ReturnsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        } else if (state is ReturnsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ReturnsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReturnsLoaded) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(24.0.r),
              child: Form(
              key: _formKey,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.0.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'sales_returns'.tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Divider(height: 32),

                          // Customer Autocomplete Search
                          Autocomplete<CustomerEntity>(
                            displayStringForOption: (CustomerEntity option) =>
                                '${option.name} (${option.phone})',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return state.customers.where((CustomerEntity option) {
                                return option.name
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()) ||
                                    option.phone.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (CustomerEntity selection) {
                              setState(() {
                                _selectedCustomer = selection;
                                if (_selectedProduct != null) {
                                  _priceController.text = _selectedProduct!
                                      .priceFor(selection.priceLevel)
                                      .toString();
                                }
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _customerSearchController.text = controller.text;
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'select_customer'.tr(),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (_selectedCustomer == null) {
                                    return 'select_customer'.tr();
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Product Autocomplete Search
                          Autocomplete<ProductEntity>(
                            displayStringForOption: (ProductEntity option) =>
                                '${option.name} (${option.barcode})',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return state.products.where((ProductEntity option) {
                                return option.name
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()) ||
                                    option.barcode.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (ProductEntity selection) {
                              setState(() {
                                _selectedProduct = selection;
                                if (_selectedCustomer != null) {
                                  _priceController.text = selection
                                      .priceFor(_selectedCustomer!.priceLevel)
                                      .toString();
                                } else {
                                  _priceController.text = selection.costPrice.toString();
                                }
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _productSearchController.text = controller.text;
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'select_product'.tr(),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.shopping_bag),
                                ),
                                validator: (value) {
                                  if (_selectedProduct == null) {
                                    return 'select_product'.tr();
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Return Qty and Return Price in a Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'return_qty'.tr(),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.numbers),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'required'.tr();
                                    }
                                    final val = int.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return 'qty_must_be_greater_zero'.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'return_price'.tr(),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.attach_money),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'required'.tr();
                                    }
                                    final val = double.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return 'price_must_be_greater_zero'.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Refund Method Choice
                          Card(
                            color: theme.colorScheme.primary.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                    child: Text(
                                      'refund_method'.tr(),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: Text(
                                            'deduct_from_balance'.tr(),
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          value: false,
                                          groupValue: _isRefundCash,
                                          onChanged: (val) => setState(() => _isRefundCash = val!),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: Text(
                                            'refund_cash'.tr(),
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          value: true,
                                          groupValue: _isRefundCash,
                                          onChanged: (val) => setState(() => _isRefundCash = val!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Notes Field
                          TextFormField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'notes'.tr(),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.note),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Submit Button
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final authBloc = context.read<AuthBloc>();
                                final cashierUsername = authBloc.currentUser?.username ?? 'system';

                                context.read<ReturnsCubit>().processSalesReturn(
                                      productId: _selectedProduct!.id,
                                      customerId: _selectedCustomer!.id,
                                      qty: int.parse(_qtyController.text),
                                      price: double.parse(_priceController.text),
                                      isRefundCash: _isRefundCash,
                                      note: _noteController.text,
                                      cashierUsername: cashierUsername,
                                    );
                              }
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: Text(
                              'process_return'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ================= PURCHASE RETURN TAB =================
class PurchaseReturnTab extends StatefulWidget {
  const PurchaseReturnTab({super.key});

  @override
  State<PurchaseReturnTab> createState() => _PurchaseReturnTabState();
}

class _PurchaseReturnTabState extends State<PurchaseReturnTab> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  SupplierEntity? _selectedSupplier;
  ProductEntity? _selectedProduct;
  bool _isReceivedCash = false;

  final _supplierSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _supplierSearchController.dispose();
    _productSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _selectedSupplier = null;
      _selectedProduct = null;
      _isReceivedCash = false;
      _qtyController.clear();
      _priceController.clear();
      _noteController.clear();
      _supplierSearchController.clear();
      _productSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ReturnsCubit, ReturnsState>(
      listener: (context, state) {
        if (state is ReturnsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        } else if (state is ReturnsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ReturnsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReturnsLoaded) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(24.0.r),
              child: Form(
              key: _formKey,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.0.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'purchase_returns'.tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Divider(height: 32),

                          // Supplier Autocomplete Search
                          Autocomplete<SupplierEntity>(
                            displayStringForOption: (SupplierEntity option) =>
                                '${option.name} (${option.company})',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return state.suppliers.where((SupplierEntity option) {
                                return option.name
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()) ||
                                    option.company
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (SupplierEntity selection) {
                              setState(() {
                                _selectedSupplier = selection;
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _supplierSearchController.text = controller.text;
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'select_supplier'.tr(),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.local_shipping),
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                validator: (value) {
                                  if (_selectedSupplier == null) {
                                    return 'select_supplier'.tr();
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Product Autocomplete Search
                          Autocomplete<ProductEntity>(
                            displayStringForOption: (ProductEntity option) =>
                                '${option.name} (${option.barcode})',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return state.products.where((ProductEntity option) {
                                return option.name
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()) ||
                                    option.barcode.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (ProductEntity selection) {
                              setState(() {
                                _selectedProduct = selection;
                                _priceController.text = selection.costPrice.toString();
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _productSearchController.text = controller.text;
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'select_product'.tr(),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.shopping_bag),
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                validator: (value) {
                                  if (_selectedProduct == null) {
                                    return 'select_product'.tr();
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Return Qty and Return Price in a Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'return_qty'.tr(),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.numbers),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'required'.tr();
                                    }
                                    final val = int.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return 'qty_must_be_greater_zero'.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'return_price'.tr(),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.attach_money),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'required'.tr();
                                    }
                                    final val = double.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return 'price_must_be_greater_zero'.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Refund Method Choice
                          Card(
                            color: theme.colorScheme.primary.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                    child: Text(
                                      'refund_method'.tr(),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: Text(
                                            'deduct_from_balance'.tr(),
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          value: false,
                                          groupValue: _isReceivedCash,
                                          onChanged: (val) => setState(() => _isReceivedCash = val!),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: Text(
                                            'received_cash'.tr(),
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          value: true,
                                          groupValue: _isReceivedCash,
                                          onChanged: (val) => setState(() => _isReceivedCash = val!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Notes Field
                          TextFormField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'notes'.tr(),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.note),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Submit Button
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final authBloc = context.read<AuthBloc>();
                                final cashierUsername = authBloc.currentUser?.username ?? 'system';

                                context.read<ReturnsCubit>().processPurchaseReturn(
                                      productId: _selectedProduct!.id,
                                      supplierId: _selectedSupplier!.id,
                                      qty: int.parse(_qtyController.text),
                                      price: double.parse(_priceController.text),
                                      isReceivedCash: _isReceivedCash,
                                      note: _noteController.text,
                                      cashierUsername: cashierUsername,
                                    );
                              }
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: Text(
                              'process_return'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
