class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});

  AppUser copyWith({String? id, String? name, String? email}) {
    return AppUser(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email);
  }
}
