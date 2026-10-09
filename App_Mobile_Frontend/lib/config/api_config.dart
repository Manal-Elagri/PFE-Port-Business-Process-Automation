class ApiConfig {
  // Tu n'auras plus qu'à changer cette ligne quand ton IP change
  static const String ipAddress = "192.168.8.3"; // Remplace par ton IP locale 192.168.1.109
  
  static const String baseUrl = "http://$ipAddress:8080";
   static const String aiWebUrl = "http://localhost:8002";

  // Endpoints
  static const String authUrl = "$baseUrl/auth";
  static const String adminUrl = "$baseUrl/api/admin";
  static const String registerUrl = "$baseUrl/api/demandes-inscription";
  static const String chefescaleUrl = "$baseUrl/api/chef-escale";
  static const String employeUrl = "$baseUrl/api/employe";
  static const String operationsUrl = '$baseUrl/api/operations';
  static const String scansUrl = '$baseUrl/api/scans';
  static const String chefdivisionUrl = "$baseUrl/api/chef-division";
  static const String chefserviceUrl = "$baseUrl/api/chef-service";
  // --- AJOUTE CETTE MÉTHODE ---
  // --- LE CORRECTEUR UNIVERSEL ---
  static String fixUrl(String? url) {
    if (url == null || url.isEmpty) return "";

    // Logique : On cherche où commence le chemin des fichiers (/uploads/)
    if (url.contains('/uploads/')) {
      // On récupère tout ce qui est après le port 8080
      // Exemple : de "http://192.168.1.182:8080/uploads/image.jpg" 
      // on garde "/uploads/image.jpg"
      int index = url.indexOf('/uploads/');
      String path = url.substring(index); 
      
      // On reconstruit l'URL avec l'IP de ton choix (ipAddress)
      return "http://$ipAddress:8080$path";
    }
    
    return url;
  }
}