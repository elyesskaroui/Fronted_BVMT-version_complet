import 'package:equatable/equatable.dart';

// ==========================================================================
// Modèles de données pour le détail d'un instrument BVMT
// Carnet d'ordres, Transactions, Publications
// ==========================================================================

/// Entrée dans le carnet d'ordres (achat ou vente)
class OrderBookEntry extends Equatable {
  final int nbrOrdres;
  final int quantite;
  final double prix; // -1 = MO (Market Order)

  const OrderBookEntry({
    required this.nbrOrdres,
    required this.quantite,
    required this.prix,
  });

  /// Whether this is a Market Order (prix au marché)
  bool get isMO => prix < 0;

  /// Display string for the price
  String get prixDisplay => isMO ? 'MO' : prix.toStringAsFixed(3);

  @override
  List<Object?> get props => [nbrOrdres, quantite, prix];
}

/// Carnet d'ordres complet (achat + vente)
class OrderBook extends Equatable {
  final List<OrderBookEntry> ordresAchat;
  final List<OrderBookEntry> ordresVente;

  const OrderBook({
    required this.ordresAchat,
    required this.ordresVente,
  });

  /// Quantité max pour calculer les barres proportionnelles
  int get maxQuantite {
    int max = 0;
    for (final e in [...ordresAchat, ...ordresVente]) {
      if (e.quantite > max) max = e.quantite;
    }
    return max == 0 ? 1 : max;
  }

  @override
  List<Object?> get props => [ordresAchat, ordresVente];
}

/// Transaction boursière
class StockTransaction extends Equatable {
  final String heure;
  final int quantite;
  final double prix;
  final double capitauxEchanges;
  final String typeTransaction;

  const StockTransaction({
    required this.heure,
    required this.quantite,
    required this.prix,
    required this.capitauxEchanges,
    required this.typeTransaction,
  });

  @override
  List<Object?> get props =>
      [heure, quantite, prix, capitauxEchanges, typeTransaction];
}

/// Publication boursière
class StockPublication extends Equatable {
  final String date;
  final String titre;
  final String? description;

  const StockPublication({
    required this.date,
    required this.titre,
    this.description,
  });

  @override
  List<Object?> get props => [date, titre, description];
}
