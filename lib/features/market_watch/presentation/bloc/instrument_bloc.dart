import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/instrument_entity.dart';
import '../../domain/usecases/instrument_usecases.dart';
import 'instrument_event.dart';
import 'instrument_state.dart';

/// BLoC Instruments — gère les données du tableau Instruments
/// Pattern : cache-first via GetStorage + fetch frais
class InstrumentBloc extends Bloc<InstrumentEvent, InstrumentState> {
  final GetInstrumentsByMarket getInstrumentsByMarket;
  final SearchInstruments searchInstruments;
  final LocalStorageService localStorage;

  InstrumentBloc({
    required this.getInstrumentsByMarket,
    required this.searchInstruments,
    required this.localStorage,
  }) : super(const InstrumentInitial()) {
    on<InstrumentLoadRequested>(_onLoadRequested);
    on<InstrumentMarketChanged>(_onMarketChanged);
    on<InstrumentSearchChanged>(_onSearchChanged);
    on<InstrumentSortRequested>(_onSortRequested);
    on<InstrumentRefreshRequested>(_onRefreshRequested);
  }

  // ═══════════════════════════════════════════
  // ── Event Handlers ──
  // ═══════════════════════════════════════════

  Future<void> _onLoadRequested(
    InstrumentLoadRequested event,
    Emitter<InstrumentState> emit,
  ) async {
    const market = InstrumentMarket.actions;

    // 1. Essayer le cache d'abord
    final cached = _readCache(market);
    if (cached != null && cached.isNotEmpty) {
      emit(InstrumentLoaded(
        allInstruments: cached,
        displayedInstruments: cached,
        currentMarket: market,
      ));
    } else {
      emit(const InstrumentLoading());
    }

    // 2. Fetch frais
    await _loadMarket(emit, market);
  }

  Future<void> _onMarketChanged(
    InstrumentMarketChanged event,
    Emitter<InstrumentState> emit,
  ) async {
    // Montrer le cache si disponible
    final cached = _readCache(event.market);
    if (cached != null && cached.isNotEmpty) {
      emit(InstrumentLoaded(
        allInstruments: cached,
        displayedInstruments: cached,
        currentMarket: event.market,
      ));
    } else {
      emit(const InstrumentLoading());
    }

    await _loadMarket(emit, event.market);
  }

  Future<void> _onSearchChanged(
    InstrumentSearchChanged event,
    Emitter<InstrumentState> emit,
  ) async {
    if (state is! InstrumentLoaded) return;
    final current = state as InstrumentLoaded;
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(current.copyWith(
        displayedInstruments: current.allInstruments,
        searchQuery: '',
      ));
      return;
    }

    final filtered = current.allInstruments
        .where((i) =>
            i.mnemo.toLowerCase().contains(query) ||
            i.valeur.toLowerCase().contains(query))
        .toList();

    emit(current.copyWith(
      displayedInstruments: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onSortRequested(
    InstrumentSortRequested event,
    Emitter<InstrumentState> emit,
  ) async {
    if (state is! InstrumentLoaded) return;
    final current = state as InstrumentLoaded;

    final sorted = List<InstrumentEntity>.from(current.displayedInstruments);
    final asc = event.ascending;

    sorted.sort((a, b) {
      switch (event.column) {
        case 'mnemo':
          return asc ? a.mnemo.compareTo(b.mnemo) : b.mnemo.compareTo(a.mnemo);
        case 'valeur':
          return asc ? a.valeur.compareTo(b.valeur) : b.valeur.compareTo(a.valeur);
        case 'dernier':
          return asc ? a.dernier.compareTo(b.dernier) : b.dernier.compareTo(a.dernier);
        case 'variation':
          return asc ? a.variation.compareTo(b.variation) : b.variation.compareTo(a.variation);
        case 'capitaux':
          return asc ? a.capitaux.compareTo(b.capitaux) : b.capitaux.compareTo(a.capitaux);
        case 'quantite':
          return asc ? a.quantite.compareTo(b.quantite) : b.quantite.compareTo(a.quantite);
        default:
          return 0;
      }
    });

    emit(current.copyWith(
      displayedInstruments: sorted,
      sortColumn: event.column,
      sortAscending: event.ascending,
    ));
  }

  Future<void> _onRefreshRequested(
    InstrumentRefreshRequested event,
    Emitter<InstrumentState> emit,
  ) async {
    if (state is InstrumentLoaded) {
      await _loadMarket(emit, (state as InstrumentLoaded).currentMarket);
    } else {
      await _loadMarket(emit, InstrumentMarket.actions);
    }
  }

  // ═══════════════════════════════════════════
  // ── Private Helpers ──
  // ═══════════════════════════════════════════

  Future<void> _loadMarket(
    Emitter<InstrumentState> emit,
    InstrumentMarket market,
  ) async {
    try {
      final instruments = await getInstrumentsByMarket(market);
      _writeCache(market, instruments);

      final query = state is InstrumentLoaded
          ? (state as InstrumentLoaded).searchQuery
          : '';

      final displayed = query.isEmpty
          ? instruments
          : instruments
              .where((i) =>
                  i.mnemo.toLowerCase().contains(query.toLowerCase()) ||
                  i.valeur.toLowerCase().contains(query.toLowerCase()))
              .toList();

      emit(InstrumentLoaded(
        allInstruments: instruments,
        displayedInstruments: displayed,
        currentMarket: market,
        searchQuery: query,
      ));
    } catch (e) {
      if (state is! InstrumentLoaded) {
        emit(InstrumentError('Erreur : ${e.toString()}'));
      }
    }
  }

  // ═══════════════════════════════════════════
  // ── CACHE GetStorage ──
  // ═══════════════════════════════════════════

  static const _cacheVersion = 'v4_'; // bump to invalidate old cache
  static const _cachePrefix = 'instruments_${_cacheVersion}data_';
  static const _cacheTsPrefix = 'instruments_${_cacheVersion}ts_';
  static const _cacheDuration = Duration(minutes: 30);

  void _writeCache(InstrumentMarket market, List<InstrumentEntity> instruments) {
    final key = '$_cachePrefix${market.name}';
    final tsKey = '$_cacheTsPrefix${market.name}';
    final jsonList = instruments
        .map((i) => {
              'mnemo': i.mnemo,
              'valeur': i.valeur,
              'statut': i.statut,
              'qteAchat': i.qteAchat,
              'achat': i.achat,
              'vente': i.vente,
              'qteVente': i.qteVente,
              'dernier': i.dernier,
              'coursRef': i.coursRef,
              'variation': i.variation,
              'capitaux': i.capitaux,
              'quantite': i.quantite,
              'nbTransactions': i.nbTransactions,
              'ouverture': i.ouverture,
              'plusHaut': i.plusHaut,
              'plusBas': i.plusBas,
              'seuilHaut': i.seuilHaut,
              'seuilBas': i.seuilBas,
              'capitBlocs': i.capitBlocs,
              'qteBlocs': i.qteBlocs,
              'nbTransBlocs': i.nbTransBlocs,
              'market': i.market.name,
            })
        .toList();
    localStorage.writeRaw(key, jsonEncode(jsonList));
    localStorage.writeRaw(tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  List<InstrumentEntity>? _readCache(InstrumentMarket market) {
    final key = '$_cachePrefix${market.name}';
    final tsKey = '$_cacheTsPrefix${market.name}';

    final raw = localStorage.readRaw<String>(key);
    final ts = localStorage.readRaw<int>(tsKey);

    if (raw == null || ts == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) {
      localStorage.removeRaw(key);
      localStorage.removeRaw(tsKey);
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) {
        final marketStr = item['market'] as String;
        final marketEnum = InstrumentMarket.values.firstWhere(
          (m) => m.name == marketStr,
          orElse: () => InstrumentMarket.actions,
        );
        return InstrumentEntity(
          mnemo: item['mnemo'] as String,
          valeur: item['valeur'] as String,
          statut: item['statut'] as String,
          qteAchat: (item['qteAchat'] as num).toInt(),
          achat: (item['achat'] as num).toDouble(),
          vente: (item['vente'] as num).toDouble(),
          qteVente: (item['qteVente'] as num).toInt(),
          dernier: (item['dernier'] as num).toDouble(),
          coursRef: (item['coursRef'] as num).toDouble(),
          variation: (item['variation'] as num).toDouble(),
          capitaux: (item['capitaux'] as num).toDouble(),
          quantite: (item['quantite'] as num).toInt(),
          nbTransactions: (item['nbTransactions'] as num).toInt(),
          ouverture: (item['ouverture'] as num).toDouble(),
          plusHaut: (item['plusHaut'] as num).toDouble(),
          plusBas: (item['plusBas'] as num).toDouble(),
          seuilHaut: (item['seuilHaut'] as num).toDouble(),
          seuilBas: (item['seuilBas'] as num).toDouble(),
          capitBlocs: item['capitBlocs'] != null ? (item['capitBlocs'] as num).toDouble() : null,
          qteBlocs: item['qteBlocs'] != null ? (item['qteBlocs'] as num).toInt() : null,
          nbTransBlocs: item['nbTransBlocs'] != null ? (item['nbTransBlocs'] as num).toInt() : null,
          market: marketEnum,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }
}
