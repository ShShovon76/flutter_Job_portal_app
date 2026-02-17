// analytics_models.dart

// --------------------
// Shared Models
// --------------------

class DailyApplicationCount {
  final DateTime date;
  final int count;

  DailyApplicationCount({required this.date, required this.count});

  factory DailyApplicationCount.fromJson(Map<String, dynamic> json) {
    return DailyApplicationCount(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'count': count};
  }
}

class DailyViewCount {
  final DateTime date;
  final int count;

  DailyViewCount({required this.date, required this.count});

  factory DailyViewCount.fromJson(Map<String, dynamic> json) {
    return DailyViewCount(
      // 1. Handle potential null/missing dates
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),

      // 2. Handle potential null counts (Type 'Null' is not a subtype of 'int')
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'count': count};
  }
}

// --------------------
// Job View Models
// --------------------

class JobViewStats {
  final int jobId;
  final String jobTitle;
  final int views;
  final int applicants;

  JobViewStats({
    required this.jobId,
    required this.jobTitle,
    required this.views,
    required this.applicants,
  });

  factory JobViewStats.fromJson(Map<String, dynamic> json) {
    return JobViewStats(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      views: json['views'],
      applicants: json['applicants'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'views': views,
      'applicants': applicants,
    };
  }
}

class JobViewsResponse {
  final int jobId;
  final String jobTitle;
  final String companyName;
  final int totalViews;
  final int uniqueViews;
  final DateTime fromDate;
  final DateTime toDate;
  final List<DailyViewCount> dailyViews;

  JobViewsResponse({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.totalViews,
    required this.uniqueViews,
    required this.fromDate,
    required this.toDate,
    required this.dailyViews,
  });

  factory JobViewsResponse.fromJson(Map<String, dynamic> json) {
    return JobViewsResponse(
      jobId: json['jobId'] ?? 0,
      jobTitle: json['jobTitle'] ?? 'Unknown Job',
      companyName: json['companyName'] ?? 'Unknown Company',
      totalViews: json['totalViews'] ?? 0,
      uniqueViews: json['uniqueViews'] ?? 0,

      // Safety check for dates to prevent "Null is not a subtype of String"
      fromDate: json['fromDate'] != null
          ? DateTime.tryParse(json['fromDate'].toString()) ?? DateTime.now()
          : DateTime.now(),

      toDate: json['toDate'] != null
          ? DateTime.tryParse(json['toDate'].toString()) ?? DateTime.now()
          : DateTime.now(),

      // Safety check for the list
      dailyViews: json['dailyViews'] != null
          ? (json['dailyViews'] as List)
                .map((e) => DailyViewCount.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'totalViews': totalViews,
      'uniqueViews': uniqueViews,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'dailyViews': dailyViews.map((e) => e.toJson()).toList(),
    };
  }
}

// --------------------
// Application Trends
// --------------------

class ApplicationTrendsResponse {
  final int? jobId;
  final String? jobTitle;
  final int? employerId;
  final String? employerName;
  final String targetName;
  final DateTime fromDate;
  final DateTime toDate;
  final List<DailyApplicationCount> dailyApplications;
  final int totalApplications;
  final Map<String, int> statusBreakdown;

  ApplicationTrendsResponse({
    this.jobId,
    this.jobTitle,
    this.employerId,
    this.employerName,
    required this.targetName,
    required this.fromDate,
    required this.toDate,
    required this.dailyApplications,
    required this.totalApplications,
    required this.statusBreakdown,
  });

  factory ApplicationTrendsResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationTrendsResponse(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      employerId: json['employerId'],
      employerName: json['employerName'],
      targetName: json['targetName'],
      fromDate:
          DateTime.tryParse(json['fromDate']?.toString() ?? '') ??
          DateTime.now(),
      toDate:
          DateTime.tryParse(json['toDate']?.toString() ?? '') ?? DateTime.now(),
      dailyApplications: (json['dailyApplications'] as List? ?? [])
          .map((e) => DailyApplicationCount.fromJson(e))
          .toList(),
      totalApplications: json['totalApplications'] ?? 0,
      statusBreakdown: Map<String, int>.from(json['statusBreakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'employerId': employerId,
      'employerName': employerName,
      'targetName': targetName,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'dailyApplications': dailyApplications.map((e) => e.toJson()).toList(),
      'totalApplications': totalApplications,
      'statusBreakdown': statusBreakdown,
    };
  }
}

// --------------------
// Employer Dashboard
// --------------------

class EmployerDashboardResponse {
  final int employerId;
  final String employerName;
  final String companyName;
  final int totalJobs;
  final int activeJobs;
  final int profileViews;
  final int totalApplications;
  final int recentApplicationsCount;
  final List<JobViewStats> topViewedJobs;
  final Map<String, int> applicationStatusBreakdown;
  final bool hasActiveSubscription;

  EmployerDashboardResponse({
    required this.employerId,
    required this.employerName,
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.profileViews,
    required this.totalApplications,
    required this.recentApplicationsCount,
    required this.topViewedJobs,
    required this.applicationStatusBreakdown,
    required this.hasActiveSubscription,
  });

  factory EmployerDashboardResponse.fromJson(Map<String, dynamic> json) {
    return EmployerDashboardResponse(
      employerId: json['employerId'] ?? 0,
      employerName: json['employerName'] ?? '',
      companyName: json['companyName'] ?? '',

      totalJobs: json['totalJobs'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
      profileViews: json['profileViews'] ?? 0,
      totalApplications: json['totalApplications'] ?? 0,
      recentApplicationsCount: json['recentApplicationsCount'] ?? 0,

      topViewedJobs: (json['topViewedJobs'] as List? ?? [])
          .map((e) => JobViewStats.fromJson(e))
          .toList(),

      applicationStatusBreakdown: Map<String, int>.from(
        json['applicationStatusBreakdown'] ?? {},
      ),

      hasActiveSubscription: json['hasActiveSubscription'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employerId': employerId,
      'employerName': employerName,
      'companyName': companyName,
      'totalJobs': totalJobs,
      'activeJobs': activeJobs,
      'profileViews': profileViews,
      'totalApplications': totalApplications,
      'recentApplicationsCount': recentApplicationsCount,
      'topViewedJobs': topViewedJobs.map((e) => e.toJson()).toList(),
      'applicationStatusBreakdown': applicationStatusBreakdown,
      'hasActiveSubscription': hasActiveSubscription,
    };
  }
}

// --------------------
// Site Metrics
// --------------------

class JobCategoryStats {
  final int categoryId;
  final String categoryName;
  final int jobCount;

  JobCategoryStats({
    required this.categoryId,
    required this.categoryName,
    required this.jobCount,
  });

  factory JobCategoryStats.fromJson(Map<String, dynamic> json) {
    return JobCategoryStats(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      jobCount: json['jobCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'jobCount': jobCount,
    };
  }
}

class SiteMetricsResponse {
  final DateTime timestamp;

  // User metrics
  final int totalUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final Map<String, int> usersByRole;

  // Job metrics
  final int totalJobs;
  final int activeJobs;
  final int jobsPostedToday;
  final int jobsPostedThisWeek;

  // Company metrics
  final int totalCompanies;
  final int verifiedCompanies;
  final int companiesCreatedToday;

  // Application metrics
  final int totalApplications;
  final int applicationsToday;
  final int applicationsThisWeek;

  // Subscription metrics
  final int activeSubscriptions;
  final int subscriptionsToday;

  // Category metrics
  final List<JobCategoryStats> popularCategories;

  SiteMetricsResponse({
    required this.timestamp,
    required this.totalUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.usersByRole,
    required this.totalJobs,
    required this.activeJobs,
    required this.jobsPostedToday,
    required this.jobsPostedThisWeek,
    required this.totalCompanies,
    required this.verifiedCompanies,
    required this.companiesCreatedToday,
    required this.totalApplications,
    required this.applicationsToday,
    required this.applicationsThisWeek,
    required this.activeSubscriptions,
    required this.subscriptionsToday,
    required this.popularCategories,
  });

  factory SiteMetricsResponse.fromJson(Map<String, dynamic> json) {
    return SiteMetricsResponse(
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      totalUsers: json['totalUsers'] ?? 0,
      newUsersToday: json['newUsersToday'],
      newUsersThisWeek: json['newUsersThisWeek'],
      newUsersThisMonth: json['newUsersThisMonth'],
      usersByRole: Map<String, int>.from(json['usersByRole'] ?? {}),
      totalJobs: json['totalJobs'],
      activeJobs: json['activeJobs'],
      jobsPostedToday: json['jobsPostedToday'],
      jobsPostedThisWeek: json['jobsPostedThisWeek'],
      totalCompanies: json['totalCompanies'],
      verifiedCompanies: json['verifiedCompanies'],
      companiesCreatedToday: json['companiesCreatedToday'],
      totalApplications: json['totalApplications'],
      applicationsToday: json['applicationsToday'],
      applicationsThisWeek: json['applicationsThisWeek'],
      activeSubscriptions: json['activeSubscriptions'],
      subscriptionsToday: json['subscriptionsToday'],
      popularCategories: (json['popularCategories'] as List)
          .map((e) => JobCategoryStats.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'totalUsers': totalUsers,
      'newUsersToday': newUsersToday,
      'newUsersThisWeek': newUsersThisWeek,
      'newUsersThisMonth': newUsersThisMonth,
      'usersByRole': usersByRole,
      'totalJobs': totalJobs,
      'activeJobs': activeJobs,
      'jobsPostedToday': jobsPostedToday,
      'jobsPostedThisWeek': jobsPostedThisWeek,
      'totalCompanies': totalCompanies,
      'verifiedCompanies': verifiedCompanies,
      'companiesCreatedToday': companiesCreatedToday,
      'totalApplications': totalApplications,
      'applicationsToday': applicationsToday,
      'applicationsThisWeek': applicationsThisWeek,
      'activeSubscriptions': activeSubscriptions,
      'subscriptionsToday': subscriptionsToday,
      'popularCategories': popularCategories.map((e) => e.toJson()).toList(),
    };
  }
}

// --------------------
// Job Seeker Dashboard
// --------------------

class RecentApplication {
  final int jobId;
  final String jobTitle;
  final String companyName;
  final String status;
  final String appliedAt;

  RecentApplication({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
  });

  factory RecentApplication.fromJson(Map<String, dynamic> json) {
    return RecentApplication(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      status: json['status'],
      appliedAt: json['appliedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'status': status,
      'appliedAt': appliedAt,
    };
  }
}

class JobSeekerDashboardResponse {
  final int jobSeekerId;
  final String fullName;
  final int totalApplications;
  final int applicationsLast30Days;
  final Map<String, int> applicationStatusBreakdown;
  final List<RecentApplication> recentApplications;

  JobSeekerDashboardResponse({
    required this.jobSeekerId,
    required this.fullName,
    required this.totalApplications,
    required this.applicationsLast30Days,
    required this.applicationStatusBreakdown,
    required this.recentApplications,
  });

  factory JobSeekerDashboardResponse.fromJson(Map<String, dynamic> json) {
    return JobSeekerDashboardResponse(
      jobSeekerId: json['jobSeekerId'],
      fullName: json['fullName'],
      totalApplications: json['totalApplications'],
      applicationsLast30Days: json['applicationsLast30Days'],
      applicationStatusBreakdown: Map<String, int>.from(
        json['applicationStatusBreakdown'],
      ),
      recentApplications: (json['recentApplications'] as List)
          .map((e) => RecentApplication.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobSeekerId': jobSeekerId,
      'fullName': fullName,
      'totalApplications': totalApplications,
      'applicationsLast30Days': applicationsLast30Days,
      'applicationStatusBreakdown': applicationStatusBreakdown,
      'recentApplications': recentApplications.map((e) => e.toJson()).toList(),
    };
  }
}

// --------------------
// Job Analytics
// --------------------

class JobAnalytics {
  final int jobId;
  final String title;
  final int totalViews;
  final int uniqueViews;
  final int totalApplications;
  final String lastViewedAt;

  JobAnalytics({
    required this.jobId,
    required this.title,
    required this.totalViews,
    required this.uniqueViews,
    required this.totalApplications,
    required this.lastViewedAt,
  });

  factory JobAnalytics.fromJson(Map<String, dynamic> json) {
    return JobAnalytics(
      jobId: json['jobId'],
      title: json['title'],
      totalViews: json['totalViews'],
      uniqueViews: json['uniqueViews'],
      totalApplications: json['totalApplications'],
      lastViewedAt: json['lastViewedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'title': title,
      'totalViews': totalViews,
      'uniqueViews': uniqueViews,
      'totalApplications': totalApplications,
      'lastViewedAt': lastViewedAt,
    };
  }
}
