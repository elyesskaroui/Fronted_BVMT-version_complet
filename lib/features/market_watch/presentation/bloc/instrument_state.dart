import 'package:equatable/equatable.dart';
import '../../domain/entities/instrument_entity.dart';

/// États BLoC — Instruments
abstract class InstrumentState extends Equatable {
  const InstrumentState();
  @override
  List<Object?> get props => [];
}

/// État initial
class InstrumentInitial extends InstrumentState {
  const InstrumentInitial();
}

/// Chargement en cours
class InstrumentLoading extends InstrumentState {
  const InstrumentLoading();
}

/// Données chargées avec succès
class InstrumentLoaded extends InstrumentState {
  final List<InstrumentEntity> allInstruments;
  final List<InstrumentEntity> displayedInstruments;
  final InstrumentMarket currentMarket;
  final String searchQuery;
  final String sortColumn;
  final bool sortAscending;

  const InstrumentLoaded({
    required this.allInstruments,
    required this.displayedInstruments,
    required this.currentMarket,
    this.searchQuery = '',
    this.sortColumn = 'mnemo',
    this.sortAscending = true,
  });

  InstrumentLoaded copyWith({
    List<InstrumentEntity>? allInstruments,
    List<InstrumentEntity>? displayedInstruments,
    InstrumentMarket? currentMarket,
    String? searchQuery,
    String? sortColumn,
    bool? sortAscending,
  }) {
    return InstrumentLoaded(
      allInstruments: allInstruments ?? this.allInstruments,
      displayedInstruments: displayedInstruments ?? this.displayedInstruments,
      currentMarket: currentMarket ?? this.currentMarket,
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
        allInstruments,
        displayedInstruments,
        currentMarket,
        searchQuery,
        sortColumn,
        sortAscending,
      ];
}

/// Erreur
class InstrumentError extends InstrumentState {
  final String message;
  const InstrumentError(this.message);
  @override
  List<Object?> get props => [message];
}
