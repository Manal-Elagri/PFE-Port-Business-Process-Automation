import 'package:flutter/material.dart';
import '../config/api_config.dart';


class ChefEscaleProfile {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageURL;

  // --- AJOUTE CETTE MÉTHODE ---
  String? get formattedImageUrl => ApiConfig.fixUrl(imageURL);

  ChefEscaleProfile({required this.id, required this.nom, required this.prenom, required this.email, required this.role, this.imageURL});

  factory ChefEscaleProfile.fromJson(Map<String, dynamic> json) => ChefEscaleProfile(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    role: json['role'],
    imageURL: json['imageURL'],
  );
}

class ChefEscaleDashboardStats {
  final int totalEquipes;
  final int totalPersonnels;
  final int totalShifts;
  final int totalMouvements;

  ChefEscaleDashboardStats({
    required this.totalEquipes,
    required this.totalPersonnels,
    required this.totalShifts,
    required this.totalMouvements,
  });

  factory ChefEscaleDashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChefEscaleDashboardStats(
      totalEquipes: json['totalEquipes'] ?? 0,
      totalPersonnels: json['totalPersonnels'] ?? 0,
      totalShifts: json['totalShifts'] ?? 0,
      totalMouvements: json['totalMouvements'] ?? 0,
    );
  }
}


class PersonnelModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role;
  final String? imageURL;
 
  // AJOUTE CECI :
  String? get formattedImageUrl => ApiConfig.fixUrl(imageURL);
  
  PersonnelModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    this.imageURL,
  });
 
  factory PersonnelModel.fromJson(Map<String, dynamic> j) => PersonnelModel(
        id: j['id'],
        nom: j['nom'] ?? '',
        prenom: j['prenom'] ?? '',
        email: j['email'] ?? '',
        telephone: j['telephone'] ?? '',
        role: j['role'] ?? '',
        imageURL: j['imageURL'],
      );
}

class EquipeModel {
  final int id;
  final String matriculeEquipe;

  final PersonnelModel? chefEquipe;
  final ShiftModel? shift;
  final PersonnelModel? chefEscale;

  EquipeModel({
    required this.id,
    required this.matriculeEquipe,
    this.chefEquipe,
    this.shift,
    this.chefEscale,
  });

  factory EquipeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EquipeModel(
      id: json['id'],
      matriculeEquipe: json['matriculeEquipe'] ?? '',

      chefEquipe: json['chefEquipe'] != null
          ? PersonnelModel.fromJson(json['chefEquipe'])
          : null,

      shift: json['shift'] != null
          ? ShiftModel.fromJson(json['shift'])
          : null,

      chefEscale: json['chefEscale'] != null
          ? PersonnelModel.fromJson(json['chefEscale'])
          : null,
    );
  }
}

class HistoriqueShiftModel {
  final int id;

  final EquipeModel? equipe;
  final ShiftModel? shift;
  final PersonnelModel? chefEscale;

  final String? dateDebut;
  final String? dateFin;

  final bool active;

  HistoriqueShiftModel({
    required this.id,
    this.equipe,
    this.shift,
    this.chefEscale,
    this.dateDebut,
    this.dateFin,
    required this.active,
  });

  factory HistoriqueShiftModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoriqueShiftModel(
      id: json['id'],

      equipe: json['equipe'] != null
          ? EquipeModel.fromJson(json['equipe'])
          : null,

      shift: json['shift'] != null
          ? ShiftModel.fromJson(json['shift'])
          : null,

      chefEscale: json['chefEscale'] != null
          ? PersonnelModel.fromJson(json['chefEscale'])
          : null,

      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      active: json['active'] ?? false,
    );
  }
}

class ShiftModel {
  final int id;
  final String type; // SHIFT_1, SHIFT_2, SHIFT_3
  final String heureDebut;
  final String heureFin;
  final PersonnelModel? chefService;
  final PersonnelModel? chefDivision;
  final String? planningDate;
  
  ShiftModel({required this.id, required this.type, required this.heureDebut, required this.heureFin, this.chefService, this.chefDivision, this.planningDate});

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
    id: json['id'],
    type: json['type'],
    heureDebut: json['heureDebut'],
    heureFin: json['heureFin'],
    chefService: json['chefService'] != null ? PersonnelModel.fromJson(json['chefService']) : null,
    chefDivision: json['chefDivision'] != null ? PersonnelModel.fromJson(json['chefDivision']) : null,
    planningDate: json['planningDate'] ?? json['date'],
  );
}