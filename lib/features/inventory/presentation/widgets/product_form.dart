import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/inventory_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../services/barcode_service.dart';
import '../../../../core/di/di.dart';

class ProductForm extends StatefulWidget {
  final ProductEntity? product;
  final String? initialBarcode;

  const ProductForm({super.key, this.product, this.initialBarcode});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _costPriceController = TextEditingController(text: '0.0');
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _imagePathController = TextEditingController();
  bool _isActive = true;

  List<PriceInputRow> _priceRows = [];

  final _barcodeFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _unitFocusNode = FocusNode();

  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _barcodeController.text = p.barcode;
      _categoryController.text = p.category;
      _brandController.text = p.brand;
      _costPriceController.text = p.costPrice.toString();
      _stockController.text = p.stock.toString();
      _minStockController.text = p.minStock.toString();
      _unitController.text = p.unit;
      _isActive = p.isActive;
      if (p.imagePath != null) {
        _imagePathController.text = p.imagePath!;
      }

      // Map prices
      _priceRows = p.prices.map((pt) {
        return PriceInputRow(
          nameController: TextEditingController(text: pt.level),
          priceController: TextEditingController(text: pt.price.toString()),
          nameFocus: FocusNode(),
          priceFocus: FocusNode(),
        );
      }).toList();
    } else {
      if (widget.initialBarcode != null) {
        _barcodeController.text = widget.initialBarcode!;
      }
      _priceRows = [
        PriceInputRow(
          nameController: TextEditingController(text: 'price_retail'.tr()),
          priceController: TextEditingController(),
          nameFocus: FocusNode(),
          priceFocus: FocusNode(),
        )
      ];
    }
  }

  @override
  void dispose() {
    _barcodeFocusNode.dispose();
    _nameFocusNode.dispose();
    _unitFocusNode.dispose();
    for (final row in _priceRows) {
      row.dispose();
    }
    super.dispose();
  }

  // Real-time pricing validation against cost price
  void _validatePricingRelations() {
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    if (cost <= 0) {
      setState(() {
        _warningMessage = null;
      });
      return;
    }

    bool isBelowCost = false;
    for (final row in _priceRows) {
      final price = double.tryParse(row.priceController.text) ?? 0.0;
      if (price < cost) {
        isBelowCost = true;
        break;
      }
    }

    setState(() {
      _warningMessage = isBelowCost ? 'below_cost_warn'.tr() : null;
    });
  }

  Widget _buildPreviewImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthBloc>().currentUser;
    final isCashier = user?.isCashier ?? true;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 600.w,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: EdgeInsets.all(24.0.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              Text(
                widget.product == null ? 'add_product'.tr() : 'edit_product'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              SizedBox(height: 16.h),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image input & preview
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imagePathController,
                              decoration: InputDecoration(
                                labelText: 'image_path_url'.tr(),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _imagePathController.clear();
                                    setState(() {});
                                  },
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              onChanged: (val) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _imagePathController.text.isNotEmpty
                                ? _buildPreviewImage(_imagePathController.text)
                                : const Center(child: Icon(Icons.image, size: 28, color: Colors.grey)),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Basic info fields
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        autofocus: widget.product == null && widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_unitFocusNode),
                        decoration: InputDecoration(labelText: 'product_name'.tr(), border: const OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _barcodeController,
                              focusNode: _barcodeFocusNode,
                              autofocus: widget.product == null && (widget.initialBarcode == null || widget.initialBarcode!.isEmpty),
                              decoration: InputDecoration(
                                labelText: 'barcode'.tr(), 
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  onPressed: () async {
                                    final barcodeService = Gravity.find<BarcodeService>();
                                    final code = await barcodeService.scanBarcode(context);
                                    if (code != null && code.isNotEmpty) {
                                      _barcodeController.text = code;
                                      setState(() {});
                                    }
                                  },
                                  tooltip: 'barcode'.tr(),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_nameFocusNode);
                              },
                              validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              focusNode: _unitFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(labelText: 'unit'.tr(), border: const OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(labelText: 'category'.tr(), border: const OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(labelText: 'brand'.tr(), border: const OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'no_data'.tr() : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(labelText: 'stock'.tr(), border: const OutlineInputBorder()),
                              validator: (v) => v == null || int.tryParse(v) == null ? 'no_data'.tr() : null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                if (isCashier && _priceRows.isNotEmpty) {
                                  _priceRows.first.nameFocus.requestFocus();
                                } else {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: InputDecoration(labelText: 'low_stock'.tr(), border: const OutlineInputBorder()),
                              validator: (v) => v == null || int.tryParse(v) == null ? 'no_data'.tr() : null,
                            ),
                          ),
                          if (!isCashier) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextFormField(
                                controller: _costPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  if (_priceRows.isNotEmpty) {
                                    _priceRows.first.nameFocus.requestFocus();
                                  } else {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                                decoration: InputDecoration(labelText: 'cost_price'.tr(), border: const OutlineInputBorder()),
                                onChanged: (_) => _validatePricingRelations(),
                                validator: (v) => v == null || double.tryParse(v) == null ? 'no_data'.tr() : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 20.h),
                      
                      // Price tiers header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'price_tiers'.tr()} / Prices',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _priceRows.add(PriceInputRow(
                                  nameController: TextEditingController(),
                                  priceController: TextEditingController(),
                                  nameFocus: FocusNode(),
                                  priceFocus: FocusNode(),
                                ));
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: Text('add_price'.tr() + ' / Add Price'),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _priceRows.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final row = _priceRows[index];
                          return Row(
                            children: [
                              // Price Name Field
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: row.nameController,
                                  focusNode: row.nameFocus,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => row.priceFocus.requestFocus(),
                                  decoration: InputDecoration(
                                    labelText: '${'price_name'.tr()} / Price Name',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'no_data'.tr() : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Price Value Field
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: row.priceController,
                                  focusNode: row.priceFocus,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    if (index < _priceRows.length - 1) {
                                      _priceRows[index + 1].nameFocus.requestFocus();
                                    } else {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: '${'price'.tr()} / Price',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (_) => _validatePricingRelations(),
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'no_data'.tr() : null,
                                ),
                              ),
                              // Delete Button
                              if (_priceRows.length > 1) ...[
                                SizedBox(width: 4.w),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      final removed = _priceRows.removeAt(index);
                                      removed.dispose();
                                    });
                                    _validatePricingRelations();
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      
                      // Warn banner
                      if (_warningMessage != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Text(
                            _warningMessage!,
                            style: TextStyle(color: Colors.amber, fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 12.h),
                      SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              SizedBox(height: 16.h),
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
                        final p = ProductEntity(
                          id: widget.product?.id ?? '',
                          name: _nameController.text,
                          barcode: _barcodeController.text,
                          category: _categoryController.text,
                          brand: _brandController.text,
                          costPrice: double.parse(_costPriceController.text),
                          stock: int.parse(_stockController.text),
                          minStock: int.parse(_minStockController.text),
                          unit: _unitController.text,
                          isActive: _isActive,
                          imagePath: _imagePathController.text.isNotEmpty ? _imagePathController.text : null,
                          prices: _priceRows.map((row) {
                            final name = row.nameController.text.trim();
                            final price = double.tryParse(row.priceController.text) ?? 0.0;
                            return PriceTierEntity(
                              level: name,
                              labelAr: name,
                              labelEn: name,
                              price: price,
                            );
                          }).toList(),
                        );

                        if (widget.product == null) {
                          context.read<InventoryBloc>().add(AddProductEvent(p));
                        } else {
                          context.read<InventoryBloc>().add(UpdateProductEvent(p));
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
    );
  }
}

class PriceInputRow {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final FocusNode nameFocus;
  final FocusNode priceFocus;

  PriceInputRow({
    required this.nameController,
    required this.priceController,
    required this.nameFocus,
    required this.priceFocus,
  });

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    nameFocus.dispose();
    priceFocus.dispose();
  }
}
