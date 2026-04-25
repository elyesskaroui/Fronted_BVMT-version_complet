import 'package:dio/dio.dart';
import '../../domain/entities/news_entity.dart';
import 'news_remote_datasource.dart';

/// Source de données mock pour les actualités
class NewsMockDataSource extends NewsRemoteDataSource {
  NewsMockDataSource() : super(dio: Dio());

  @override
  Future<List<NewsEntity>> getAllNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async =>
      buildData();

  List<NewsEntity> buildData() {
    final now = DateTime.now();
    return [
      NewsEntity(
        id: '1',
        title: 'Le TUNINDEX clôture en hausse de 0.45%',
        summary:
            'L\'indice principal de la BVMT a terminé la séance en territoire positif, '
            'porté par les valeurs bancaires et les sociétés agroalimentaires. '
            'Le volume des échanges a atteint 8.2 millions de dinars.',
        source: 'BVMT',
        category: 'marché',
        publishedAt: now.subtract(const Duration(minutes: 25)),
        relatedSymbol: 'TUNINDEX',
      ),
      NewsEntity(
        id: '2',
        title: 'BIAT : Résultats semestriels en forte progression',
        summary:
            'La Banque Internationale Arabe de Tunisie affiche un PNB en hausse '
            'de 12.3% au premier semestre. Le résultat net s\'établit à 185 MDT, '
            'en progression de 8.7% par rapport à la même période.',
        source: 'Tustex',
        category: 'entreprise',
        publishedAt: now.subtract(const Duration(hours: 2)),
        relatedSymbol: 'BIAT',
      ),
      NewsEntity(
        id: '3',
        title: 'Poulina Group Holding : Acquisition stratégique',
        summary:
            'PGH annonce l\'acquisition de 60% du capital d\'une société spécialisée '
            'dans la distribution alimentaire. Cette opération renforce la position '
            'du groupe dans le secteur agroalimentaire.',
        source: 'Webmanagercenter',
        category: 'entreprise',
        publishedAt: now.subtract(const Duration(hours: 4)),
        relatedSymbol: 'PGH',
      ),
      NewsEntity(
        id: '4',
        title: 'Analyse technique : SFBT en zone de support',
        summary:
            'L\'action SFBT évolue actuellement près d\'un support technique majeur '
            'à 18.50 TND. Les analystes anticipent un rebond technique vers 19.80 TND '
            'si le support tient. Volume en baisse, RSI en zone neutre.',
        source: 'Tunisie Valeurs',
        category: 'analyse',
        publishedAt: now.subtract(const Duration(hours: 6)),
        relatedSymbol: 'SFBT',
      ),
      NewsEntity(
        id: '5',
        title: 'BCT : Le taux directeur maintenu à 8%',
        summary:
            'La Banque Centrale de Tunisie a décidé de maintenir son taux directeur '
            'inchangé à 8%. Cette décision vise à préserver la stabilité des prix '
            'tout en soutenant la croissance économique.',
        source: 'BCT',
        category: 'économie',
        publishedAt: now.subtract(const Duration(hours: 10)),
      ),
      NewsEntity(
        id: '6',
        title: 'Amen Bank : Distribution de dividendes approuvée',
        summary:
            'L\'Assemblée Générale d\'Amen Bank a approuvé la distribution d\'un '
            'dividende de 1.200 TND par action au titre de l\'exercice écoulé, '
            'soit un rendement de 3.8% au cours actuel.',
        source: 'BVMT',
        category: 'entreprise',
        publishedAt: now.subtract(const Duration(hours: 14)),
        relatedSymbol: 'AB',
      ),
      NewsEntity(
        id: '7',
        title: 'Marché obligataire : Nouvelle émission BTA',
        summary:
            'Le Trésor public lance une nouvelle émission de Bons du Trésor '
            'Assimilables (BTA) à 5 ans avec un taux de 9.2%. La souscription '
            'est ouverte du 5 au 12 mars.',
        source: 'BCT',
        category: 'économie',
        publishedAt: now.subtract(const Duration(days: 1)),
      ),
      NewsEntity(
        id: '8',
        title: 'Carthage Cement : Production record au T3',
        summary:
            'Carthage Cement annonce une production record de 1.2 million de tonnes '
            'au troisième trimestre, en hausse de 15% par rapport à la même période '
            'de l\'année précédente. Le carnet de commandes reste solide.',
        source: 'Tustex',
        category: 'entreprise',
        publishedAt: now.subtract(const Duration(days: 1, hours: 5)),
        relatedSymbol: 'CC',
      ),
      NewsEntity(
        id: '9',
        title: 'Perspectives 2026 : Les secteurs à surveiller',
        summary:
            'Les analystes de Tunisie Valeurs identifient le secteur bancaire, '
            'l\'agroalimentaire et les matériaux de construction comme les segments '
            'les plus prometteurs pour 2026. Revue détaillée des valorisations.',
        source: 'Tunisie Valeurs',
        category: 'analyse',
        publishedAt: now.subtract(const Duration(days: 2)),
      ),
      NewsEntity(
        id: '10',
        title: 'Délice Holding : Expansion vers le marché libyen',
        summary:
            'Délice Holding signe un accord de partenariat pour la distribution '
            'de ses produits laitiers en Libye. Le groupe prévoit un chiffre '
            'd\'affaires additionnel de 20 MDT sur les deux prochaines années.',
        source: 'Webmanagercenter',
        category: 'entreprise',
        publishedAt: now.subtract(const Duration(days: 2, hours: 8)),
        relatedSymbol: 'DELICE',
      ),
    ];
  }

  List<NewsEntity> getNewsByCategory(String category) {
    return buildData().where((n) => n.category == category).toList();
  }

  List<NewsEntity> getNewsBySymbol(String symbol) {
    return buildData().where((n) => n.relatedSymbol == symbol).toList();
  }
}
