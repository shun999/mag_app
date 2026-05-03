/// /anomaly-score API のレスポンスモデル
class AnomalyResult {
  final double ensembleScore;
  final bool isAnomaly;
  final double threshold;
  final double reconstructionError;
  final double ssimScore;
  final double mahalanobisDistance;
  final int inferenceTimeMs;

  AnomalyResult({
    required this.ensembleScore,
    required this.isAnomaly,
    required this.threshold,
    required this.reconstructionError,
    required this.ssimScore,
    required this.mahalanobisDistance,
    required this.inferenceTimeMs,
  });

  factory AnomalyResult.fromJson(Map<String, dynamic> json) {
    return AnomalyResult(
      ensembleScore: (json['ensemble_score'] as num).toDouble(),
      isAnomaly: json['is_anomaly'] as bool,
      threshold: (json['threshold'] as num).toDouble(),
      reconstructionError: (json['reconstruction_error'] as num).toDouble(),
      ssimScore: (json['ssim_score'] as num).toDouble(),
      mahalanobisDistance: (json['mahalanobis_distance'] as num).toDouble(),
      inferenceTimeMs: json['inference_time_ms'] as int,
    );
  }

  /// ensemble_score を 0〜100% の信頼度に変換する。
  /// スコアが threshold 以下なら正常側の信頼度、超えたら異常側の信頼度。
  double get confidencePercent {
    final ratio = ensembleScore / threshold;
    if (isAnomaly) {
      return (ratio.clamp(1.0, 3.0) / 3.0 * 100).clamp(50.0, 99.0);
    } else {
      return ((1.0 - ratio).clamp(0.0, 1.0) * 50 + 50).clamp(50.0, 99.0);
    }
  }
}
