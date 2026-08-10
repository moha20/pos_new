import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/balance_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/di/di.dart';

class PayBalanceDialog extends StatefulWidget {
  final String type; // 'customer' | 'supplier'
  final String targetId;
  final String targetName;
  final double currentBalance;

  const PayBalanceDialog({
    super.key,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.currentBalance,
  });

  @override
  State<PayBalanceDialog> createState() => _PayBalanceDialogState();
}

class _PayBalanceDialogState extends State<PayBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.currentBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    final currencySymbol = 'currency_symbol'.tr();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 450.w,
        padding: EdgeInsets.all(24.0.r),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: theme.colorScheme.primary,
                      size: 24.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'pay_balance'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Target info card
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.type == 'customer'
                                ? 'customer_name'.tr()
                                : 'supplier_name'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            widget.targetName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'remaining'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            '${widget.currentBalance.toStringAsFixed(2)} $currencySymbol',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'payment_amount'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'no_data'.tr();
                    final val = double.tryParse(v);
                    if (val == null || val <= 0) {
                      return 'price_must_be_greater_zero'.tr();
                    }
                    if (val > widget.currentBalance) {
                      return 'amount_exceeds_balance'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),

                // Quick amount buttons
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _quickAmountChip(
                      context,
                      isArabic ? 'الكل' : 'Full',
                      widget.currentBalance,
                    ),
                    if (widget.currentBalance > 100)
                      _quickAmountChip(
                        context,
                        isArabic ? 'نصف' : 'Half',
                        widget.currentBalance / 2,
                      ),
                    if (widget.currentBalance > 500)
                      _quickAmountChip(context, '500', 500),
                    if (widget.currentBalance > 1000)
                      _quickAmountChip(context, '1000', 1000),
                  ],
                ),
                SizedBox(height: 12.h),

                // Payment method
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  dropdownColor: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
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
                    if (val != null) setState(() => _paymentMethod = val);
                  },
                  decoration: InputDecoration(
                    labelText: 'payment_method'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Note field
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'notes'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.note_outlined),
                  ),
                ),
                SizedBox(height: 24.h),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr()),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        'confirm'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickAmountChip(BuildContext context, String label, double amount) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(2);
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = Gravity.find<AuthBloc>().currentUser;
      final payment = PaymentEntity(
        id: '',
        type: widget.type,
        targetId: widget.targetId,
        targetName: widget.targetName,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        paymentMethod: _paymentMethod,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
        createdBy: user?.username ?? 'system',
      );

      context.read<BalanceCubit>().addPayment(payment);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'payment_recorded'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    }
  }
}
