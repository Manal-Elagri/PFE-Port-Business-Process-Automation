import 'package:flutter/material.dart';
import '../config/api_config.dart';


class ScanRequestDTO {
  final int operationId;
  final String? mobileScanId;
  final String? deviceId;
  final String? matricule;
  final String? typeIso;
  final double? score;
  final bool? offlineMode;

  ScanRequestDTO({
    required this.operationId,
    this.mobileScanId,
    this.deviceId,
    this.matricule,
    this.typeIso,
    this.score,
    this.offlineMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'mobileScanId': mobileScanId,
      'deviceId': deviceId,
      'matricule': matricule,
      'typeIso': typeIso,
      'score': score,
      'offlineMode': offlineMode,
    };
  }
}

class ScanValidationRequestDTO {
  final int scanId;
  final String? matriculeCorrige;
  final String? typeIsoCorrige;

  ScanValidationRequestDTO({
    required this.scanId,
    this.matriculeCorrige,
    this.typeIsoCorrige,
  });

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'matriculeCorrige': matriculeCorrige,
      'typeIsoCorrige': typeIsoCorrige,
    };
  }
}

class ScanResponseDTO {
  final int? id;
  final String? matricule;
  final String? typeIso;
  final double? score;
  final String? statut;
  final DateTime? date;

  ScanResponseDTO({
    this.id,
    this.matricule,
    this.typeIso,
    this.score,
    this.statut,
    this.date,
  });

  factory ScanResponseDTO.fromJson(Map<String, dynamic> json) {
    return ScanResponseDTO(
      id: (json['id'] as num?)?.toInt(),
      matricule: json['matricule'] as String?,
      typeIso: json['typeIso'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      statut: json['statut'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'typeIso': typeIso,
      'score': score,
      'statut': statut,
      'date': date?.toIso8601String(),
    };
  }
}

class StartOperationRequest {
  final String type;
  final int escaleId;
  final int posteId;
  final int portierId;
  final List<int> enginIds;
  final int nombreConteneurs;

  StartOperationRequest({
    required this.type,
    required this.escaleId,
    required this.posteId,
    required this.portierId,
    required this.enginIds,
    this.nombreConteneurs = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'escaleId': escaleId,
      'posteId': posteId,
      'portierId': portierId,
      'enginIds': enginIds,
      'nombreConteneurs': nombreConteneurs,
    };
  }
}
class OperationResponseDTO {
  final int? id;
  final String? statut;
  final DateTime? dateDebut;
  final int? nombreConteneurs;
OperationResponseDTO({
    this.id,
    this.statut,
    this.dateDebut,
    this.nombreConteneurs,
  });

  factory OperationResponseDTO.fromJson(Map<String, dynamic> json) {
    return OperationResponseDTO(
      id: (json['id'] as num?)?.toInt(),
      statut: json['statut'],
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      nombreConteneurs: (json['nombreConteneurs'] as num?)?.toInt(),
    );
  }
}

class ArretDTO {
  final int? id;
  final String? type;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? cause;

  ArretDTO({
    this.id,
    this.type,
    this.dateDebut,
    this.dateFin,
    this.cause,
  });

  factory ArretDTO.fromJson(Map<String, dynamic> json) {
    return ArretDTO(
      id: (json['id'] as num?)?.toInt(),
      type: json['type'],
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.parse(json['dateFin'])
          : null,
      cause: json['cause'],
    );
  }
}