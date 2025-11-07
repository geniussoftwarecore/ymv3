import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:yaman_hybrid_flutter_app/core/services/openai_service.dart';

// Mock class for Dio
class MockDio extends Mock implements Dio {}

void main() {
  group('OpenAiService Tests', () {
    late MockDio mockDio;
    late OpenAiService openAiService;
    const String testApiKey = 'test-api-key-123';

    setUp(() {
      mockDio = MockDio();
      openAiService = OpenAiService(
        apiKey: testApiKey,
        dio: mockDio,
      );
    });

    group('Service Initialization', () {
      test('OpenAiService should be initialized with API key', () {
        expect(openAiService, isNotNull);
      });

      test('OpenAiService should initialize with custom Dio', () {
        final customDio = MockDio();
        final service = OpenAiService(
          apiKey: testApiKey,
          dio: customDio,
        );
        expect(service, isNotNull);
      });

      test('OpenAiService should initialize with default Dio if not provided',
          () {
        final service = OpenAiService(apiKey: testApiKey);
        expect(service, isNotNull);
      });

      test('Base URL should be set correctly', () {
        expect(
          OpenAiService.baseUrl,
          equals('https://api.openai.com/v1'),
        );
      });

      test('Model should be set to GPT-4 Turbo', () {
        expect(
          OpenAiService.model,
          equals('gpt-4-turbo'),
        );
      });
    });

    group('Chat Completion - Success Cases', () {
      test('getChatCompletion should return response for valid input',
          () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'This is a test response from OpenAI',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Hello, how are you?',
          conversationHistory: [],
        );

        // Assert
        expect(result, equals('This is a test response from OpenAI'));
      });

      test('getChatCompletion should handle conversation history', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'Response based on history',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final history = [
          {'role': 'user', 'content': 'First question'},
          {'role': 'assistant', 'content': 'First answer'},
        ];

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Follow up question',
          conversationHistory: history,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getChatCompletion should use system prompt if provided', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'Response with custom system prompt',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Test message',
          conversationHistory: [],
          systemPrompt: 'You are a helpful assistant',
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getChatCompletion should use Arabic system prompt by default',
          () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'رد عربي',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'مرحبا',
          conversationHistory: [],
          isArabic: true,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getChatCompletion should handle English language', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'English response',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Hello',
          conversationHistory: [],
          isArabic: false,
        );

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('Chat Completion - Error Cases', () {
      test('getChatCompletion should handle empty response', () async {
        // Arrange
        final mockResponse = Response(
          data: {'choices': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Test',
          conversationHistory: [],
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getChatCompletion should handle non-200 status code', () async {
        // Arrange
        final mockResponse = Response(
          data: {},
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Test',
          conversationHistory: [],
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getChatCompletion should handle DioException', () async {
        // Arrange
        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Test',
          conversationHistory: [],
        );

        // Assert
        expect(result, contains('Error'));
      });

      test('getChatCompletion should handle general exceptions', () async {
        // Arrange
        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await openAiService.getChatCompletion(
          userMessage: 'Test',
          conversationHistory: [],
        );

        // Assert
        expect(result.contains('Unexpected error') || result.contains('Error'),
            isTrue);
      });
    });

    group('Diagnostic Suggestions', () {
      test('getDiagnosticSuggestions should return suggestions for symptoms',
          () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content':
                      'The symptom suggests a potential engine issue. Here are the steps...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getDiagnosticSuggestions(
          symptom: 'Engine overheating',
          vehicleType: 'Toyota Camry',
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getDiagnosticSuggestions should handle Arabic language', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'التشخيص...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getDiagnosticSuggestions(
          symptom: 'ارتفاع درجة الحرارة',
          vehicleType: 'تويوتا كامري',
          isArabic: true,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getDiagnosticSuggestions should handle English language', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'Diagnosis steps...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getDiagnosticSuggestions(
          symptom: 'Overheating engine',
          vehicleType: 'Toyota Camry',
          isArabic: false,
        );

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('Service Recommendations', () {
      test(
          'getServiceRecommendations should return maintenance recommendations',
          () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content':
                      'Recommended services: Oil change, filter replacement...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getServiceRecommendations(
          vehicleInfo: 'Toyota Camry 2020',
          mileage: 50000,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getServiceRecommendations should consider mileage', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'Major service recommended at this mileage',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getServiceRecommendations(
          vehicleInfo: 'BMW 320i',
          mileage: 100000,
          isArabic: false,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getServiceRecommendations should handle different languages',
          () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'التوصيات...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getServiceRecommendations(
          vehicleInfo: 'هونداي',
          mileage: 75000,
          isArabic: true,
        );

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('Cost Estimation', () {
      test('getCostEstimation should evaluate service costs', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content':
                      'The estimated cost seems reasonable for these services',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getCostEstimation(
          services: ['Oil Change', 'Filter Replacement', 'Fluid Top-up'],
          estimatedCost: 250.0,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getCostEstimation should handle multiple services', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'Cost analysis complete',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getCostEstimation(
          services: [
            'Engine Diagnostic',
            'Oil Change',
            'Air Filter',
            'Cabin Filter',
            'Spark Plugs'
          ],
          estimatedCost: 1500.0,
          isArabic: false,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getCostEstimation should handle Arabic language', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'تقييم التكلفة...',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getCostEstimation(
          services: ['تغيير الزيت', 'استبدال الفلتر'],
          estimatedCost: 350.0,
          isArabic: true,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('getCostEstimation should handle high costs', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'choices': [
              {
                'message': {
                  'content': 'This is a major repair with significant cost',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await openAiService.getCostEstimation(
          services: ['Engine Replacement', 'Transmission Repair', 'Labor'],
          estimatedCost: 5000.0,
        );

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('Streaming Responses', () {
      test('getChatCompletionStream should return a stream', () {
        // Act
        final stream = openAiService.getChatCompletionStream(
          userMessage: 'Test message',
          conversationHistory: [],
        );

        // Assert
        expect(stream, isA<Stream>());
      });

      test('getChatCompletionStream should yield strings', () async {
        // Arrange
        final mockStream = Stream.fromIterable([
          'This is ',
          'a streaming ',
          'response from OpenAI',
        ]);

        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => Response(
            data: mockStream,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act & Assert
        final stream = openAiService.getChatCompletionStream(
          userMessage: 'Test',
          conversationHistory: [],
        );

        expect(stream, isA<Stream<String>>());
      });

      test('getChatCompletionStream should handle errors', () async {
        // Arrange
        when(mockDio.post(
          'https://api.openai.com/v1/chat/completions',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(Exception('Stream error'));

        // Act
        final stream = openAiService.getChatCompletionStream(
          userMessage: 'Test',
          conversationHistory: [],
        );

        // Assert
        expect(stream, isA<Stream>());
      });

      test('getChatCompletionStream should support Arabic language', () {
        // Act
        final stream = openAiService.getChatCompletionStream(
          userMessage: 'مرحبا',
          conversationHistory: [],
          isArabic: true,
        );

        // Assert
        expect(stream, isA<Stream>());
      });

      test('getChatCompletionStream should support English language', () {
        // Act
        final stream = openAiService.getChatCompletionStream(
          userMessage: 'Hello',
          conversationHistory: [],
          isArabic: false,
        );

        // Assert
        expect(stream, isA<Stream>());
      });
    });

    group('ChunkedStreamDecoder', () {
      test('ChunkedStreamDecoder should decode chunks correctly', () {
        final decoder = _ChunkedStreamDecoder();
        final chunk = 'test line 1\ntest line 2\n'.codeUnits;

        final result = decoder.add(chunk);

        expect(result.length, equals(2));
        expect(result[0], equals('test line 1'));
        expect(result[1], equals('test line 2'));
      });

      test('ChunkedStreamDecoder should handle incomplete lines', () {
        final decoder = _ChunkedStreamDecoder();
        final chunk = 'incomplete'.codeUnits;

        final result = decoder.add(chunk);

        expect(result.isEmpty, isTrue);
      });

      test('ChunkedStreamDecoder should close and flush buffer', () {
        final decoder = _ChunkedStreamDecoder();
        decoder.add('incomplete line'.codeUnits);
        final result = decoder.close();

        expect(result.length, equals(1));
        expect(result[0], equals('incomplete line'));
      });

      test('ChunkedStreamDecoder should handle multiple chunks', () {
        final decoder = _ChunkedStreamDecoder();

        final chunk1 = 'line1\npar'.codeUnits;
        final result1 = decoder.add(chunk1);
        expect(result1.length, equals(1));

        final chunk2 = 'tial\nline3\n'.codeUnits;
        final result2 = decoder.add(chunk2);
        expect(result2.length, greaterThan(0));
      });
    });

    group('Configuration Constants', () {
      test('Base URL should be HTTPS', () {
        expect(
          OpenAiService.baseUrl.startsWith('https://'),
          isTrue,
        );
      });

      test('Model should be valid GPT version', () {
        expect(
          OpenAiService.model.contains('gpt'),
          isTrue,
        );
      });

      test('Base URL should point to OpenAI API', () {
        expect(
          OpenAiService.baseUrl.contains('openai.com'),
          isTrue,
        );
      });
    });
  });
}

/// Helper class for testing chunked stream decoder
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
