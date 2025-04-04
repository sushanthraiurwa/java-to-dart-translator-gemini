import 'dart:io';
import 'package:args/args.dart';
import 'package:java_to_dart_translator/java_to_dart_translator_gemini.dart';

void main(List<String> arguments) async {
  // Parse command line arguments
  final parser = ArgParser()
    ..addOption('api-key', abbr: 'k', help: 'Gemini API key')
    ..addOption('file', abbr: 'f', help: 'Java/Kotlin file to translate')
    ..addOption('output', abbr: 'o', help: 'Output file for Dart code')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('Error: $e\n');
    printUsage(parser);
    exit(1);
  }

  if (args['help']) {
    printUsage(parser);
    exit(0);
  }

  // Validate required arguments
  final apiKey = args['api-key'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: API key is required\n');
    printUsage(parser);
    exit(1);
  }

  String javaCode;
  if (args['file'] != null) {
    // Read code from file
    try {
      javaCode = await File(args['file']).readAsString();
    } catch (e) {
      print('Error reading file: $e');
      exit(1);
    }
  } else {
    // Read from stdin
    print('Enter Java/Kotlin code (press Ctrl+D when finished):');
    javaCode = await readFromStdin();
  }

  if (javaCode.isEmpty) {
    print('Error: No code provided');
    exit(1);
  }

  print('Translating code using Gemini API...');

  try {
    // Create translator and translate code
    final translator = JavaToDartTranslator(apiKey: apiKey);
    final dartCode = await translator.translate(javaCode);

    if (args['output'] != null) {
      await File(args['output']).writeAsString(dartCode);
      print('Translation saved to ${args['output']}');
    } else {
      print('\n=== Translated Dart Code ===\n');
      print(dartCode);
      print('\n===========================\n');
    }
  } catch (e) {
    print('Error during translation: $e');
    exit(1);
  }
}

Future<String> readFromStdin() async {
  final buffer = StringBuffer();
  String? line;

  while ((line = stdin.readLineSync()) != null) {
    buffer.writeln(line);
  }

  return buffer.toString();
}

void printUsage(ArgParser parser) {
  print('Usage: dart run bin/translator.dart [options]');
  print(parser.usage);
}