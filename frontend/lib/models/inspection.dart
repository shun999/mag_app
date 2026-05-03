/// 判定履歴アイテムモデル (GET /inspections レスポンス)
class Inspection {
  final String id;
  final String filename;
  final double ensembleScore;
  final bool isAnomaly;
  final double threshold;
  final double reconstructionError;
  final double ssimScore;
  final double mahalanobisDistance;
  final int inferenceTimeMs;
  final DateTime createdAt;

  Inspection({
    required this.id,
    required this.filename,
    required this.ensembleScore,
    required this.isAnomaly,
    required this.threshold,
    required this.reconstructionError,
    required this.ssimScore,
    required this.mahalanobisDistance,
    required this.inferenceTimeMs,
    required this.createdAt,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] as String,
      filename: json['filename'] as String,
      ensembleScore: (json['ensemble_score'] as num).toDouble(),
      isAnomaly: json['is_anomaly'] as bool,
      threshold: (json['threshold'] as num).toDouble(),
      reconstructionError: (json['reconstruction_error'] as num).toDouble(),
      ssimScore: (json['ssim_score'] as num).toDouble(),
      mahalanobisDistance: (json['mahalanobis_distance'] as num).toDouble(),
      inferenceTimeMs: json['inference_time_ms'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  double get confidencePercent {
    final ratio = ensembleScore / threshold;
    if (isAnomaly) {
      return (ratio.clamp(1.0, 3.0) / 3.0 * 100).clamp(50.0, 99.0);
    } else {
      return ((1.0 - ratio).clamp(0.0, 1.0) * 50 + 50).clamp(50.0, 99.0);
    }
  }
}
