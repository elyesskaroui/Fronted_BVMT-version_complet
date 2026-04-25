import 'package:equatable/equatable.dart';

/// Entité représentant une notification de nouvelle publication
class NotificationEntity extends Equatable {
  final String id;
  final String company;
  final String publicationTitle;
  final String category;
  final String pdfUrl;
  final String detailUrl;
  final int totalPublications;
  final bool isRead;
  final String nodeId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.company,
    required this.publicationTitle,
    required this.category,
    required this.pdfUrl,
    required this.detailUrl,
    required this.totalPublications,
    required this.isRead,
    required this.nodeId,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      company: company,
      publicationTitle: publicationTitle,
      category: category,
      pdfUrl: pdfUrl,
      detailUrl: detailUrl,
      totalPublications: totalPublications,
      isRead: isRead ?? this.isRead,
      nodeId: nodeId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, isRead];
}
