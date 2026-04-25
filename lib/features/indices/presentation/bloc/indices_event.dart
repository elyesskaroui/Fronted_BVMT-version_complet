import 'package:equatable/equatable.dart';

/// Événements BLoC — Indices
abstract class IndicesEvent extends Equatable {
  const IndicesEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial
class IndicesLoadRequested extends IndicesEvent {
  const IndicesLoadRequested();
}

/// Rafraîchissement (pull-to-refresh)
class IndicesRefreshRequested extends IndicesEvent {
  const IndicesRefreshRequested();
}

/// Recherche
class IndicesSearchChanged extends IndicesEvent {
  final String query;
  const IndicesSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Tri par colonne
class IndicesSortRequested extends IndicesEvent {
  final IndicesSortColumn column;
  const IndicesSortRequested(this.column);
  @override
  List<Object?> get props => [column];
}

/// Changement d'indice sélectionné (TUNINDEX, TUNINDEX20, etc.)
class IndicesIndexChanged extends IndicesEvent {
  final String indexName;
  const IndicesIndexChanged(this.indexName);
  @override
  List<Object?> get props => [indexName];
}

/// Changement de période du chart (15M, 1H, 3H, ALL)
class IndicesChartPeriodChanged extends IndicesEvent {
  final String period;
  const IndicesChartPeriodChanged(this.period);
  @override
  List<Object?> get props => [period];
}

/// Rafraîchissement automatique (timer interne — polling temps réel)
class IndicesAutoRefreshTick extends IndicesEvent {
  const IndicesAutoRefreshTick();
}

/// Colonnes de tri disponibles
enum IndicesSortColumn {
  name,
  openPrice,
  closePrice,
  changePercent,
  transactions,
  volume,
  capitaux,
}
