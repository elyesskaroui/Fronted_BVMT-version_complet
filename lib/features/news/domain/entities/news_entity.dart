import 'package:equatable/equatable.dart';

/// Entité représentant une publication/actualité financière BVMT
class NewsEntity extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String source;
  final String category;
  final DateTime publishedAt;
  final String? imageUrl;
  final String? relatedSymbol;
  final String? pdfUrl;
  final String? detailUrl;

  const NewsEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    this.relatedSymbol,
    this.pdfUrl,
    this.detailUrl,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }

  /// Date formatée DD/MM/YYYY
  String get formattedDate {
    final d = publishedAt.day.toString().padLeft(2, '0');
    final m = publishedAt.month.toString().padLeft(2, '0');
    final y = publishedAt.year;
    return '$d/$m/$y';
  }

  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, title, source, publishedAt];
}
