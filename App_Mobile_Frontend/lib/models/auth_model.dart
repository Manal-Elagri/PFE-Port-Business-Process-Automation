enum RoleUser { 
  ADMIN, 
  CHEF_ESCALE, 
  CHEF_SERVICE, 
  CHEF_DIVISION, 
  CHEF_EQUIPE, 
  EMPLOYE 
}

class AuthResponse {
  final String token;
  final String role; // On garde String ici car c'est plus facile pour faire le .startsWith('CHEF_')
  final String nom;

  AuthResponse({
    required this.token, 
    required this.role, 
    required this.nom
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      // Le rôle reçu du JSON sera "ADMIN" ou "EMPLOYE", etc.
      role: json['role'], 
      nom: json['nom'],
    );
  }
}