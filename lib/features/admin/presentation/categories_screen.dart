// categories_screen.dart
import 'package:flutter/material.dart';
import 'package:job_portal_app/features/auth/provider/category_provider.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoadingMore = false;
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCategories();
    }
  }

  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories(refresh: true);
  }

  Future<void> _loadMoreCategories() async {
    if (_isLoadingMore) return;
    
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.hasMore) {
      setState(() => _isLoadingMore = true);
      await categoryProvider.loadCategories();
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories(refresh: true);
  }

  void _showCategoryDialog({Category? category}) {
    if (category != null) {
      _editingCategory = category;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
    } else {
      _editingCategory = null;
      _nameController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingCategory == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    child: Text(_editingCategory == null ? 'Add' : 'Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name is required'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    if (_editingCategory == null) {
      // Create new category
      final newCategory = Category(
        id: 0, // Will be assigned by backend
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        jobCount: 0,
      );
      
      await categoryProvider.createCategory(newCategory);
    } else {
      // Update existing category
      final updatedCategory = _editingCategory!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      
      await categoryProvider.updateCategory(_editingCategory!.id, updatedCategory);
    }

    Navigator.pop(context);
    _refreshCategories();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingCategory == null
              ? 'Category added successfully'
              : 'Category updated successfully',
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final categoryProvider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );
              await categoryProvider.deleteCategory(category.id);
              _refreshCategories();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category deleted successfully'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Categories List
          Expanded(
            child: _buildCategoriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<CategoryProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.categories.length} total categories',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _refreshCategories();
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Implement search
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.loading && provider.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCategories,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Color(0xFF94A3B8)),
                SizedBox(height: 16),
                Text(
                  'No categories found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add a new category',
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshCategories,
          color: const Color(0xFF3B82F6),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.categories.length) {
                return _buildLoadingIndicator();
              }
              return _buildCategoryCard(provider.categories[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Show category details or edit
          _showCategoryDialog(category: category);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Job Count
              if (category.jobCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${category.jobCount} jobs',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCategoryDialog(category: category);
                  } else if (value == 'delete') {
                    _confirmDelete(category);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      ),
    );
  }
}

// Extension method for Category copyWith
extension CategoryCopyWith on Category {
  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? jobCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      jobCount: jobCount ?? this.jobCount,
    );
  }
}