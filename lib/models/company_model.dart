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
      // Added null check and fallback for type and url
      type: SocialLinkTypeExtension.fromString(json['type'] ?? 'WEBSITE'),
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

  final SimpleUser owner;

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
  final bool? verified;
  final int? reviewCount;
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
    this.verified,
    this.reviewCount,
    required this.socialLinks,
    this.createdAt,
    this.activeJobCount,
    this.featured,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      // Provide an empty map if owner is null to avoid crash
      owner: SimpleUser.fromJson(json['owner'] ?? {}),
      name: json['name'] ?? 'No Name',
      industry: json['industry'] ?? 'Unknown',
      companySize: json['companySize'],
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      about: json['about'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      foundedYear: json['foundedYear'],
      rating: (json['rating'] != null)
          ? (json['rating'] as num).toDouble()
          : null,
      verified: json['verified'] ?? false,
      reviewCount: json['reviewCount'],
      socialLinks: json['socialLinks'] != null
          ? List<SocialLink>.from(
              (json['socialLinks'] as List).map((x) => SocialLink.fromJson(x)),
            )
          : [],
      // CRITICAL FIX: Only parse if the key exists and is not null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      activeJobCount: json['activeJobCount'],
      featured: json['featured'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner': owner.toJson(),
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
    'socialLinks': socialLinks.map((x) => x.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'activeJobCount': activeJobCount,
    'featured': featured,
  };
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
