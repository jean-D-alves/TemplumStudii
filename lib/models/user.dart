class User {
  final int id;
  final String name;
  final String email;
  final String? studies;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.studies,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['userId'];
    return User(
      id: int.tryParse('$idValue') ?? 0,
      name: json['name'],
      email: json['email'],
      studies: json['studies'] ?? json['areaOfStudy'],
    );
  }
}