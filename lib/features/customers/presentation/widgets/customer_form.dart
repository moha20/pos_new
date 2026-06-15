import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';

class CustomerForm extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerForm({super.key, this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalPurchasesController = TextEditingController();
  final _balanceController = TextEditingController();
  final _customPriceLevelController = TextEditingController();
  String _priceLevel = 'retail';
  bool _isCustomPriceLevel = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      final c = widget.customer!;
      _nameController.text = c.name;
      _phoneController.text = c.phone;
      _addressController.text = c.address;
      _priceLevel = c.priceLevel;
      _totalPurchasesController.text = c.totalPurchases.toStringAsFixed(2);
      _balanceController.text = c.balance.toStringAsFixed(2);

      final standardTiers = ['retail', 'salesman', 'company', 'wholesale'];
      if (!standardTiers.contains(_priceLevel)) {
        _customPriceLevelController.text = _priceLevel;
      }
    } else {
      _totalPurchasesController.text = '0.00';
      _balanceController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _totalPurchasesController.dispose();
    _balanceController.dispose();
    _customPriceLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 500.w,
        padding: EdgeInsets.all(24.0.r),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.customer == null
                      ? 'add_customer'.tr()
                      : 'edit_customer'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'customer_name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'phone'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'address'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _totalPurchasesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'total_purchases'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${'opening_balance'.tr()} (Debt)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),

                // Price Level Selection
                Text(
                  'price_tier'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Builder(
                  builder: (context) {
                    final invState = context.read<InventoryBloc>().state;
                    final Set<String> customLevels = {};
                    if (invState is InventoryLoaded) {
                      for (final p in invState.allProducts) {
                        for (final pt in p.prices) {
                          customLevels.add(pt.level);
                        }
                      }
                    }

                    final List<String> dropdownLevels = [
                      'retail',
                      'salesman',
                      'company',
                      'wholesale',
                    ];
                    for (final lvl in customLevels) {
                      if (!dropdownLevels.any(
                        (d) => d.toLowerCase() == lvl.toLowerCase(),
                      )) {
                        dropdownLevels.add(lvl);
                      }
                    }

                    if (_priceLevel != 'other' &&
                        !dropdownLevels.contains(_priceLevel)) {
                      dropdownLevels.add(_priceLevel);
                    }

                    final dropdownValue = dropdownLevels.contains(_priceLevel)
                        ? _priceLevel
                        : 'other';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: dropdownValue,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                          items: [
                            ...dropdownLevels.map((lvl) {
                              String label = lvl;
                              if (lvl == 'retail') {
                                label = 'price_retail'.tr();
                              } else if (lvl == 'salesman')
                                label = 'price_salesman'.tr();
                              else if (lvl == 'company')
                                label = 'price_company'.tr();
                              else if (lvl == 'wholesale')
                                label = 'price_wholesale'.tr();
                              return DropdownMenuItem(
                                value: lvl,
                                child: Text(label),
                              );
                            }),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('other'.tr()),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _priceLevel = val;
                                _isCustomPriceLevel = (val == 'other');
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'price_tier'.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                        if (_isCustomPriceLevel) ...[
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _customPriceLevelController,
                            decoration: InputDecoration(
                              labelText:
                                  '${'custom_level'.tr()} / Custom Level Name',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                _isCustomPriceLevel &&
                                    (v == null || v.trim().isEmpty)
                                ? 'no_data'.tr()
                                : null,
                          ),
                        ],
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr()),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final c = CustomerEntity(
                            id: widget.customer?.id ?? '',
                            name: _nameController.text,
                            phone: _phoneController.text,
                            address: _addressController.text,
                            totalPurchases:
                                double.tryParse(
                                  _totalPurchasesController.text,
                                ) ??
                                0.0,
                            balance:
                                double.tryParse(_balanceController.text) ?? 0.0,
                            createdAt:
                                widget.customer?.createdAt ?? DateTime.now(),
                            priceLevel: _priceLevel == 'other'
                                ? _customPriceLevelController.text.trim()
                                : _priceLevel,
                          );

                          if (widget.customer == null) {
                            context.read<CustomerBloc>().add(
                              AddCustomerEvent(c),
                            );
                          } else {
                            context.read<CustomerBloc>().add(
                              UpdateCustomerEvent(c),
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('save'.tr()),
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
}
