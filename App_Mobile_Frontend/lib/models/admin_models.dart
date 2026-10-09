
import 'package:flutter/material.dart';
import '../config/api_config.dart';


class AdminProfile {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageURL;

  AdminProfile({required this.id, required this.nom, required this.prenom, required this.email, required this.role, this.imageURL});

  factory AdminProfile.fromJson(Map<String, dynamic> json) => AdminProfile(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    role: json['role'],
    imageURL: json['imageURL'],
  );
}

class GlobalStats {
  final int totalPersonnels;
  final int totalChefsEscales;
  final int totalEquipes;
  final int totalShifts;
  final int shiftsActifs;
  final int demandesEnAttente;
  final int employesEnConge;

  GlobalStats({required this.totalPersonnels, required this.totalChefsEscales, required this.totalEquipes, required this.totalShifts, required this.shiftsActifs, required this.demandesEnAttente, required this.employesEnConge});

  factory GlobalStats.fromJson(Map<String, dynamic> json) => GlobalStats(
    totalPersonnels: json['totalPersonnels'],
    totalChefsEscales: json['totalChefsEscales'],
    totalEquipes: json['totalEquipes'],
    totalShifts: json['totalShifts'],
    shiftsActifs: json['shiftsActifs'],
    demandesEnAttente: json['demandesEnAttente'],
    employesEnConge: json['employesEnConge'],
  );
}



class ResourceUsageDTO {
  final String nom;
  final int totalUtilisations;
  ResourceUsageDTO({required this.nom, required this.totalUtilisations});
  factory ResourceUsageDTO.fromJson(Map<String, dynamic> j) =>
      ResourceUsageDTO(nom: j['nom'], totalUtilisations: j['totalUtilisations']);
}

class StatsRateDTO {
  final String label;
  final double value;
  StatsRateDTO({required this.label, required this.value});
  factory StatsRateDTO.fromJson(Map<String, dynamic> j) =>
      StatsRateDTO(label: j['label'], value: (j['value'] as num).toDouble());
}

class StatsCountDTO {
  final String label;
  final int total;
  StatsCountDTO({required this.label, required this.total});
  factory StatsCountDTO.fromJson(Map<String, dynamic> j) =>
      StatsCountDTO(label: j['label'], total: j['total']);
}

class OperationStatsDTO {
  final int totalOperations;
  final int terminees;
  final int enCours;
  final int annulees;
  final double moyenneConteneurs;
  final double dureeMoyenneSecondes;
  OperationStatsDTO({
    required this.totalOperations,
    required this.terminees,
    required this.enCours,
    required this.annulees,
    required this.moyenneConteneurs,
    required this.dureeMoyenneSecondes,
  });
  factory OperationStatsDTO.fromJson(Map<String, dynamic> j) => OperationStatsDTO(
    totalOperations: j['totalOperations'],
    terminees: j['terminees'],
    enCours: j['enCours'],
    annulees: j['annulees'] ?? 0,
    moyenneConteneurs: (j['moyenneConteneurs'] as num?)?.toDouble() ?? 0.0,
    dureeMoyenneSecondes: (j['dureeMoyenneSecondes'] as num?)?.toDouble() ?? 0.0,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// MODEL
// ═════════════════════════════════════════════════════════════════════════════
 
class DemandeInscription {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String cin;
  final String telephone;
  final String roleDemande;
  final String statut;
  final String? imageURL;
 
  // --- AJOUTE CETTE MÉTHODE ---
  String? get formattedImageUrl => ApiConfig.fixUrl(imageURL);

  DemandeInscription({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.cin,
    required this.telephone,
    required this.roleDemande,
    required this.statut,
    this.imageURL,
  });
 
  factory DemandeInscription.fromJson(Map<String, dynamic> j) =>
      DemandeInscription(
        id: j['id'],
        nom: j['nom'],
        prenom: j['prenom'],
        email: j['email'],
        cin: j['cin'] ?? '',
        telephone: j['telephone'] ?? '',
        roleDemande: j['roleDemande'] ?? '',
        statut: j['statut'] ?? 'EN_ATTENTE',
        imageURL: j['imageURL'],
      );
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


enum EtatEngin { ACTIF, PANNE, MAINTENANCE }
class EnginModel {
  final int id;
  final String type;
  final EtatEngin etat;
  final double capacite;

  EnginModel({
    required this.id,
    required this.type,
    required this.etat,
    required this.capacite,
  });

  factory EnginModel.fromJson(Map<String, dynamic> json) {
    return EnginModel(
      id: json['id'],
      type: json['type'],
      etat: _etatFromString(json['etat']),
      capacite: (json['capacite'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'etat': etat.name, // important
      'capacite': capacite,
    };
  }

  static EtatEngin _etatFromString(String value) {
    switch (value) {
      case 'ACTIF':
        return EtatEngin.ACTIF;
      case 'PANNE':
        return EtatEngin.PANNE;
      case 'MAINTENANCE':
        return EtatEngin.MAINTENANCE;
      default:
        return EtatEngin.ACTIF;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// POSTE
// ═════════════════════════════════════════════════════════════════════════════

class PosteModel {
  final int id;
  final int numeroPoste;
  final String localisation;
  final double latitude;
  final double longitude;

  PosteModel({
    required this.id,
    required this.numeroPoste,
    required this.localisation,
    required this.latitude,
    required this.longitude,
  });

  factory PosteModel.fromJson(Map<String, dynamic> json) => PosteModel(
        id: json['id'],
        numeroPoste: json['numeroPoste'],
        localisation: json['localisation'] ?? '',
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numeroPoste': numeroPoste,
        'localisation': localisation,
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// PORTIER
// ═════════════════════════════════════════════════════════════════════════════

class PortierModel {
  final int id;
  final String code;
  final int nombreCameras;

  PortierModel({
    required this.id,
    required this.code,
    required this.nombreCameras,
  });

  factory PortierModel.fromJson(Map<String, dynamic> json) => PortierModel(
        id: json['id'],
        code: json['code'] ?? '',
        nombreCameras: json['nombreCameras'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'nombreCameras': nombreCameras,
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// NAVIRE
// ═════════════════════════════════════════════════════════════════════════════

class NavireModel {
  final int id;
  final String nom;
  final String numeroIMO;

  NavireModel({
    required this.id,
    required this.nom,
    required this.numeroIMO,
  });

  factory NavireModel.fromJson(Map<String, dynamic> json) => NavireModel(
        id: json['id'],
        nom: json['nom'] ?? '',
        numeroIMO: json['numeroIMO'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'numeroIMO': numeroIMO,
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// ESCALE
// ═════════════════════════════════════════════════════════════════════════════

class EscaleModel {
  final int id;
  final String numeroEscale;
  final String dateArrivee;
  final String dateDepart;
  final NavireModel? navire;

  EscaleModel({
    required this.id,
    required this.numeroEscale,
    required this.dateArrivee,
    required this.dateDepart,
    this.navire,
  });

  factory EscaleModel.fromJson(Map<String, dynamic> json) => EscaleModel(
        id: json['id'],
        numeroEscale: json['numeroEscale'] ?? '',
        dateArrivee: json['dateArrivee'] ?? '',
        dateDepart: json['dateDepart'] ?? '',
        navire: json['navire'] != null
            ? NavireModel.fromJson(json['navire'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numeroEscale': numeroEscale,
        'dateArrivee': dateArrivee,
        'dateDepart': dateDepart,
        'navire': navire?.toJson(),
      };
}



class PlanningModel {
  final int id;
  final String date;
  PlanningModel({required this.id, required this.date});

  factory PlanningModel.fromJson(Map<String, dynamic> json) => PlanningModel(
    id: json['id'],
    date: json['date'],
  );
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