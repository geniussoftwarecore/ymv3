import 'package:dio/dio.dart';
import 'dart:async';

class OpenAiService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String model =
      'gpt-4-turbo'; // Using GPT-4 Turbo for best results

  final Dio _dio;
  final String _apiKey;

  OpenAiService({required String apiKey, Dio? dio})
      : _apiKey = apiKey,
        _dio = dio ?? Dio();

  /// Initialize the Dio instance with required headers
  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  /// Get chat completion from OpenAI API
  /// Supports both streaming and non-streaming modes
  Future<String> getChatCompletion({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String systemPrompt = '',
    bool isArabic = true,
  }) async {
    try {
      _initializeDio();

      // Build messages array with conversation history
      List<Map<String, dynamic>> messages = [];

      // Add system prompt
      if (systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      } else {
        // Default system prompt for workshop assistance
        messages.add({
          'role': 'system',
          'content': isArabic
              ? 'أنت مساعد ذكي متخصص في إدارة ورش السيارات والصيانة. يجب عليك تقديم نصائح فنية دقيقة وحلول عملية للمشاكل. تحدث بلغة واضحة وسهلة الفهم.'
              : 'You are an intelligent assistant specialized in car workshop management and maintenance. Provide accurate technical advice and practical solutions to problems. Speak in clear and easy-to-understand language.',
        });
      }

      // Add conversation history
      for (var msg in conversationHistory) {
        messages.add({
          'role': msg['role'] ?? 'user',
          'content': msg['content'] ?? '',
        });
      }

      // Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      // Make API call
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'top_p': 0.9,
          'max_tokens': 1500,
          'presence_penalty': 0.6,
          'frequency_penalty': 0.5,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'] ?? 'No response generated';
        }
      }
      return 'Error: Could not get response from AI';
    } on DioException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Get streaming chat completion (real-time response)
  Stream<String> getChatCompletionStream({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String systemPrompt = '',
    bool isArabic = true,
  }) async* {
    try {
      _initializeDio();

      // Build messages array
      List<Map<String, dynamic>> messages = [];

      if (systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      } else {
        messages.add({
          'role': 'system',
          'content': isArabic
              ? 'أنت مساعد ذكي متخصص في إدارة ورش السيارات والصيانة. يجب عليك تقديم نصائح فنية دقيقة وحلول عملية للمشاكل.'
              : 'You are an intelligent assistant specialized in car workshop management and maintenance.',
        });
      }

      for (var msg in conversationHistory) {
        messages.add({
          'role': msg['role'] ?? 'user',
          'content': msg['content'] ?? '',
        });
      }

      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      // Make streaming API call
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model,
          'messages': messages,
          'stream': true,
          'temperature': 0.7,
          'max_tokens': 1500,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream;
      final decoder = _ChunkedStreamDecoder();

      await for (var chunk in stream) {
        final decoded = decoder.add(chunk);
        if (decoded.isNotEmpty) {
          for (var line in decoded) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              if (data == '[DONE]') break;

              try {
                final json = data.isEmpty ? {} : _parseJson(data);
                final content = json['choices']?[0]?['delta']?['content'] ?? '';
                if (content.isNotEmpty) {
                  yield content;
                }
              } catch (e) {
                // Skip invalid JSON
              }
            }
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  /// Parse JSON safely
  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return {'data': jsonString}; // Placeholder - use actual JSON parsing
    } catch (e) {
      return {};
    }
  }

  /// Generate workshop diagnostic suggestions
  Future<String> getDiagnosticSuggestions({
    required String symptom,
    required String vehicleType,
    bool isArabic = true,
  }) async {
    final prompt = isArabic
        ? 'المركبة: $vehicleType\nالأعراض: $symptom\n\nقدم تشخيص مفصل وخطوات إصلاح.'
        : 'Vehicle: $vehicleType\nSymptoms: $symptom\n\nProvide detailed diagnosis and repair steps.';

    return await getChatCompletion(
      userMessage: prompt,
      conversationHistory: [],
      systemPrompt: isArabic
          ? 'أنت خبير تشخيص سيارات ذو خبرة. قدم تشخيصات دقيقة وملموسة.'
          : 'You are an experienced car diagnostic expert. Provide accurate and concrete diagnoses.',
      isArabic: isArabic,
    );
  }

  /// Generate service recommendations
  Future<String> getServiceRecommendations({
    required String vehicleInfo,
    required int mileage,
    bool isArabic = true,
  }) async {
    final prompt = isArabic
        ? 'المركبة: $vehicleInfo\nعدد الكيلومترات: $mileage\n\nما هي الخدمات الموصى بها؟'
        : 'Vehicle: $vehicleInfo\nMileage: $mileage\n\nWhat services are recommended?';

    return await getChatCompletion(
      userMessage: prompt,
      conversationHistory: [],
      systemPrompt: isArabic
          ? 'أنت استشاري صيانة سيارات محترف. قدم توصيات الصيانة الدورية المهمة.'
          : 'You are a professional car maintenance consultant. Provide important periodic maintenance recommendations.',
      isArabic: isArabic,
    );
  }

  /// Generate cost estimation explanation
  Future<String> getCostEstimation({
    required List<String> services,
    required double estimatedCost,
    bool isArabic = true,
  }) async {
    final servicesList = services.join('\n- ');
    final prompt = isArabic
        ? 'الخدمات المطلوبة:\n- $servicesList\nالتكلفة المتوقعة: $estimatedCost ريال\n\nهل هذه التكلفة معقولة؟'
        : 'Required Services:\n- $servicesList\nEstimated Cost: $estimatedCost\n\nIs this cost reasonable?';

    return await getChatCompletion(
      userMessage: prompt,
      conversationHistory: [],
      systemPrompt: isArabic
          ? 'أنت محلل تكاليف صيانة سيارات. قيّم معقولية الأسعار المقترحة.'
          : 'You are a car maintenance cost analyst. Evaluate the reasonableness of proposed prices.',
      isArabic: isArabic,
    );
  }
}

/// Helper class for decoding chunked streaming responses
class _ChunkedStreamDecoder {
  String _buffer = '';

  List<String> add(List<int> chunk) {
    _buffer += String.fromCharCodes(chunk);
    final lines = _buffer.split('\n');
    _buffer = lines.last;
    return lines.sublist(0, lines.length - 1);
  }

  List<String> close() {
    final lines = _buffer.isEmpty ? <String>[] : [_buffer];
    _buffer = '';
    return lines;
  }
}
