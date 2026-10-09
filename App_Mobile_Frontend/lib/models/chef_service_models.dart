import '../config/api_config.dart';

/// ======================
/// PROFILE
/// ======================

class ChefServiceProfile {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageURL;

  ChefServiceProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.imageURL,
  });

  String? get formattedImageUrl =>
      ApiConfig.fixUrl(imageURL);

  factory ChefServiceProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChefServiceProfile(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'].toString(),
      imageURL: json['imageURL'],
    );
  }
}

/// ======================
/// DASHBOARD
/// ======================

class ChefServiceDashboard {

  final int totalOperations;

  final int operationsEnCours;

  final int operationsTerminees;

  final int operationsAnnulees;

  final int postesUtilises;

  final int portiersUtilises;

  final int enginsUtilises;

  final int totalConteneurs;

  final double moyenneConteneurs;

  final double dureeMoyenneMinutes;

  final int totalArrets;

  final double dureeTotaleArretsMinutes;

  final double tauxDetectionIA;

  final int scansToday;

  final int documentsEnAttente;

  final int documentsSignes;

  ChefServiceDashboard({
    required this.totalOperations,
    required this.operationsEnCours,
    required this.operationsTerminees,
    required this.operationsAnnulees,
    required this.postesUtilises,
    required this.portiersUtilises,
    required this.enginsUtilises,
    required this.totalConteneurs,
    required this.moyenneConteneurs,
    required this.dureeMoyenneMinutes,
    required this.totalArrets,
    required this.dureeTotaleArretsMinutes,
    required this.tauxDetectionIA,
    required this.scansToday,
    required this.documentsEnAttente,
    required this.documentsSignes,
  });

  factory ChefServiceDashboard.fromJson(
      Map<String, dynamic> json) {
    return ChefServiceDashboard(
      totalOperations:
          json['totalOperations'] ?? 0,

      operationsEnCours:
          json['operationsEnCours'] ?? 0,

      operationsTerminees:
          json['operationsTerminees'] ?? 0,

      operationsAnnulees:
          json['operationsAnnulees'] ?? 0,

      postesUtilises:
          json['postesUtilises'] ?? 0,

      portiersUtilises:
          json['portiersUtilises'] ?? 0,

      enginsUtilises:
          json['enginsUtilises'] ?? 0,

      totalConteneurs:
          json['totalConteneurs'] ?? 0,

      moyenneConteneurs:
          (json['moyenneConteneurs'] ?? 0)
              .toDouble(),

      dureeMoyenneMinutes:
          (json['dureeMoyenneMinutes'] ?? 0)
              .toDouble(),

      totalArrets:
          json['totalArrets'] ?? 0,

      dureeTotaleArretsMinutes:
          (json[
                      'dureeTotaleArretsMinutes'] ??
                  0)
              .toDouble(),

      tauxDetectionIA:
          (json['tauxDetectionIA'] ?? 0)
              .toDouble(),

      scansToday:
          json['scansToday'] ?? 0,

      documentsEnAttente:
          json['documentsEnAttente'] ?? 0,

      documentsSignes:
          json['documentsSignes'] ?? 0,
    );
  }
}

/// ======================
/// PERSONNEL
/// ======================

class SimplePersonnel {

  final int id;

  final String nom;

  final String prenom;

  final String? imageURL;

  final String? role;

  SimplePersonnel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.imageURL,
    this.role,
  });

  String? get formattedImage =>
      ApiConfig.fixUrl(imageURL);

  factory SimplePersonnel.fromJson(
      Map<String, dynamic> json) {
    return SimplePersonnel(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      imageURL: json['imageURL'],
      role: json['role']?.toString(),
    );
  }
}

/// ======================
/// SHIFT
/// ======================

class ShiftModel {

  final int id;

  final String type;

  final String heureDebut;

  final String heureFin;

  final SimplePersonnel? chefService;

  final SimplePersonnel? chefDivision;

  ShiftModel({
    required this.id,
    required this.type,
    required this.heureDebut,
    required this.heureFin,
    this.chefService,
    this.chefDivision,
  });

  factory ShiftModel.fromJson(
      Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      type: json['type'] ?? '',
      heureDebut:
          json['heureDebut'] ?? '',
      heureFin:
          json['heureFin'] ?? '',
      chefService:
          json['chefService'] != null
              ? SimplePersonnel.fromJson(
                  json['chefService'],
                )
              : null,
      chefDivision:
          json['chefDivision'] != null
              ? SimplePersonnel.fromJson(
                  json['chefDivision'],
                )
              : null,
    );
  }
}

/// ======================
/// EQUIPE
/// ======================

class EquipeModel {

  final int id;

  final String matriculeEquipe;

  final SimplePersonnel? chefEquipe;

  EquipeModel({
    required this.id,
    required this.matriculeEquipe,
    this.chefEquipe,
  });

  factory EquipeModel.fromJson(
      Map<String, dynamic> json) {
    return EquipeModel(
      id: json['id'],
      matriculeEquipe:
          json['matriculeEquipe'] ?? '',
      chefEquipe:
          json['chefEquipe'] != null
              ? SimplePersonnel.fromJson(
                  json['chefEquipe'],
                )
              : null,
    );
  }
}

/// ======================
/// HISTORIQUE SHIFT
/// ======================

class HistoriqueShiftModel {

  final int id;

  final EquipeModel? equipe;

  final DateTime? dateDebut;

  final DateTime? dateFin;

  final bool active;

  HistoriqueShiftModel({
    required this.id,
    this.equipe,
    this.dateDebut,
    this.dateFin,
    required this.active,
  });

  factory HistoriqueShiftModel.fromJson(
      Map<String, dynamic> json) {
    return HistoriqueShiftModel(
      id: json['id'],

      equipe:
          json['equipe'] != null
              ? EquipeModel.fromJson(
                  json['equipe'],
                )
              : null,

      dateDebut:
          json['dateDebut'] != null
              ? DateTime.parse(
                  json['dateDebut'],
                )
              : null,

      dateFin:
          json['dateFin'] != null
              ? DateTime.parse(
                  json['dateFin'],
                )
              : null,

      active:
          json['active'] ?? false,
    );
  }
}