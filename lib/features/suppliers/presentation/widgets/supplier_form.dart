import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';

class SupplierForm extends StatefulWidget {
  final SupplierEntity? supplier;

  const SupplierForm({super.key, this.supplier});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _totalOrdersController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      final s = widget.supplier!;
      _nameController.text = s.name;
      _phoneController.text = s.phone;
      _companyController.text = s.company;
      _totalOrdersController.text = s.totalOrders.toStringAsFixed(2);
      _balanceController.text = s.balance.toStringAsFixed(2);
    } else {
      _totalOrdersController.text = '0.00';
      _balanceController.text = '0.00';
    }
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
                  widget.supplier == null ? 'add_supplier'.tr() : 'edit_supplier'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'supplier_name'.tr(), border: const OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'phone'.tr(), border: const OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: 'company_name'.tr(), border: const OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _totalOrdersController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'total_orders'.tr(), border: const OutlineInputBorder()),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'opening_balance'.tr() + ' (Remaining)', border: const OutlineInputBorder()),
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
                          final s = SupplierEntity(
                            id: widget.supplier?.id ?? '',
                            name: _nameController.text,
                            phone: _phoneController.text,
                            company: _companyController.text,
                            totalOrders: double.tryParse(_totalOrdersController.text) ?? 0.0,
                            balance: double.tryParse(_balanceController.text) ?? 0.0,
                          );
  
                          if (widget.supplier == null) {
                            context.read<SupplierBloc>().add(AddSupplierEvent(s));
                          } else {
                            context.read<SupplierBloc>().add(UpdateSupplierEvent(s));
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
