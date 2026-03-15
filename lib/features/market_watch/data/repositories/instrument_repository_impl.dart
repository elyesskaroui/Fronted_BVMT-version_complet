import '../../domain/entities/instrument_entity.dart';
import '../../domain/repositories/instrument_repository.dart';
import '../datasources/instrument_mock_datasource.dart';

/// Implémentation concrète du repository Instruments
class InstrumentRepositoryImpl implements InstrumentRepository {
  final InstrumentMockDataSource _dataSource;

  InstrumentRepositoryImpl({required InstrumentMockDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<InstrumentEntity>> getInstrumentsByMarket(
      InstrumentMarket market) =>
      _dataSource.getByMarket(market);

  @override
  Future<List<InstrumentEntity>> searchInstruments(
    String query,
    InstrumentMarket market,
  ) =>
      _dataSource.searchInMarket(query, market);
}
