# Java/Kotlin to Dart Translator

A tool to translate Java/Kotlin code snippets to Dart code using JNIgen conventions via the Gemini API.

## Overview

This project provides a command-line tool for translating Java/Kotlin code snippets into equivalent Dart code that uses JNIgen-generated bindings. It leverages Google's Gemini 1.5 Pro API to perform the translation.

JNIgen is a tool that generates Dart FFI bindings for Java/Android APIs. This translator helps developers convert example code from Java/Kotlin documentation into Dart code that works with JNIgen-generated bindings.

## Features

- Translate Java/Kotlin code to Dart using JNIgen conventions
- Support for command-line usage with various options
- Read input from files or standard input
- Write output to files or standard output
- Automatic extraction of code blocks from API responses

## Installation

### Prerequisites

- Dart SDK 2.19.0 or higher
- A Gemini API key (obtain from [https://ai.google.dev/gemini-api/docs/api-key](https://ai.google.dev/gemini-api/docs/api-key))

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/java-to-dart-translator-gemini.git
   cd java-to-dart-translator-gemini
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

## Usage

### Command Line

```bash
dart run bin/translator.dart --api-key YOUR_API_KEY [options]
```

#### Options:

- `-k, --api-key`: Gemini API key (required)
- `-f, --file`: Java/Kotlin file to translate
- `-o, --output`: Output file for Dart code
- `-h, --help`: Show usage information

### Examples

#### Translate a Java file:

```bash
dart run bin/translator.dart --api-key YOUR_API_KEY --file examples/camera_example.java --output example/camera_example.dart
```

#### Interactive mode (paste code):

```bash
dart run bin/translator.dart --api-key YOUR_API_KEY
```

## How It Works

The translator works by:

1. Creating a prompt for the Gemini API that includes:
  - The task description (translating Java/Kotlin to Dart)
  - Information about JNIgen conventions
  - Example transformations
  - Translation rules
  - The input Java/Kotlin code

2. Sending the prompt to the Gemini API
3. Processing the API response to extract the Dart code
4. Returning the translated code

## Translation Rules

The translator applies the following rules:

- Java's 'new' keyword is omitted in Dart
- Java's ContentValues becomes Map<String, dynamic> in Dart
- Android system services are accessed through equivalent JNIgen wrappers
- Java exceptions are translated to Dart try/catch blocks
- Android UI components are accessed through their JNIgen equivalents
- Android Context is passed as needed to JNIgen methods

## Example

### Input (Java):

```java
// Sample from https://developer.android.com/media/camera/camerax/take-photo#take_a_picture
private void takePhoto() {
    // Get a stable reference of the modifiable image capture use case
    ImageCapture imageCapture = imageCapture;
    if (imageCapture == null) {
        return;
    }

    // Create time stamped name and MediaStore entry.
    String name = new SimpleDateFormat(FILENAME_FORMAT, Locale.US)
            .format(System.currentTimeMillis());
    ContentValues contentValues = new ContentValues();
    contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, name);
    contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg");
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
        contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CameraX-Image");
    }

    // Create output options object which contains file + metadata
    ImageCapture.OutputFileOptions outputOptions = new ImageCapture.OutputFileOptions.Builder(
            getContentResolver(),
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues
    ).build();

    // Set up image capture listener, which is triggered after photo has been taken
    imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            new ImageCapture.OnImageSavedCallback() {
                @Override
                public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {
                    String msg = "Photo capture succeeded: " +
                            outputFileResults.getSavedUri();
                    Toast.makeText(getBaseContext(), msg, Toast.LENGTH_SHORT).show();
                    Log.d(TAG, msg);
                }

                @Override
                public void onError(@NonNull ImageCaptureException exc) {
                    Log.e(TAG, "Photo capture failed: " + exc.getMessage(), exc);
                }
            }
    );
}
```

### Output (Dart):

```dart
import 'package:jigen_example/android_content/ContentValues.jigen.dart' as jigen_content_values;
import 'package:jigen_example/android_content/Context.jigen.dart' as jigen_context;
import 'package:jigen_example/android_os/Build.jigen.dart' as jigen_build;
import 'package:jigen_example/android_provider/MediaStore.jigen.dart' as jigen_mediastore;
import 'package:jigen_example/android_widget/Toast.jigen.dart' as jigen_toast;
import 'package:jigen_example/androidx/camera/core/ImageCapture.jigen.dart' as jigen_imagecapture;
import 'package:jigen_example/androidx/camera/core/ImageCaptureException.jigen.dart' as jigen_imagecapture_exception;
import 'package:jigen_example/androidx/core/content/ContextCompat.jigen.dart' as jigen_contextcompat;
import 'package:intl/intl.dart';

// Assuming TAG and FILENAME_FORMAT are defined elsewhere
const String TAG = "CameraXApp";
const String FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS";

Future<void> takePhoto(jigen_imagecapture.ImageCapture? imageCapture, jigen_context.Context context) async {
  // Get a stable reference of the modifiable image capture use case
  if (imageCapture == null) {
    return;
  }

  // Create time stamped name and MediaStore entry.
  String name = DateFormat(FILENAME_FORMAT).format(DateTime.now());
  final jigen_content_values.ContentValues contentValues = jigen_content_values.ContentValues();
  contentValues.put(jigen_mediastore.MediaStore_MediaColumns.DISPLAY_NAME, name);
  contentValues.put(jigen_mediastore.MediaStore_MediaColumns.MIME_TYPE, "image/jpeg");
  if (jigen_build.Build.VERSION.SDK_INT > jigen_build.Build_VERSION_CODES.P) {
    contentValues.put(jigen_mediastore.MediaStore_Images_Media.RELATIVE_PATH, "Pictures/CameraX-Image");
  }

  // Create output options object which contains file + metadata
  final jigen_imagecapture.ImageCapture_OutputFileOptions outputOptions = jigen_imagecapture.ImageCapture_OutputFileOptions.builder(
    context.getContentResolver(),
    jigen_mediastore.MediaStore_Images_Media.EXTERNAL_CONTENT_URI,
    contentValues,
  ).build();

  // Set up image capture listener, which is triggered after photo has been taken
  try {
    final jigen_imagecapture.ImageCapture_OutputFileResults outputFileResults = await imageCapture.takePicture(
      outputOptions,
      jigen_contextcompat.ContextCompat.getMainExecutor(context),
    );
    String msg = "Photo capture succeeded: ${outputFileResults.getSavedUri()}";
    jigen_toast.Toast.makeText(context, msg, jigen_toast.Toast.LENGTH_SHORT).show();
    // ignore: avoid_print
    print(msg); // Using print instead of Log.d
  } on jigen_imagecapture_exception.ImageCaptureException catch (exc) {
    // ignore: avoid_print
    print("Photo capture failed: ${exc.getMessage()}"); // Using print instead of Log.e
  }
}
```

## Project Structure

```
java_to_dart_translator_gemini/
├── .dart_tool/           # Dart configuration files
├── .idea/                # IntelliJ IDEA configuration
├── bin/
│   └── translator.dart   # Command line entry point
├── examples/
│   └── camera_example.java  # Example Java file for testing
├── lib/
│   └── java_to_dart_translator_gemini.dart  # Core translator implementation
├── test/                 # Test files
├── .gitignore
├── analysis_options.yaml
├── CHANGELOG.md
├── pubspec.lock
├── pubspec.yaml
└── README.md             # This file
```

## Future Improvements

- Add support for more complex Java/Kotlin constructs
- Improve error handling and feedback
- Add unit tests for translation accuracy
- Create a browser extension for auto-translating code on documentation websites
- Implement feedback mechanisms where translation errors are analyzed and fed back to improve results

## License

MIT License

## Acknowledgments

- Google Gemini API for providing the generative AI capabilities
- JNIgen project for creating the Dart FFI bindings for Java/Android APIs
