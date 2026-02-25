// features/job_seeker/presentation/search/job_search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/category_api.dart';
import 'package:job_portal_app/core/api/search_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class JobSearchScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const JobSearchScreen({super.key, this.initialCategory, this.initialQuery});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen>
    with SingleTickerProviderStateMixin {
  // ===================== CONTROLLERS =====================
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  Timer? _autocompleteDebounceTimer;

  // ===================== FILTERS =====================
  int? _selectedCategoryId;
  JobType? _selectedJobType;
  ExperienceLevel? _selectedExperienceLevel;
  RangeValues? _salaryRange;
  bool _remoteOnly = false;
  bool _showFilters = false;

  // ===================== SEARCH STATE =====================
  List<Job> _jobs = [];
  List<String> _autocompleteSuggestions = [];
  List<Category> _categories = [];
  List<String> _popularSkills = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isFetchingMore = false;
  bool _showSuggestions = false;
  String? _error;

  // ===================== PAGINATION =====================
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  int _totalResults = 0;

  // ===================== SALARY RANGE =====================
  static const double _minSalary = 0;
  static const double _maxSalary = 200000;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _initializeData();
    _setupListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _autocompleteDebounceTimer?.cancel();
    super.dispose();
  }

  // ===================== INITIALIZATION =====================
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Load categories and popular skills in parallel
      final results = await Future.wait([
        CategoryApi.getTopCategories(page: 0, size: 20),
        SearchApi.getPopularSkills(),
      ], eagerError: false);

      setState(() {
        _categories = (results[0] as Pagination<Category>).items;
        _popularSkills = results[1] as List<String>;
        _isLoading = false;
      });

      // If there's an initial category, set it
      if (widget.initialCategory != null) {
        final category = _categories.firstWhere(
          (c) => c.name == widget.initialCategory,
          orElse: () => _categories.first,
        );
        _selectedCategoryId = category.id;
      }

      // 🔥 FIX: Load initial jobs after categories are loaded
      // Always load jobs initially, even if search is empty
      _performSearch(refresh: true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _setupListeners() {
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _showSuggestions = true;
        _fetchAutocompleteSuggestions();
      } else {
        setState(() {
          _showSuggestions = false;
          _autocompleteSuggestions.clear();
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isFetchingMore) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _fetchAutocompleteSuggestions() async {
    if (_autocompleteDebounceTimer?.isActive ?? false) {
      _autocompleteDebounceTimer!.cancel();
    }

    _autocompleteDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () async {
        try {
          final suggestions = await SearchApi.autocompleteJobTitles(
            _searchController.text,
          );
          if (mounted) {
            setState(() {
              _autocompleteSuggestions = suggestions;
            });
          }
        } catch (e) {
          debugPrint('Autocomplete error: $e');
        }
      },
    );
  }

  Future<void> _performSearch({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMore = true;
        _jobs.clear();
        _isSearching = true;
        _error = null;
      });
    }

    if (!_hasMore || _isFetchingMore) return;

    final filter = JobSearchFilter(
      keyword: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
      location: _locationController.text.isNotEmpty
          ? _locationController.text
          : null,
      categoryId: _selectedCategoryId,
      jobType: _selectedJobType,
      experienceLevel: _selectedExperienceLevel,
      remote: _remoteOnly ? true : null,
      salaryRange: _salaryRange != null
          ? SalaryRange(min: _salaryRange!.start, max: _salaryRange!.end)
          : null,
      page: _currentPage,
      size: _pageSize,
    );

    try {
      final result = await SearchApi.searchJobs(filter);

      setState(() {
        if (refresh) {
          _jobs = result.items;
        } else {
          _jobs.addAll(result.items);
        }
        _totalResults = result.totalItems;
        _hasMore = _currentPage + 1 < result.totalPages;
        _currentPage++;
        _isSearching = false;
        _isFetchingMore = false;
        _showSuggestions = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSearching = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() => _isFetchingMore = true);
    await _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _selectedCategoryId = null;
      _selectedJobType = null;
      _selectedExperienceLevel = null;
      _salaryRange = null;
      _remoteOnly = false;
      _showFilters = false;
    });
    _performSearch(refresh: true);
  }

  void _applyFilters() {
    setState(() => _showFilters = false);
    _performSearch(refresh: true);
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _showSuggestions = false;
      _autocompleteSuggestions.clear();
    });
    _performSearch(refresh: true);
  }

  void _navigateToJobDetails(int jobId) {
    Navigator.pushNamed(context, RouteNames.jobDetails, arguments: jobId);
  }

  // ===================== UTILITY METHODS =====================
  String _formatSalary(Job job) {
    if (job.minSalary == null && job.maxSalary == null) {
      return 'Not specified';
    } else if (job.minSalary != null && job.maxSalary != null) {
      return '\$${_formatNumber(job.minSalary!)} - \$${_formatNumber(job.maxSalary!)} ${_getSalarySuffix(job.salaryType)}';
    } else if (job.minSalary != null) {
      return 'From \$${_formatNumber(job.minSalary!)} ${_getSalarySuffix(job.salaryType)}';
    } else {
      return 'Up to \$${_formatNumber(job.maxSalary!)} ${_getSalarySuffix(job.salaryType)}';
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  String _getSalarySuffix(SalaryType type) {
    switch (type) {
      case SalaryType.HOURLY:
        return '/hr';
      case SalaryType.DAILY:
        return '/day';
      case SalaryType.WEEKLY:
        return '/week';
      case SalaryType.MONTHLY:
        return '/mo';
      case SalaryType.YEARLY:
        return '/yr';
      default:
        return '';
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatExperienceLevel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.ENTRY:
        return 'Entry Level';
      case ExperienceLevel.MID:
        return 'Mid Level';
      case ExperienceLevel.SENIOR:
        return 'Senior Level';
      case ExperienceLevel.DIRECTOR:
        return 'Director';
      case ExperienceLevel.EXECUTIVE:
        return 'Executive';
    }
  }

  String _formatPostedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return difference.inMinutes <= 1
            ? 'Just now'
            : '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()}w ago';
    return DateFormat('MMM d').format(date);
  }

  Color _getJobTypeColor(JobType type) {
    switch (type) {
      case JobType.FULL_TIME:
        return Colors.blue;
      case JobType.PART_TIME:
        return Colors.orange;
      case JobType.CONTRACT:
        return Colors.purple;
      case JobType.REMOTE:
        return Colors.green;
      case JobType.INTERNSHIP:
        return Colors.teal;
      case JobType.FREELANCE:
        return Colors.amber;
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showSuggestions) {
          setState(() => _showSuggestions = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Search Jobs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                setState(() => _showFilters = !_showFilters);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar - Fixed height
            _buildSearchBar(),

            // Filter Panel - Scrollable when visible
            if (_showFilters)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _buildFilterPanel(),
              ),

            // Results Count - Fixed height when visible
            if (_jobs.isNotEmpty || _isSearching) _buildResultsHeader(),

            // Results or Suggestions - Takes remaining space
            Expanded(
              child: Stack(
                children: [
                  // Search Results
                  if (!_showSuggestions) _buildResultsList(),

                  // Autocomplete Suggestions
                  if (_showSuggestions && _autocompleteSuggestions.isNotEmpty)
                    _buildSuggestionsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Input
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: _searchFocusNode.hasFocus
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Job title, keywords, or company',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    onSubmitted: (_) {
                      _showSuggestions = false;
                      _performSearch(refresh: true);
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch(refresh: true);
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Quick Filters Row
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Location Filter
                  return Container(
                    width: 100,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Location',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.location_on, size: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 12),
                      onSubmitted: (_) => _performSearch(refresh: true),
                    ),
                  );
                } else if (index == 1) {
                  // Remote Chip
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(
                        'Remote',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: _remoteOnly,
                      onSelected: (selected) {
                        setState(() => _remoteOnly = selected);
                        _performSearch(refresh: true);
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                } else if (index == 2) {
                  // Entry Level Chip
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(
                        'Entry Level',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected:
                          _selectedExperienceLevel == ExperienceLevel.ENTRY,
                      onSelected: (selected) {
                        setState(() {
                          _selectedExperienceLevel = selected
                              ? ExperienceLevel.ENTRY
                              : null;
                        });
                        _performSearch(refresh: true);
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.purple.withOpacity(0.2),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                } else {
                  // Full Time Chip
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(
                        'Full Time',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: _selectedJobType == JobType.FULL_TIME,
                      onSelected: (selected) {
                        setState(() {
                          _selectedJobType = selected
                              ? JobType.FULL_TIME
                              : null;
                        });
                        _performSearch(refresh: true);
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.blue.withOpacity(0.2),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() => _showFilters = false);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: const Text(
                                'All',
                                style: TextStyle(fontSize: 12),
                              ),
                              selected: _selectedCategoryId == null,
                              onSelected: (_) {
                                setState(() => _selectedCategoryId = null);
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }
                        final category = _categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(
                              category.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected
                                    ? category.id
                                    : null;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Job Type Filter
                  const Text(
                    'Job Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: JobType.values.map((type) {
                      return FilterChip(
                        label: Text(
                          _formatJobType(type),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: _selectedJobType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedJobType = selected ? type : null;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: _getJobTypeColor(type).withOpacity(0.2),
                        checkmarkColor: _getJobTypeColor(type),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Experience Level Filter
                  const Text(
                    'Experience Level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ExperienceLevel.values.map((level) {
                      return FilterChip(
                        label: Text(
                          _formatExperienceLevel(level),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: _selectedExperienceLevel == level,
                        onSelected: (selected) {
                          setState(() {
                            _selectedExperienceLevel = selected ? level : null;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.purple.withOpacity(0.2),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Salary Range Filter
                  const Text(
                    'Salary Range',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  RangeSlider(
                    values:
                        _salaryRange ??
                        const RangeValues(_minSalary, _maxSalary),
                    min: _minSalary,
                    max: _maxSalary,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_formatNumber(_salaryRange?.start ?? 0)}',
                      '\$${_formatNumber(_salaryRange?.end ?? _maxSalary)}',
                    ),
                    onChanged: (values) {
                      setState(() => _salaryRange = values);
                    },
                    activeColor: AppColors.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_formatNumber(_salaryRange?.start ?? 0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '\$${_formatNumber(_salaryRange?.end ?? _maxSalary)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Remote Option
                  Row(
                    children: [
                      Checkbox(
                        value: _remoteOnly,
                        onChanged: (value) {
                          setState(() => _remoteOnly = value ?? false);
                        },
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 4),
                      const Text('Remote Only', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Fixed Footer with Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Apply', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _autocompleteSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _autocompleteSuggestions[index];
          return ListTile(
            leading: const Icon(
              Icons.search,
              color: Color(0xFF64748B),
              size: 18,
            ),
            title: Text(
              suggestion,
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
            ),
            dense: true,
            onTap: () => _selectSuggestion(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            _isSearching
                ? 'Searching...'
                : '$_totalResults ${_totalResults == 1 ? 'job' : 'jobs'} found',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const Spacer(),
          if (_searchController.text.isNotEmpty ||
              _selectedCategoryId != null ||
              _selectedJobType != null ||
              _selectedExperienceLevel != null ||
              _remoteOnly)
            TextButton(
              onPressed: _clearFilters,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching && _jobs.isEmpty) {
      return _buildShimmerLoader();
    }

    if (_error != null && _jobs.isEmpty) {
      return _buildErrorState();
    }

    if (_jobs.isEmpty && !_isSearching) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _jobs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            );
          }
          return _buildJobCard(_jobs[index]);
        },
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final jobTypeColor = _getJobTypeColor(job.jobType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToJobDetails(job.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: job.company.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          AppConstants.getImageUrl(job.company.logoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.business,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),

              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: jobTypeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatJobType(job.jobType),
                            style: TextStyle(
                              fontSize: 8,
                              color: jobTypeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (job.experienceLevel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatExperienceLevel(job.experienceLevel),
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Salary and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.minSalary != null || job.maxSalary != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatSalary(job),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPostedDate(job.postedAt),
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search filters',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                text: 'Clear Filters',
                onPressed: _clearFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'Failed to search jobs',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 100,
              child: PrimaryButton(
                text: 'Try Again',
                onPressed: () => _performSearch(refresh: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
