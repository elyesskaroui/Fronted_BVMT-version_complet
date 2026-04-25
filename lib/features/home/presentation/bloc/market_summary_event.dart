import 'package:equatable/equatable.dart';

/// Events pour le BLoC du résumé marché
abstract class MarketSummaryEvent extends Equatable {
  const MarketSummaryEvent();
  @override
  List<Object?> get props => [];
}

/// Demande de chargement initial
class MarketSummaryLoadRequested extends MarketSummaryEvent {
  const MarketSummaryLoadRequested();
}

/// Demande de rafraîchissement (pull-to-refresh)
class MarketSummaryRefreshRequested extends MarketSummaryEvent {
  const MarketSummaryRefreshRequested();
}

/// Rafraîchissement automatique (timer interne — polling temps réel)
class MarketSummaryAutoRefreshTick extends MarketSummaryEvent {
  const MarketSummaryAutoRefreshTick();
}

/// Changement de page dans le slider résumé
class MarketSummaryPageChanged extends MarketSummaryEvent {
  final int page;
  const MarketSummaryPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}
