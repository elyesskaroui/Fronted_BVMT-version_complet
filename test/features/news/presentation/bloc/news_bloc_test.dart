import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bvmt/features/news/presentation/bloc/news_bloc.dart';
import 'package:bvmt/features/news/presentation/bloc/news_event.dart';
import 'package:bvmt/features/news/presentation/bloc/news_state.dart';
import 'package:bvmt/features/news/data/datasources/news_mock_datasource.dart';

void main() {
  group('NewsBloc', () {
    late NewsBloc bloc;
    late NewsMockDataSource dataSource;

    setUp(() {
      dataSource = NewsMockDataSource();
      bloc = NewsBloc(dataSource: dataSource);
    });

    tearDown(() {
      bloc.close();
    });

    test('état initial est NewsInitial', () {
      expect(bloc.state, const NewsInitial());
    });

    blocTest<NewsBloc, NewsState>(
      'émet [NewsLoading, NewsLoaded] lors du chargement',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      act: (bloc) => bloc.add(const NewsLoadRequested()),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const NewsLoading(),
        isA<NewsLoaded>()
            .having((s) => s.allNews.length, 'total articles', 10)
            .having((s) => s.selectedCategory, 'catégorie', 'Tout')
            .having(
              (s) => s.categories,
              'catégories',
              ['Tout', 'marché', 'entreprise', 'analyse', 'économie'],
            ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'filteredNews = allNews quand catégorie est Tout',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      act: (bloc) => bloc.add(const NewsLoadRequested()),
      wait: const Duration(milliseconds: 400),
      verify: (bloc) {
        final state = bloc.state as NewsLoaded;
        expect(state.filteredNews.length, state.allNews.length);
      },
    );

    blocTest<NewsBloc, NewsState>(
      'NewsCategoryChanged filtre par catégorie entreprise',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      seed: () {
        final allNews = NewsMockDataSource().buildData();
        return NewsLoaded(
          allNews: allNews,
          filteredNews: allNews,
          selectedCategory: 'Tout',
          categories: ['Tout', 'marché', 'entreprise', 'analyse', 'économie'],
        );
      },
      act: (bloc) => bloc.add(const NewsCategoryChanged('entreprise')),
      expect: () => [
        isA<NewsLoaded>()
            .having((s) => s.selectedCategory, 'catégorie', 'entreprise')
            .having(
              (s) => s.filteredNews.every((n) => n.category == 'entreprise'),
              'toutes entreprise',
              true,
            ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'NewsCategoryChanged "Tout" retourne toutes les news',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      seed: () {
        final allNews = NewsMockDataSource().buildData();
        final filtered =
            allNews.where((n) => n.category == 'entreprise').toList();
        return NewsLoaded(
          allNews: allNews,
          filteredNews: filtered,
          selectedCategory: 'entreprise',
          categories: ['Tout', 'marché', 'entreprise', 'analyse', 'économie'],
        );
      },
      act: (bloc) => bloc.add(const NewsCategoryChanged('Tout')),
      expect: () => [
        isA<NewsLoaded>()
            .having((s) => s.selectedCategory, 'catégorie', 'Tout')
            .having((s) => s.filteredNews.length, 'count', 10),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'NewsCategoryChanged "analyse" filtre correctement',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      seed: () {
        final allNews = NewsMockDataSource().buildData();
        return NewsLoaded(
          allNews: allNews,
          filteredNews: allNews,
          selectedCategory: 'Tout',
          categories: ['Tout', 'marché', 'entreprise', 'analyse', 'économie'],
        );
      },
      act: (bloc) => bloc.add(const NewsCategoryChanged('analyse')),
      verify: (bloc) {
        final state = bloc.state as NewsLoaded;
        expect(state.filteredNews.length, 2); // 2 articles d'analyse
        for (final news in state.filteredNews) {
          expect(news.category, 'analyse');
        }
      },
    );

    blocTest<NewsBloc, NewsState>(
      'NewsRefreshRequested recharge les données',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      seed: () {
        final allNews = NewsMockDataSource().buildData();
        return NewsLoaded(
          allNews: allNews,
          filteredNews: allNews,
          selectedCategory: 'Tout',
          categories: ['Tout', 'marché', 'entreprise', 'analyse', 'économie'],
        );
      },
      act: (bloc) => bloc.add(const NewsRefreshRequested()),
      expect: () => [
        isA<NewsLoaded>()
            .having((s) => s.allNews.length, 'total', 10)
            .having((s) => s.selectedCategory, 'catégorie', 'Tout'),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'NewsCategoryChanged ne fait rien si pas NewsLoaded',
      build: () => NewsBloc(dataSource: NewsMockDataSource()),
      act: (bloc) => bloc.add(const NewsCategoryChanged('marché')),
      expect: () => [],
    );
  });
}
