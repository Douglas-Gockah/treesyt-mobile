import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Manages offline storage of survey responses using Hive.
///
/// Responses are saved locally immediately; a [synced] flag tracks
/// whether they have been uploaded to the server.
class StorageService {
  static const String _boxName = 'survey_responses';
  static StorageService? _instance;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  late Box<String> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  // ---------------------------------------------------------------------------
  // Save a new response (always unsynced at first)
  // ---------------------------------------------------------------------------
  Future<void> saveResponse(SurveyResponse response) async {
    final json = jsonEncode(response.toJson());
    await _box.put(response.id, json);
  }

  // ---------------------------------------------------------------------------
  // Get all saved responses
  // ---------------------------------------------------------------------------
  List<SurveyResponse> getAllResponses() {
    return _box.values
        .map((raw) {
          try {
            return SurveyResponse.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SurveyResponse>()
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  // ---------------------------------------------------------------------------
  // Get responses for a specific form
  // ---------------------------------------------------------------------------
  List<SurveyResponse> getResponsesForForm(String formId) {
    return getAllResponses()
        .where((r) => r.formId == formId)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Mark a response as synced (called after successful API upload)
  // ---------------------------------------------------------------------------
  Future<void> markSynced(String responseId) async {
    final raw = _box.get(responseId);
    if (raw == null) return;
    final response = SurveyResponse.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
    await saveResponse(response.copyWith(synced: true));
  }

  // ---------------------------------------------------------------------------
  // Get count of unsynced responses
  // ---------------------------------------------------------------------------
  int get unsyncedCount =>
      getAllResponses().where((r) => !r.synced).length;

  // ---------------------------------------------------------------------------
  // Delete a single response
  // ---------------------------------------------------------------------------
  Future<void> deleteResponse(String responseId) async {
    await _box.delete(responseId);
  }

  // ---------------------------------------------------------------------------
  // Clear all responses (dev helper)
  // ---------------------------------------------------------------------------
  Future<void> clearAll() async {
    await _box.clear();
  }
}
