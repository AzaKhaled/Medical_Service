class DoctorModel {
  final String? id;
  final String? name;
  final String? specialtyId;
  final String? specialtyName;
  final String? workingHours;
  final double? price;
  double? rating;
  final int? experienceYears;
  final int? patientsCount;
  final String? bio;
  final String? imageUrl;
  final List<int>? workingDays;

  DoctorModel({
    this.id,
    this.name,
    this.specialtyId,
    this.specialtyName,
    this.workingHours,
    this.price,
    this.rating,
    this.experienceYears,
    this.patientsCount,
    this.bio,
     this.imageUrl,
     this.workingDays,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialtyId: json['specialty_id'] as String,
      specialtyName: json['specialty_name'] as String? ?? '',
      workingHours: json['working_hours'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      experienceYears: (json['experience_years'] as num).toInt(),
      patientsCount: (json['patients_count'] as num).toInt(),
      bio: json['bio'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      workingDays: (json['working_days'] as List<dynamic>)
          .map((e) => e as int)
          .toList()??[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty_id': specialtyId,
      'specialty_name': specialtyName,
      'working_hours': workingHours,
      'price': price,
      'rating': rating,
      'experience_years': experienceYears,
      'patients_count': patientsCount,
      'bio': bio,
      'image_url': imageUrl,
      'working_days': workingDays,
    };
  }
}
