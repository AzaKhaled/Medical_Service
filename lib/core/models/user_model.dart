class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    imageUrl: json['image_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'image_url': imageUrl,
  };
}
