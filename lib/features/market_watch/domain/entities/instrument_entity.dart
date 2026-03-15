import 'package:equatable/equatable.dart';

/// Type de marché pour un instrument
enum InstrumentMarket { actions, lignesSecondaires, obligations, marcheHorsCote }

/// Entité métier — Données complètes d'un instrument BVMT
class InstrumentEntity extends Equatable {
  final String mnemo;
  final String valeur;
  final String statut; // "Open" / "Closed"
  final int qteAchat;
  final double achat;
  final double vente;
  final int qteVente;
  final double dernier;
  final double coursRef;
  final double variation; // en %
  final double capitaux;
  final int quantite;
  final int nbTransactions;
  final double ouverture;
  final double plusHaut;
  final double plusBas;
  final double? cto;
  final double? vto;
  final double seuilHaut;
  final double seuilBas;
  final double? capitBlocs;
  final int? qteBlocs;
  final int? nbTransBlocs;
  final InstrumentMarket market;

  const InstrumentEntity({
    required this.mnemo,
    required this.valeur,
    required this.statut,
    required this.qteAchat,
    required this.achat,
    required this.vente,
    required this.qteVente,
    required this.dernier,
    required this.coursRef,
    required this.variation,
    required this.capitaux,
    required this.quantite,
    required this.nbTransactions,
    required this.ouverture,
    required this.plusHaut,
    required this.plusBas,
    this.cto,
    this.vto,
    this.seuilHaut = 0,
    this.seuilBas = 0,
    this.capitBlocs,
    this.qteBlocs,
    this.nbTransBlocs,
    required this.market,
  });

  bool get isPositive => variation >= 0;
  bool get isNegative => variation < 0;
  bool get isNeutral => variation == 0;

  @override
  List<Object?> get props => [
        mnemo,
        valeur,
        statut,
        qteAchat,
        achat,
        vente,
        qteVente,
        dernier,
        coursRef,
        variation,
        capitaux,
        quantite,
        nbTransactions,
        ouverture,
        plusHaut,
        plusBas,
        cto,
        vto,
        seuilHaut,
        seuilBas,
        capitBlocs,
        qteBlocs,
        nbTransBlocs,
        market,
      ];
}
