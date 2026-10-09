import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ChefDivisionProfile {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageURL;

  ChefDivisionProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.imageURL,
  });

  String? get formattedImageUrl =>
      ApiConfig.fixUrl(imageURL);

  factory ChefDivisionProfile.fromJson(
      Map<String, dynamic> json) {
    return ChefDivisionProfile(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      imageURL: json['imageURL'],
    );
  }
}

class ChefDivisionDashboard {
  final int operationsToday;
  final int operationsWeek;

  final int chargements;
  final int dechargements;

  final double tauxAnnulation;
  final double tauxRetard;
  final double tauxArret;

  final double tauxDetectionIA;

  final int scansToday;
  final int scansWeek;
  final int erreursIA;

  final int documentsEnAttente;
  final int documentsSignes;

  ChefDivisionDashboard({
    required this.operationsToday,
    required this.operationsWeek,
    required this.chargements,
    required this.dechargements,
    required this.tauxAnnulation,
    required this.tauxRetard,
    required this.tauxArret,
    required this.tauxDetectionIA,
    required this.scansToday,
    required this.scansWeek,
    required this.erreursIA,
    required this.documentsEnAttente,
    required this.documentsSignes,
  });

  factory ChefDivisionDashboard.fromJson(
      Map<String, dynamic> json) {
    return ChefDivisionDashboard(
      operationsToday: json['operationsToday'],
      operationsWeek: json['operationsWeek'],
      chargements: json['chargements'],
      dechargements: json['dechargements'],
      tauxAnnulation:
          (json['tauxAnnulation'] ?? 0).toDouble(),
      tauxRetard:
          (json['tauxRetard'] ?? 0).toDouble(),
      tauxArret:
          (json['tauxArret'] ?? 0).toDouble(),
      tauxDetectionIA:
          (json['tauxDetectionIA'] ?? 0).toDouble(),
      scansToday: json['scansToday'],
      scansWeek: json['scansWeek'],
      erreursIA: json['erreursIA'],
      documentsEnAttente:
          json['documentsEnAttente'],
      documentsSignes:
          json['documentsSignes'],
    );
  }
}

class CongeDashboard {
  final int absentToday;

  final int demandesEnAttente;
  final int demandesAcceptees;
  final int demandesRefusees;

  final int congesAnnuels;
  final int congesMaladie;
  final int congesSansSolde;

  final int chefsEscalesAbsents;
  final int chefsEquipesAbsents;
  final int employesAbsents;

  CongeDashboard.fromJson(
      Map<String, dynamic> json)
      : absentToday = json['absentToday'],
        demandesEnAttente =
            json['demandesEnAttente'],
        demandesAcceptees =
            json['demandesAcceptees'],
        demandesRefusees =
            json['demandesRefusees'],
        congesAnnuels =
            json['congesAnnuels'],
        congesMaladie =
            json['congesMaladie'],
        congesSansSolde =
            json['congesSansSolde'],
        chefsEscalesAbsents =
            json['chefsEscalesAbsents'],
        chefsEquipesAbsents =
            json['chefsEquipesAbsents'],
        employesAbsents =
            json['employesAbsents'];
}

class ArretStats {
  final String cause;
  final int nombre;

  ArretStats({
    required this.cause,
    required this.nombre,
  });

  factory ArretStats.fromJson(
      Map<String, dynamic> json) {
    return ArretStats(
      cause: json['cause'],
      nombre: json['nombre'],
    );
  }
}

class ArretDashboard {
  final int totalArrets;
  final int arretsToday;

  final int arretsWeek;

  final int tempsPerduTotal;

  final double avgDuration;

  final double tauxBlocageOperations;

  final List<ArretStats> topCauses;

  ArretDashboard.fromJson(
      Map<String, dynamic> json)
      : totalArrets =
            json['totalArrets'],
        arretsToday =
            json['arretsToday'],
        arretsWeek =
            json['arretsWeek'],
        tempsPerduTotal =
            json['tempsPerduTotal'],
        avgDuration =
            (json['avgDuration'])
                .toDouble(),
        tauxBlocageOperations =
            (json[
                    'tauxBlocageOperations'])
                .toDouble(),
        topCauses =
            (json['topCauses']
                    as List)
                .map(
                  (e) =>
                      ArretStats.fromJson(
                          e),
                )
                .toList();
}

class EnginKPI {
  final int enginId;
  final String typeEngin;
  final int totalOperations;

  EnginKPI.fromJson(
      Map<String, dynamic> json)
      : enginId = json['enginId'],
        typeEngin =
            json['typeEngin'],
        totalOperations =
            json['totalOperations'];
}

class EnginUsageRate {
  final int enginId;

  final String typeEngin;

  final double tauxUtilisation;

  EnginUsageRate.fromJson(
      Map<String, dynamic> json)
      : enginId = json['enginId'],
        typeEngin =
            json['typeEngin'],
        tauxUtilisation =
            (json[
                    'tauxUtilisation'])
                .toDouble();
}

class EscaleKPI {
  final String numeroEscale;
  final String nomNavire;
  final int totalOperations;

  EscaleKPI.fromJson(
      Map<String, dynamic> json)
      : numeroEscale =
            json['numeroEscale'],
        nomNavire =
            json['nomNavire'],
        totalOperations =
            json['totalOperations'];
}

class EquipeKPI {
  final int equipeId;

  final String matriculeEquipe;

  final int totalOperations;

  final int totalConteneurs;

  EquipeKPI.fromJson(
      Map<String, dynamic> json)
      : equipeId = json['equipeId'],
        matriculeEquipe =
            json['matriculeEquipe'],
        totalOperations =
            json['totalOperations'],
        totalConteneurs =
            json['totalConteneurs'];
}

class SignatureDocument {
  final int id;

  final String statut;

  final String? pdfPath;

  final String? draftPdfPath;

  final DateTime? dateGeneration;

  SignatureDocument({
    required this.id,
    required this.statut,
    this.pdfPath,
    this.draftPdfPath,
    this.dateGeneration,
  });

  factory SignatureDocument.fromJson(
      Map<String, dynamic> json) {
    return SignatureDocument(
      id: json['id'],
      statut:
          json['statut'] ?? '',
      pdfPath:
          json['pdfPath'],
      draftPdfPath:
          json['draftPdfPath'],
      dateGeneration:
          json['dateGeneration'] != null
              ? DateTime.parse(
                  json['dateGeneration'],
                )
              : null,
    );
  }
}

class SignaturePersonnel {
  final int id;

  final String nom;

  final String prenom;

  final String email;

  final String role;

  final String? imageURL;

  SignaturePersonnel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.imageURL,
  });

  String? get formattedImage =>
      ApiConfig.fixUrl(imageURL);

  factory SignaturePersonnel.fromJson(
      Map<String, dynamic> json) {
    return SignaturePersonnel(
      id: json['id'],
      nom:
          json['nom'] ?? '',
      prenom:
          json['prenom'] ?? '',
      email:
          json['email'] ?? '',
      role:
          json['role'] ?? '',
      imageURL:
          json['imageURL'],
    );
  }
}

class OperationResponsableModel {

  final int id;

  final String role;

  final int ordreSignature;

  final String statut;

  final DateTime? dateSignature;

  final SignaturePersonnel?
      personnel;

  OperationResponsableModel({
    required this.id,
    required this.role,
    required this.ordreSignature,
    required this.statut,
    this.dateSignature,
    this.personnel,
  });

  factory OperationResponsableModel
      .fromJson(
      Map<String, dynamic> json) {

    return OperationResponsableModel(

      id: json['id'],

      role:
          json['role'] ?? '',

      ordreSignature:
          json[
              'ordreSignature'] ??
              0,

      statut:
          json['statut'] ?? '',

      dateSignature:
          json['dateSignature'] !=
                  null
              ? DateTime.parse(
                  json[
                      'dateSignature'],
                )
              : null,

      personnel:
          json['personnel'] !=
                  null
              ? SignaturePersonnel
                  .fromJson(
                  json[
                      'personnel'],
                )
              : null,
    );
  }
}

class SignatureModel {

  final int id;

  final DateTime? dateSignature;

  final String statut;

  final String? signaturePath;

  final SignatureDocument?
      document;

  final SignaturePersonnel?
      signataire;

  final OperationResponsableModel?
      operationResponsable;

  SignatureModel({

    required this.id,

    required this.statut,

    this.dateSignature,

    this.signaturePath,

    this.document,

    this.signataire,

    this.operationResponsable,
  });

  factory SignatureModel.fromJson(
      Map<String, dynamic> json) {

    return SignatureModel(

      id: json['id'],

      statut:
          json['statut'] ?? '',

      signaturePath:
          json[
              'signaturePath'],

      dateSignature:
          json['dateSignature'] !=
                  null
              ? DateTime.parse(
                  json[
                      'dateSignature'],
                )
              : null,

      document:
          json['document'] !=
                  null
              ? SignatureDocument
                  .fromJson(
                  json[
                      'document'],
                )
              : null,

      signataire:
          json['signataire'] !=
                  null
              ? SignaturePersonnel
                  .fromJson(
                  json[
                      'signataire'],
                )
              : null,

      operationResponsable:
          json[
                      'operationResponsable'] !=
                  null
              ? OperationResponsableModel
                  .fromJson(
                  json[
                      'operationResponsable'],
                )
              : null,
    );
  }
}