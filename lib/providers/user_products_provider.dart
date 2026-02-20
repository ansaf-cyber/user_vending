import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user/models/categoy_model_app.dart';
import 'package:user/models/product_model.dart';

enum SortOption { none, nameAsc, nameDesc, priceAsc, priceDesc }

class UserProductsProvider extends ChangeNotifier {
  String _selectedCategory = 'All';
  SortOption _sortOption = SortOption.none;

  List<ProductModel> _products = [];
  List<CategoryModelApp> _categoriesList = [];
  List<dynamic> _categories = ['All'];

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  String get selectedCategory => _selectedCategory;
  SortOption get sortOption => _sortOption;
  List<ProductModel> get products => _products;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  void setSelectedCategory(dynamic category) {
    if (category is CategoryModelApp) {
      _selectedCategory = category.name;
    } else if (category is Map) {
      _selectedCategory = category['name'] ?? 'All';
    } else {
      _selectedCategory = category.toString();
    }
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Initial fetch of products for a specific machine
  Future<void> fetchProductsForMachine(
    String machineId, {
    String? ownerId,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _products = []; // Clear previous products
    _categories = ['All'];
    notifyListeners();

    try {
      if (machineId.isEmpty) {
        throw 'Machine ID is invalid';
      }

      if (ownerId != null && ownerId.isNotEmpty) {
        // Optionally fetch categories and global product data from owner if needed
        await _fetchCategories(ownerId);
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('machines')
          .doc(machineId)
          .collection('products')
          .get();

      final List<ProductModel> loadedProducts = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data['id'] == null) {
            data['id'] = doc.id;
          }

          final product = ProductModel.fromMap(data);

          // Only add valid products
          if (_isProductVisible(product)) {
            loadedProducts.add(product);
          }
        } catch (e) {
          log('Error parsing product ${doc.id}: $e');
        }
      }

      _products = loadedProducts;

      // Resolve categories (map categoryId to actual CategoryModel if available)
      if (_categoriesList.isNotEmpty) {
        _resolveProductCategories();
      }

      // Extract unique categories from loaded products
      _extractCategories();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error fetching machine products: $e');
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchCategories(String ownerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      _categoriesList = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['id'] == null) data['id'] = doc.id;
        return CategoryModelApp.fromMap(data);
      }).toList();
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  void _resolveProductCategories() {
    for (int i = 0; i < _products.length; i++) {
      final category = _resolveCategory(_products[i]);
      if (category != null) {
        _products[i] = _products[i].copyWith(category: category);
      }
    }
  }

  CategoryModelApp? _resolveCategory(ProductModel product) {
    if (product.categoryId != null && product.categoryId!.isNotEmpty) {
      return _categoriesList
          .where((c) => c.id == product.categoryId)
          .firstOrNull;
    }
    return product.category;
  }

  void _extractCategories() {
    final Map<String, dynamic> categoriesMap = {'All': 'All'};

    for (var product in _products) {
      if (_selectedCategory == 'All' ||
          _selectedCategory == _resolveCategory(product)?.name) {
        // Logic usually is: show all categories available in the list of products
        final category = _resolveCategory(product);
        if (category != null) {
          final categoryName = category.name;
          if (categoryName.isNotEmpty) {
            final parts = categoryName.split('/');
            final lastPart = parts.last.trim();
            categoriesMap[lastPart] = category;
          }
        }
      }
    }
    // Actually we want ALL categories present in the products list, regardless of selected category
    for (var product in _products) {
      final category = _resolveCategory(product);
      if (category != null) {
        final categoryName = category.name;
        if (categoryName.isNotEmpty) {
          final parts = categoryName.split('/');
          final lastPart = parts.last.trim();
          categoriesMap[lastPart] = category;
        }
      }
    }

    _categories = categoriesMap.values.toList();
    _categories.sort((a, b) {
      final nameA = a is CategoryModelApp ? a.name : a.toString();
      final nameB = b is CategoryModelApp ? b.name : b.toString();
      if (nameA == 'All') return -1;
      if (nameB == 'All') return 1;
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });
  }

  bool _isProductVisible(ProductModel p) {
    // Basic visibility check for user app
    if (p.stock <= 0) return false;

    // Check expiry
    if (p.expiryDate != null && p.expiryDate!.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  List<ProductModel> getDisplayProducts() {
    List<ProductModel> displayProducts = List.from(_products);

    // Apply category filter
    if (_selectedCategory != 'All') {
      displayProducts = displayProducts.where((p) {
        final category = _resolveCategory(p);
        final categoryName = category?.name;
        if (categoryName == null) return false;

        final parts = categoryName.split('/');
        final lastPart = parts.last.trim();
        return lastPart.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    }

    // Apply sorting
    _sortProducts(displayProducts);

    return displayProducts;
  }

  void _sortProducts(List<ProductModel> products) {
    switch (_sortOption) {
      case SortOption.nameAsc:
        products.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.nameDesc:
        products.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case SortOption.priceAsc:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.none:
        break;
    }
  }
}
