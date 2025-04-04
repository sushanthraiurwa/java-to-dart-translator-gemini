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