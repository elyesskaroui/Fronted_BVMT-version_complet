import 'package:equatable/equatable.dart';
import '../../domain/entities/instrument_entity.dart';

/// Événements BLoC — Instruments
abstract class InstrumentEvent extends Equatable {
  const InstrumentEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial des instruments
class InstrumentLoadRequested extends InstrumentEvent {
  const InstrumentLoadRequested();
}

/// Changement de marché (Actions / Lignes secondaires / Obligations / Hors cote)
class InstrumentMarketChanged extends InstrumentEvent {
  final InstrumentMarket market;
  const InstrumentMarketChanged(this.market);
  @override
  List<Object?> get props => [market];
}

/// Recherche d'instruments
class InstrumentSearchChanged extends InstrumentEvent {
  final String query;
  const InstrumentSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Tri par colonne
class InstrumentSortRequested extends InstrumentEvent {
  final String column;
  final bool ascending;
  const InstrumentSortRequested({required this.column, required this.ascending});
  @override
  List<Object?> get props => [column, ascending];
}

/// Rafraîchissement automatique (timer interne — polling temps réel)
class InstrumentAutoRefreshTick extends InstrumentEvent {
  const InstrumentAutoRefreshTick();
}

/// Rafraîchissement des données
class InstrumentRefreshRequested extends InstrumentEvent {
  const InstrumentRefreshRequested();
}
