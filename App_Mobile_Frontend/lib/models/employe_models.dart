import 'package:flutter/material.dart';
import '../config/api_config.dart';


class EmployeProfile {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageURL;

  // --- AJOUTE CETTE MÉTHODE ---
  String? get formattedImageUrl => ApiConfig.fixUrl(imageURL);

  EmployeProfile({required this.id, required this.nom, required this.prenom, required this.email, required this.role, this.imageURL});

  factory EmployeProfile.fromJson(Map<String, dynamic> json) => EmployeProfile(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    role: json['role'],
    imageURL: json['imageURL'],
  );
}

class PersonnelModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  PersonnelModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });

  factory PersonnelModel.fromJson(Map<String, dynamic> json) {
    return PersonnelModel(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class EquipeModel {
  final int id;
  final String matriculeEquipe;

  EquipeModel({
    required this.id,
    required this.matriculeEquipe,
  });

  factory EquipeModel.fromJson(Map<String, dynamic> json) {
    return EquipeModel(
      id: json['id'],
      matriculeEquipe: json['matriculeEquipe'],
    );
  }
}

class CongeModel {
  final int id;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final String type;

  CongeModel({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.type,
  });

  factory CongeModel.fromJson(Map<String, dynamic> json) {
    return CongeModel(
      id: json['id'],
      dateDebut: json['dateDebut'].toString(),
      dateFin: json['dateFin'].toString(),
      statut: json['statut'],
      type: json['type'],
    );
  }
}

class EquipePersonnelModel {
  final int id;
  final PersonnelModel personnel;
  final String roleMetier;

  EquipePersonnelModel({
    required this.id,
    required this.personnel,
    required this.roleMetier,
  });

  factory EquipePersonnelModel.fromJson(Map<String, dynamic> json) {
    return EquipePersonnelModel(
      id: json['id'],
      personnel: PersonnelModel.fromJson(json['personnel']),
      roleMetier: json['roleMetier'],
    );
  }
}

class HistoriqueShiftModel {
  final int id;
  final bool active;

  HistoriqueShiftModel({
    required this.id,
    required this.active,
  });

  factory HistoriqueShiftModel.fromJson(Map<String, dynamic> json) {
    return HistoriqueShiftModel(
      id: json['id'],
      active: json['active'] ?? false,
    );
  }
}

class OperationContextModel {
  final int id;
  final String matriculeEquipe;

  OperationContextModel({
    required this.id,
    required this.matriculeEquipe,
  });

  factory OperationContextModel.fromJson(Map<String, dynamic> json) {
    return OperationContextModel(
      id: json['id'],
      matriculeEquipe: json['matriculeEquipe'],
    );
  }
}
