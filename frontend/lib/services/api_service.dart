import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/anomaly_result.dart';
import '../models/inspection.dart';

class ApiService {
  /// 画像を送信して異常スコアを取得する。
  static Future<AnomalyResult> analyzeImage(File imageFile) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrl/anomaly-score');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      final body = await streamed.stream.bytesToString();
      throw Exception('API error ${streamed.statusCode}: $body');
    }
    final body = await streamed.stream.bytesToString();
    return AnomalyResult.fromJson(json.decode(body));
  }

  /// 判定結果を保存する。
  static Future<void> saveInspection({
    required File imageFile,
    required String filename,
    required AnomalyResult result,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrl/inspections');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path))
      ..fields['filename'] = filename
      ..fields['ensemble_score'] = result.ensembleScore.toString()
      ..fields['is_anomaly'] = result.isAnomaly.toString()
      ..fields['threshold'] = result.threshold.toString()
      ..fields['reconstruction_error'] = result.reconstructionError.toString()
      ..fields['ssim_score'] = result.ssimScore.toString()
      ..fields['mahalanobis_distance'] = result.mahalanobisDistance.toString()
      ..fields['inference_time_ms'] = result.inferenceTimeMs.toString();

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      final body = await streamed.stream.bytesToString();
      throw Exception('Save error ${streamed.statusCode}: $body');
    }
  }

  /// 判定履歴一覧を取得する。
  static Future<({List<Inspection> items, int total})> getInspections({
    int limit = 50,
    int offset = 0,
    int days = 7,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final uri = Uri.parse(
      '$baseUrl/inspections?limit=$limit&offset=$offset&days=$days',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Fetch error ${response.statusCode}: ${response.body}');
    }
    final data = json.decode(response.body);
    final items = (data['items'] as List)
        .map((e) => Inspection.fromJson(e))
        .toList();
    return (items: items, total: data['total'] as int);
  }

  /// 判定画像のURLを取得する。
  static Future<String> getInspectionImageUrl(String inspectionId) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrl/inspections/$inspectionId/image');

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Image error ${response.statusCode}: ${response.body}');
    }
    final data = json.decode(response.body);
    return data['url'] as String;
  }
}
