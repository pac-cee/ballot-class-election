class CampaignPost {
  const CampaignPost({
    required this.id,
    required this.candidateId,
    required this.body,
    required this.timeLabel,
    required this.likes,
    this.isLiked = false,
  });
  final int id;
  final int candidateId;
  final String body;
  final String timeLabel;
  final int likes;
  final bool isLiked;

  CampaignPost copyWith({int? likes, bool? isLiked}) => CampaignPost(
    id: id,
    candidateId: candidateId,
    body: body,
    timeLabel: timeLabel,
    likes: likes ?? this.likes,
    isLiked: isLiked ?? this.isLiked,
  );
}
