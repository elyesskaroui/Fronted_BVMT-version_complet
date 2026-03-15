import '../entities/instrument_entity.dart';

/// Contrat du repository Instruments
abstract class InstrumentRepository {
  /// Récupère tous les instruments d'un marché donné
  Future<List<InstrumentEntity>> getInstrumentsByMarket(InstrumentMarket market);

  /// Recherche parmi les instruments
  Future<List<InstrumentEntity>> searchInstruments(
    String query,
    InstrumentMarket market,
  );
}
