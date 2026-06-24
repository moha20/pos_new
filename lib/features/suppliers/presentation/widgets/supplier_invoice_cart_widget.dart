import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supplier_invoice_bloc.dart';
import '../bloc/supplier_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SupplierInvoiceCartWidget extends StatelessWidget {
  const SupplierInvoiceCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final user = context.read<AuthBloc>().currentUser;

    // Currency Formatter
    final currencySymbol = 'currency_symbol'.tr();
    String formatCurrency(double val) =>
        '${val.toStringAsFixed(2)} $currencySymbol';

    return BlocListener<SupplierInvoiceBloc, SupplierInvoiceState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SupplierInvoiceStatus.checkoutSuccess &&
            state.lastCompletedInvoice != null) {
          // 1. Show Success Message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'purchase_completed_successfully'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // 2. Reload Suppliers and Inventory
          context.read<SupplierBloc>().add(LoadSuppliers());
          context.read<InventoryBloc>().add(LoadInventory());

          // 3. Clear Cart
          context.read<SupplierInvoiceBloc>().add(SupplierInvoiceClearCart());
        } else if (state.status == SupplierInvoiceStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
        builder: (context, state) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cart Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'cart'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.cartItems.isNotEmpty)
                        Chip(
                          label: Text(
                            'supplier_invoice'.tr(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Supplier Selector
                  BlocBuilder<SupplierBloc, SupplierState>(
                    builder: (context, suppState) {
                      List<SupplierEntity> suppliers = [];
                      if (suppState is SupplierLoaded) {
                        suppliers = suppState.allSuppliers;
                      }
                      return DropdownButtonFormField<SupplierEntity?>(
                        isExpanded: true,
                        value: state.selectedSupplier == null
                            ? null
                            : suppliers.firstWhere(
                                (s) => s.id == state.selectedSupplier!.id,
                                orElse: () => state.selectedSupplier!,
                              ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        dropdownColor: theme.cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        decoration: InputDecoration(
                          labelText: 'supplier_name'.tr(),
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: theme.dividerColor.withOpacity(0.2),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<SupplierEntity?>(
                            value: null,
                            child: Text('select_supplier'.tr()),
                          ),
                          ...suppliers.map(
                            (s) => DropdownMenuItem<SupplierEntity?>(
                              value: s,
                              child: Text(
                                '${s.name} (${s.company})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (supp) {
                          context
                              .read<SupplierInvoiceBloc>()
                              .add(SupplierInvoiceSelectSupplier(supp));
                        },
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Supplier balance warning banner
                  if (state.selectedSupplier != null &&
                      state.selectedSupplier!.balance > 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${'remaining'.tr()}: ${state.selectedSupplier!.balance.toStringAsFixed(2)} $currencySymbol',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cart items list
                  Expanded(
                    child: state.cartItems.isEmpty
                        ? Center(child: Text('no_data'.tr()))
                        : ListView.builder(
                            itemCount: state.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = state.cartItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.sp,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<SupplierInvoiceBloc>()
                                                .add(
                                                  SupplierInvoiceRemoveProduct(
                                                      item.product.id),
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity adjusts
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<SupplierInvoiceBloc>()
                                                    .add(
                                                      SupplierInvoiceUpdateQty(
                                                        item.product.id,
                                                        item.qty - 1,
                                                      ),
                                                    );
                                              },
                                            ),
                                            Text(
                                              '${item.qty}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<SupplierInvoiceBloc>()
                                                    .add(
                                                      SupplierInvoiceUpdateQty(
                                                        item.product.id,
                                                        item.qty + 1,
                                                      ),
                                                    );
                                              },
                                            ),
                                          ],
                                        ),
                                        // Unit Purchase Price button
                                        InkWell(
                                          onTap: () =>
                                              _showEditCostPriceDialog(
                                                  context, item),
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 4.h,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '@ ${formatCurrency(item.unitCostPrice)}',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  Icons.edit_rounded,
                                                  size: 11.sp,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: isArabic
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        formatCurrency(item.totalPrice),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),

                  // Summaries
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('subtotal'.tr()),
                        Text(formatCurrency(state.subtotal)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('discount'.tr()),
                        InkWell(
                          onTap: () => _showDiscountDialog(context),
                          child: Text(
                            '-${formatCurrency(state.discount)} ✎',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${'tax'.tr()} (${state.taxRate % 1 == 0 ? state.taxRate.toInt() : state.taxRate}%)'),
                        Text(formatCurrency(state.taxAmount)),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'total'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          formatCurrency(state.total),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: state.cartItems.isEmpty ||
                            state.selectedSupplier == null
                        ? null
                        : () => _showCheckoutDialog(
                              context,
                              state,
                              user?.name ?? 'admin',
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'purchase_checkout'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: context.read<SupplierInvoiceBloc>().state.discount.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'discount'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: const Icon(Icons.money_off),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                context
                    .read<SupplierInvoiceBloc>()
                    .add(SupplierInvoiceSetDiscount(val));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'confirm'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCostPriceDialog(
      BuildContext context, SupplierInvoiceCartItem item) {
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: item.unitCostPrice.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'edit_purchase_price'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'edit_purchase_price_hint'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                  labelText: 'price'.tr(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                if (val >= 0) {
                  context.read<SupplierInvoiceBloc>().add(
                        SupplierInvoiceUpdateCostPrice(item.product.id, val),
                      );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'confirm'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(
    BuildContext context,
    SupplierInvoiceState state,
    String cashierName,
  ) {
    final theme = Theme.of(context);
    String paymentMethod = 'cash';
    final noteController = TextEditingController();

    // Amount Paid controller
    final paidController = TextEditingController(
      text: state.total.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final total = state.total;
            final paid = double.tryParse(paidController.text) ?? 0.0;
            final remaining = (total - paid).clamp(0.0, total);

            return AlertDialog(
              title: Text('purchase_checkout'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${'total'.tr()}: ${total.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Previous balance summary (when supplier has existing debt)
                    if (state.selectedSupplier != null &&
                        state.selectedSupplier!.balance > 0) ...[
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'remaining'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                                Text(
                                  '${state.selectedSupplier!.balance.toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'new_debt'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  '${remaining.toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total_after_sale'.tr(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '${(state.selectedSupplier!.balance + remaining).toStringAsFixed(2)} EGP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Amount Paid Field
                    TextFormField(
                      controller: paidController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'amount_paid'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Amount Remaining (debt to supplier)
                    Card(
                      elevation: 0,
                      color: remaining > 0
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: remaining > 0
                              ? Colors.red.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'amount_remaining'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: remaining > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                            Text(
                              '${remaining.toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: remaining > 0
                                    ? Colors.red.shade900
                                    : Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Payment Method
                    Text(
                      'payment_method'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      borderRadius: BorderRadius.circular(12.r),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        prefixIcon: const Icon(Icons.payment),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('cash'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'card',
                          child: Text('card'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'wallet',
                          child: Text('wallet'.tr()),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => paymentMethod = val);
                        }
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Notes
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'note'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final noteText = noteController.text.trim();
                    // Dispatch Checkout Event
                    context.read<SupplierInvoiceBloc>().add(
                          SupplierInvoiceCheckout(
                            paymentMethod,
                            cashierName,
                            noteText.isEmpty ? null : noteText,
                            paid,
                            remaining,
                          ),
                        );
                    // Dismiss dialog
                    Navigator.pop(dlgContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'confirm'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
