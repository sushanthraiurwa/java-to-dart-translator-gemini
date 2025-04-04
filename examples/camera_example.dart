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