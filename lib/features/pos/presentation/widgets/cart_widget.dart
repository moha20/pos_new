import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../../services/print_service.dart';
import '../../../../core/di/di.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final user = context.read<AuthBloc>().currentUser;

    // Currency Formatter
    final currencySymbol = 'currency_symbol'.tr();
    String formatCurrency(double val) => '${val.toStringAsFixed(2)} $currencySymbol';

    return BlocListener<POSBloc, POSState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == POSStatus.checkoutSuccess && state.lastCompletedSale != null) {
          // 1. Show Success Message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'تم إتمام عملية البيع وحفظ الفاتورة بنجاح!'
                    : 'Sale completed and invoice saved successfully!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // 2. Open PDF Print Preview
          final printService = Gravity.find<PrintService>();
          printService.printInvoice(
            context,
            state.lastCompletedSale!,
            'Al Mohands Electrical Tools / المهندس للأدوات الكهربائية',
            context.locale.languageCode,
            customer: state.selectedCustomer,
          );

          // 3. Reload Customers
          context.read<CustomerBloc>().add(LoadCustomers());

          // 4. Clear Cart
          context.read<POSBloc>().add(POSClearCart());
        } else if (state.status == POSStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<POSBloc, POSState>(
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
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (state.cartItems.isNotEmpty)
                      Chip(
                        label: Text(
                          _getTierBadgeText(state.selectedCustomer?.priceLevel ?? 'retail', isArabic),
                          style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                // Customer Selector
                BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, custState) {
                    List<CustomerEntity> customers = [];
                    if (custState is CustomerLoaded) {
                      customers = custState.allCustomers;
                    }
                    return DropdownButtonFormField<CustomerEntity?>(
                      value: state.selectedCustomer == null 
                          ? null 
                          : customers.firstWhere((c) => c.id == state.selectedCustomer!.id, orElse: () => state.selectedCustomer!),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                      dropdownColor: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      decoration: InputDecoration(
                        labelText: 'customer_name'.tr(),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem<CustomerEntity?>(
                          value: null,
                          child: Text('cash_customer'.tr()),
                        ),
                        ...customers.map((c) => DropdownMenuItem<CustomerEntity?>(
                              value: c,
                              child: Text('${c.name} (${_getTierBadgeText(c.priceLevel, isArabic)})'),
                            )),
                      ],
                      onChanged: (cust) {
                        context.read<POSBloc>().add(POSSelectCustomer(cust));
                      },
                    );
                  },
                ),
                SizedBox(height: 12.h),
                
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
                                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () {
                                          context.read<POSBloc>().add(POSRemoveProduct(item.product.id));
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Pricing Tier Selector
                                      Row(
                                        children: [
                                          Text('${'price_tier'.tr()}: ', style: TextStyle(fontSize: 10.sp)),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.05),
                                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: item.product.prices.any((p) => p.level == item.priceLevel)
                                                    ? item.priceLevel
                                                    : (item.product.prices.isNotEmpty ? item.product.prices.first.level : 'retail'),
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  size: 16.sp,
                                                  color: theme.colorScheme.primary,
                                                ),
                                                dropdownColor: theme.cardColor,
                                                borderRadius: BorderRadius.circular(12.r),
                                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                                items: item.product.prices.map((pt) {
                                                  String label = pt.level;
                                                  if (pt.level == 'retail') label = 'price_retail'.tr();
                                                  else if (pt.level == 'salesman') label = 'price_salesman'.tr();
                                                  else if (pt.level == 'company') label = 'price_company'.tr();
                                                  else if (pt.level == 'wholesale') label = 'price_wholesale'.tr();
                                                  return DropdownMenuItem<String>(
                                                    value: pt.level,
                                                    child: Text(label, style: TextStyle(fontSize: 11.sp)),
                                                  );
                                                }).toList(),
                                                onChanged: (newLevel) {
                                                  if (newLevel != null) {
                                                    context.read<POSBloc>().add(POSUpdateItemPriceLevel(item.product.id, newLevel));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatCurrency(item.totalPrice),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                  // Quantity adjusts
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: () {
                                          context.read<POSBloc>().add(POSUpdateQty(item.product.id, item.qty - 1));
                                        },
                                      ),
                                      Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: () {
                                          context.read<POSBloc>().add(POSUpdateQty(item.product.id, item.qty + 1));
                                        },
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () => _showEditPriceDialog(context, item),
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '@ ${formatCurrency(item.unitPrice)}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 11.sp,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                      Text('tax'.tr() + ' (${state.taxRate}%)'),
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
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      Text(
                        formatCurrency(state.total),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                
                // Checkout Buttons
                ElevatedButton(
                  onPressed: state.cartItems.isEmpty
                      ? null
                      : () => _showCheckoutDialog(context, state, user?.name ?? 'cashier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('checkout'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    ),
   );
  }

  String _getTierBadgeText(String level, bool isArabic) {
    switch (level) {
      case 'retail':
        return 'tier_retail'.tr();
      case 'salesman':
        return 'tier_salesman'.tr();
      case 'company':
        return 'tier_company'.tr();
      case 'wholesale':
        return 'tier_wholesale'.tr();
      default:
        return level;
    }
  }

  void _showDiscountDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: context.read<POSBloc>().state.discount.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('discount'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
                context.read<POSBloc>().add(POSSetDiscount(val));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditPriceDialog(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final controller = TextEditingController(text: item.unitPrice.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            isArabic ? 'تعديل سعر الوحدة (مؤقت)' : 'Edit Unit Price (Temporary)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isArabic 
                    ? 'هذا التعديل يسري فقط على هذه العملية ولا يغير السعر الأصلي للمنتج في المخزن.'
                    : 'This price update is temporary for this sale and does not modify the persistent product retail price.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.edit),
                  labelText: isArabic ? 'السعر' : 'Price',
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
                if (val > 0) {
                  context.read<POSBloc>().add(POSUpdateItemPrice(item.product.id, val));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, POSState state, String cashierName) {
    final theme = Theme.of(context);
    String paymentMethod = 'cash';
    final noteController = TextEditingController();
    
    // Amount Paid controller
    final paidController = TextEditingController(text: state.total.toStringAsFixed(2));
    final hasCustomer = state.selectedCustomer != null;

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final total = state.total;
            final paid = double.tryParse(paidController.text) ?? 0.0;
            final remaining = (total - paid).clamp(0.0, total);

            return AlertDialog(
              title: Text('checkout'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${'total'.tr()}: ${total.toStringAsFixed(2)} EGP',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    
                    // Amount Paid Field
                    TextFormField(
                      controller: paidController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: hasCustomer, // Only edit if customer is selected
                      decoration: InputDecoration(
                        labelText: 'amount_paid'.tr(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                        helperText: !hasCustomer 
                            ? ('cash_customer_must_pay_full'.tr()) 
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 12.h),
  
                    // Remaining / Unpaid balance
                    if (hasCustomer) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: remaining > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'amount_remaining'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: remaining > 0 ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              '${remaining.toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: remaining > 0 ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
  
                    Text('payment_method'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                      dropdownColor: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      items: [
                        DropdownMenuItem(value: 'cash', child: Text('cash'.tr())),
                        DropdownMenuItem(value: 'card', child: Text('card'.tr())),
                        DropdownMenuItem(value: 'wallet', child: Text('wallet'.tr())),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => paymentMethod = val);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'expense_description'.tr() + ' / Note',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final double finalPaid = double.tryParse(paidController.text) ?? total;
                    if (finalPaid < 0 || (!hasCustomer && finalPaid != total)) {
                      return; // Simple validation check
                    }
                    final double finalRemaining = (total - finalPaid).clamp(0.0, total);
  
                    // Trigger Checkout with paid and remaining amounts
                    context.read<POSBloc>().add(
                          POSCheckout(
                            paymentMethod,
                            cashierName,
                            noteController.text,
                            finalPaid,
                            finalRemaining,
                          ),
                        );
                    Navigator.pop(dlgContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
