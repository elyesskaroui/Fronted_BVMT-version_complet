import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../domain/entities/news_entity.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRemoteDataSource dataSource;

  NewsBloc({required this.dataSource}) : super(const NewsInitial()) {
    on<NewsLoadRequested>(_onLoad);
    on<NewsCategoryChanged>(_onCategoryChanged);
    on<NewsRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoad(NewsLoadRequested event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());
    try {
      final allNews = await dataSource.getAllNews();

      // Extraire les catégories dynamiquement depuis les données
      final dynamicCategories = allNews
          .map((n) => n.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final categories = ['Tout', ...dynamicCategories];

      emit(NewsLoaded(
        allNews: allNews,
        filteredNews: allNews,
        selectedCategory: 'Tout',
        categories: categories,
      ));
    } catch (e) {
      emit(NewsError('Impossible de charger les publications: $e'));
    }
  }

  void _onCategoryChanged(NewsCategoryChanged event, Emitter<NewsState> emit) {
    if (state is! NewsLoaded) return;
    final current = state as NewsLoaded;
    List<NewsEntity> filtered;
    if (event.category == 'Tout') {
      filtered = current.allNews;
    } else {
      filtered = current.allNews
          .where((n) => n.category.toLowerCase() == event.category.toLowerCase())
          .toList();
    }
    emit(NewsLoaded(
      allNews: current.allNews,
      filteredNews: filtered,
      selectedCategory: event.category,
      categories: current.categories,
    ));
  }

  Future<void> _onRefresh(NewsRefreshRequested event, Emitter<NewsState> emit) async {
    try {
      final allNews = await dataSource.getAllNews();
      final category = (state is NewsLoaded) ? (state as NewsLoaded).selectedCategory : 'Tout';

      final dynamicCategories = allNews
          .map((n) => n.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final categories = ['Tout', ...dynamicCategories];

      List<NewsEntity> filtered;
      if (category == 'Tout') {
        filtered = allNews;
      } else {
        filtered = allNews
            .where((n) => n.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      emit(NewsLoaded(
        allNews: allNews,
        filteredNews: filtered,
        selectedCategory: category,
        categories: categories,
      ));
    } catch (e) {
      emit(NewsError('Erreur de rafraîchissement: $e'));
    }
  }
}
