// ---------------------------
// Social Link Type Enum
// ---------------------------
enum SocialLinkType { WEBSITE, LINKEDIN, FACEBOOK, INSTAGRAM }

extension SocialLinkTypeExtension on SocialLinkType {
  String get value {
    return toString().split('.').last;
  }

  static SocialLinkType fromString(String type) {
    return SocialLinkType.values.firstWhere(
      (e) => e.value == type.toUpperCase(),
      orElse: () => SocialLinkType.WEBSITE,
    );
  }
}

// ---------------------------
// Social Link Model
// ---------------------------
class SocialLink {
  final SocialLinkType type;
  final String url;

  SocialLink({required this.type, required this.url});

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      type: json['type'] != null
          ? SocialLinkTypeExtension.fromString(json['type'])
          : SocialLinkType.WEBSITE,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'type': type.value, 'url': url};
}

// ---------------------------
// Company Model
// ---------------------------
class Company {
  final int id;
  final SimpleUser? owner;
  final String name;
  final String industry;
  final String? companySize;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? about;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final int? foundedYear;
  final double? rating;
  final bool verified;
  final int? reviewCount;

  /// Relations
  final List<SocialLink> socialLinks;
  final DateTime? createdAt;
  final int? activeJobCount;
  final bool? featured;

  Company({
    required this.id,
    required this.owner,
    required this.name,
    required this.industry,
    this.companySize,
    this.logoUrl,
    this.coverImageUrl,
    this.about,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.foundedYear,
    this.rating,
    required this.verified,
    this.reviewCount,
    required this.socialLinks,
    this.createdAt,
    this.activeJobCount,
    this.featured,
  });

  /// ---------- FROM JSON ----------
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      owner: json['owner'] != null ? SimpleUser.fromJson(json['owner']) : null,

      name: json['name'] ?? '',
      industry: json['industry'] ?? '',

      companySize: json['companySize'],
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      about: json['about'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      foundedYear: json['foundedYear'],

      // ✅ BigDecimal safe parsing
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,

      // ✅ Backend primitive boolean → non-nullable
      verified: json['verified'] ?? false,

      reviewCount: json['reviewCount'],

      socialLinks:
          (json['socialLinks'] as List?)
              ?.map((e) => SocialLink.fromJson(e))
              .toList() ??
          [],

      // Optional / future-safe
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      activeJobCount: json['activeJobCount'],
      featured: json['featured'],
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() => {
    'id': id,
    'owner': owner?.toJson(),
    'name': name,
    'industry': industry,
    'companySize': companySize,
    'logoUrl': logoUrl,
    'coverImageUrl': coverImageUrl,
    'about': about,
    'website': website,
    'email': email,
    'phone': phone,
    'address': address,
    'foundedYear': foundedYear,
    'rating': rating,
    'verified': verified,
    'reviewCount': reviewCount,
    'socialLinks': socialLinks.map((e) => e.toJson()).toList(),

    // Extra frontend fields (ignored by backend safely)
    'createdAt': createdAt?.toIso8601String(),
    'activeJobCount': activeJobCount,
    'featured': featured,
  };

  /// ---------- COPY WITH ----------
  Company copyWith({
    int? id,
    SimpleUser? owner,
    String? name,
    String? industry,
    String? companySize,
    String? logoUrl,
    String? coverImageUrl,
    String? about,
    String? website,
    String? email,
    String? phone,
    String? address,
    int? foundedYear,
    double? rating,
    bool? verified,
    int? reviewCount,
    List<SocialLink>? socialLinks,
    DateTime? createdAt,
    int? activeJobCount,
    bool? featured,
  }) {
    return Company(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      about: about ?? this.about,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      foundedYear: foundedYear ?? this.foundedYear,
      rating: rating ?? this.rating,
      verified: verified ?? this.verified,
      reviewCount: reviewCount ?? this.reviewCount,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      activeJobCount: activeJobCount ?? this.activeJobCount,
      featured: featured ?? this.featured,
    );
  }
}

// ---------------------------
// Simple User (for owner)
// ---------------------------
class SimpleUser {
  final int id;
  final String fullName;

  SimpleUser({required this.id, required this.fullName});

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? 'Unknown Owner',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'fullName': fullName};
}
class CompanyUpdateRequest {
  final String? name;
  final String? industry;
  final String? companySize;
  final String? about;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final int? foundedYear;
  final List<SocialLink>? socialLinks;

  CompanyUpdateRequest({
    this.name,
    this.industry,
    this.companySize,
    this.about,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.foundedYear,
    this.socialLinks,
  });

  /// 🔁 Convert to JSON (only what backend expects)
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (industry != null) 'industry': industry,
        if (companySize != null) 'companySize': companySize,
        if (about != null) 'about': about,
        if (website != null) 'website': website,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (foundedYear != null) 'foundedYear': foundedYear,
        if (socialLinks != null)
          'socialLinks': socialLinks!.map((e) => e.toJson()).toList(),
      };
}
