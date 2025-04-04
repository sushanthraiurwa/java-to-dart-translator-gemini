import 'dart:convert';
import 'package:http/http.dart' as http;

/// Translates Java/Kotlin code to Dart code using the Gemini API
class JavaToDartTranslator {
  final String apiKey;

  /// API endpoint for Gemini model
  static const String apiEndpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent';

  /// Creates a new translator with the given API key
  JavaToDartTranslator({required this.apiKey});

  /// Translates Java code to Dart code using JNIgen conventions
  Future<String> translate(String javaCode) async {
    final prompt = _createPrompt(javaCode);

    final response = await http.post(
      Uri.parse('$apiEndpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': prompt}]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw 'API request failed with status ${response.statusCode}: ${response.body}';
    }

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['candidates'] == null ||
        jsonResponse['candidates'].isEmpty ||
        jsonResponse['candidates'][0]['content']['parts'] == null) {
      throw 'Unexpected API response format';
    }

    final responseText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];

    // Extract code from response (ignoring explanation text)
    return _extractCodeFromResponse(responseText);
  }

  /// Creates a prompt for the Gemini API to translate Java code to Dart
  String _createPrompt(String javaCode) {
    return '''
Task: Translate the following Java/Kotlin code into equivalent Dart code that uses JNIgen-generated bindings.

About JNIgen:
JNIgen is a tool that generates Dart FFI bindings for Java/Android APIs. When using JNIgen-generated code:
1. Java/Kotlin classes become Dart classes with similar methods
2. Java method calls are mapped to equivalent Dart method calls
3. Java types are mapped to appropriate Dart types
4. Java constructors become Dart factory constructors or static methods
5. Java listeners/callbacks are mapped to Dart callbacks or streams

Example transformation:
Java/Kotlin:
```java
ImageCapture imageCapture = new ImageCapture.Builder()
        .setTargetRotation(rotation)
        .build();
cameraProvider.bindToLifecycle(lifecycleOwner, cameraSelector, imageCapture);
```

Dart with JNIgen:
```dart
final ImageCapture imageCapture = ImageCapture.builder()
        .setTargetRotation(rotation)
        .build();
cameraProvider.bindToLifecycle(lifecycleOwner, cameraSelector, imageCapture);
```

Additional translation rules:
- Java's 'new' keyword is omitted in Dart
- Java's ContentValues becomes Map<String, dynamic> in Dart
- Android system services are accessed through equivalent JNIgen wrappers
- Java exceptions are translated to Dart try/catch blocks
- Android UI components are accessed through their JNIgen equivalents
- Android Context is passed as needed to JNIgen methods

Now translate the following Java/Kotlin code to Dart:
```java
$javaCode
```
''';
  }

  /// Extracts just the Dart code from the API response, which may include explanatory text
  String _extractCodeFromResponse(String responseText) {
    // Look for code blocks marked with triple backticks and 'dart'
    final codeRegex = RegExp(r'```dart\s*([\s\S]*?)\s*```');
    final match = codeRegex.firstMatch(responseText);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }

    // If no code block found, try to extract any code-like content
    // This is a fallback in case the model doesn't format with markdown
    final lines = responseText.split('\n');
    bool inCodeBlock = false;
    final codeLines = <String>[];

    for (final line in lines) {
      if (line.contains('```dart')) {
        inCodeBlock = true;
        continue;
      } else if (line.contains('```') && inCodeBlock) {
        inCodeBlock = false;
        continue;
      }

      if (inCodeBlock || (line.contains(';') && !line.startsWith('//') && !line.startsWith('#'))) {
        codeLines.add(line);
      }
    }

    return codeLines.join('\n').trim();
  }
}