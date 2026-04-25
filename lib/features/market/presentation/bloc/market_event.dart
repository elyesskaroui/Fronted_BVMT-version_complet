import 'package:equatable/equatable.dart';

/// Événements BLoC — Market
abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object?> get props => [];
}

/// Chargement initial de toutes les données du marché
class MarketLoadRequested extends MarketEvent {
  const MarketLoadRequested();
}

/// Rafraîchissement (pull-to-refresh)
class MarketRefreshRequested extends MarketEvent {
  const MarketRefreshRequested();
}

/// Recherche d'une action
class MarketSearchRequested extends MarketEvent {
  final String query;
  const MarketSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Rafraîchissement automatique (timer interne — polling temps réel)
class MarketAutoRefreshTick extends MarketEvent {
  const MarketAutoRefreshTick();
}

/// Changement d'onglet (Toutes / Hausse / Baisse / Volume)
class MarketTabChanged extends MarketEvent {
  final int tabIndex;
  const MarketTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
