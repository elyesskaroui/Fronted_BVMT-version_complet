import 'dart:math';

import '../../domain/entities/instrument_detail_models.dart';
import '../../domain/entities/instrument_entity.dart';
import 'sitex_order_book_data.dart';
import 'sts_order_book_data.dart';

// ==========================================================================
// Mock DataSource pour les détails d'un instrument
// Génère des données réalistes pour les 5 onglets
// ==========================================================================
class InstrumentDetailMockDataSource {
  /// Génère un carnet d'ordres mock
  Future<OrderBook> getOrderBook(InstrumentEntity instrument) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Lignes Secondaires / Obligations → aucun ordre
    if (instrument.market == InstrumentMarket.lignesSecondaires ||
        instrument.market == InstrumentMarket.obligations) {
      return const OrderBook(ordresAchat: [], ordresVente: []);
    }

    // SITEX → données réelles BVMT
    if (instrument.mnemo == 'SITEX') {
      return sitexOrderBook;
    }

    // STS → données réelles BVMT
    if (instrument.mnemo == 'STS') {
      return stsOrderBook;
    }

    final rng = Random(instrument.mnemo.hashCode);
    final basePrice = instrument.dernier;

    // Ordres d'achat (prix décroissant à partir du prix actuel)
    final ordresAchat = List.generate(5, (i) {
      final spread = (i + 1) * (basePrice * 0.002);
      return OrderBookEntry(
        nbrOrdres: rng.nextInt(5) + 1,
        quantite: (rng.nextInt(400) + 20) ~/ 10 * 10,
        prix: double.parse((basePrice - spread).toStringAsFixed(3)),
      );
    });

    // Ordres de vente (prix croissant à partir du prix actuel)
    final ordresVente = List.generate(5, (i) {
      final spread = (i + 1) * (basePrice * 0.003);
      return OrderBookEntry(
        nbrOrdres: rng.nextInt(6) + 1,
        quantite: (rng.nextInt(350) + 10) ~/ 10 * 10,
        prix: double.parse((basePrice + spread).toStringAsFixed(3)),
      );
    });

    return OrderBook(ordresAchat: ordresAchat, ordresVente: ordresVente);
  }

  /// Génère des transactions mock
  Future<List<StockTransaction>> getTransactions(
      InstrumentEntity instrument) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Lignes Secondaires / Obligations / Marché Hors Cote → aucune transaction
    if (instrument.market == InstrumentMarket.lignesSecondaires ||
        instrument.market == InstrumentMarket.obligations ||
        instrument.market == InstrumentMarket.marcheHorsCote) {
      return [];
    }

    final rng = Random(instrument.mnemo.hashCode + 42);
    final basePrice = instrument.dernier;

    return List.generate(15, (i) {
      final hour = 12 - (i ~/ 4);
      final minute = rng.nextInt(60);
      final second = rng.nextInt(60);
      final qty = (rng.nextInt(250) + 5);
      final price =
          basePrice + (rng.nextDouble() - 0.5) * basePrice * 0.005;
      final roundedPrice = double.parse(price.toStringAsFixed(3));

      return StockTransaction(
        heure:
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
        quantite: qty,
        prix: roundedPrice,
        capitauxEchanges: double.parse((roundedPrice * qty).toStringAsFixed(0)),
        typeTransaction: rng.nextBool() ? 'COC' : 'OPE',
      );
    });
  }

  /// Génère des publications mock
  Future<List<StockPublication>> getPublications(
      InstrumentEntity instrument) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Lignes Secondaires / Obligations / Marché Hors Cote → aucune publication
    if (instrument.market == InstrumentMarket.lignesSecondaires ||
        instrument.market == InstrumentMarket.obligations ||
        instrument.market == InstrumentMarket.marcheHorsCote) {
      return [];
    }

    final pubTitles = [
      '${instrument.valeur} - Déclaration des opérations significatives',
      '${instrument.valeur} - Rapport annuel exercice 2025',
      '${instrument.valeur} - Avis de convocation AGO',
      '${instrument.valeur} - États financiers intermédiaires',
      '${instrument.valeur} - Résolutions AGO',
      '${instrument.valeur} - Indicateurs d\'activité T4 2025',
      '${instrument.valeur} - Communication financière',
    ];

    final dates = [
      '28/11/2025',
      '28/11/2025',
      '15/10/2025',
      '30/09/2025',
      '15/06/2025',
      '31/03/2025',
      '15/02/2025',
    ];

    return List.generate(pubTitles.length, (i) {
      return StockPublication(
        date: dates[i],
        titre: pubTitles[i],
      );
    });
  }

  /// Génère des données de graphique (30 points par défaut = 1M)
  Future<List<double>> getChartData(InstrumentEntity instrument) async {
    return getChartDataForPeriod(instrument, '1M');
  }

  /// Génère des données de graphique selon la période sélectionnée
  /// 1J=24pts (heures), 1S=7pts (jours), 1M=30pts, 3M=90pts, 6M=180pts, 1A=365pts
  Future<List<double>> getChartDataForPeriod(
      InstrumentEntity instrument, String period) async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Marché Hors Cote → aucune donnée graphique
    if (instrument.market == InstrumentMarket.marcheHorsCote) {
      return [];
    }

    // Nombre de points et volatilité selon la période
    final int nbPoints;
    final double volatility;
    final int seedOffset;

    switch (period) {
      case '1J':
        nbPoints = 24; // 1 point par heure
        volatility = 0.015; // faible volatilité intraday
        seedOffset = 1;
        break;
      case '1S':
        nbPoints = 7; // 1 point par jour
        volatility = 0.025;
        seedOffset = 7;
        break;
      case '1M':
        nbPoints = 30; // 1 point par jour
        volatility = 0.04;
        seedOffset = 30;
        break;
      case '3M':
        nbPoints = 45; // 1 point tous les 2 jours
        volatility = 0.06;
        seedOffset = 90;
        break;
      case '6M':
        nbPoints = 50; // 1 point par ~3.6 jours
        volatility = 0.08;
        seedOffset = 180;
        break;
      case '1A':
        nbPoints = 52; // 1 point par semaine
        volatility = 0.12;
        seedOffset = 365;
        break;
      default:
        nbPoints = 30;
        volatility = 0.04;
        seedOffset = 30;
    }

    final rng = Random(instrument.mnemo.hashCode + seedOffset);
    final basePrice = instrument.dernier;

    // Génère un parcours de prix réaliste (random walk)
    final data = <double>[];
    double price = basePrice * (1 - volatility / 2 + rng.nextDouble() * volatility);

    for (int i = 0; i < nbPoints; i++) {
      // Random walk avec tendance vers le prix actuel
      final drift = (basePrice - price) * 0.03; // mean-reversion
      final noise = (rng.nextDouble() - 0.5) * basePrice * volatility * 0.15;
      price += drift + noise;
      price = price.clamp(basePrice * (1 - volatility), basePrice * (1 + volatility));
      data.add(double.parse(price.toStringAsFixed(3)));
    }

    // Dernier point = prix actuel
    data[data.length - 1] = basePrice;
    return data;
  }
}
