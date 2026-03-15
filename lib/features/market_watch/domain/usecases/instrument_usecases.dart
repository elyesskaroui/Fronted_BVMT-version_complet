import '../entities/instrument_entity.dart';
import '../repositories/instrument_repository.dart';

/// Use case — Récupérer les instruments par marché
class GetInstrumentsByMarket {
  final InstrumentRepository _repository;
  GetInstrumentsByMarket(this._repository);

  Future<List<InstrumentEntity>> call(InstrumentMarket market) =>
      _repository.getInstrumentsByMarket(market);
}

/// Use case — Rechercher des instruments
class SearchInstruments {
  final InstrumentRepository _repository;
  SearchInstruments(this._repository);

  Future<List<InstrumentEntity>> call(String query, InstrumentMarket market) =>
      _repository.searchInstruments(query, market);
}
