/*
 * Copyright 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

/// Camera view of the app.
class Camera extends StatefulWidget {
  /// The list of available cameras.
  List<CameraDescription> cameras;
  Camera(this.cameras);

  /// Creates the mutable state for this widget at a given location in the tree.
  @override
  State<StatefulWidget> createState() {
    return _CameraHomeScreenState();
  }
}

/// Set the Camera view as Stateless.
class _CameraHomeScreenState extends State<Camera> {
  /// Path of the taken photo.
  String imagePath;

  /// A camera controller used to open the camera.
  CameraController controller;

  /// Detect preview the newly captured photo.
  bool preview = false;

  /// When this object is inserted into the tree.
  @override
  void initState() {
    // Select the rear camera.
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  /// Release the camera.
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// Override this method to build widgets that depend on the state of the
  /// listenable.
  @override
  Widget build(BuildContext context) {
    // If no available cameras.
    if (widget.cameras.isEmpty) {
      // Creates a widget that combines common painting, positioning, and
      // sizing widgets.
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    // If the camera is initialized, return empty Container.
    if (!controller.value.isInitialized) {
      return Container();
    }

    // If not in the preview view.
    if (!preview) {
      // Creates a visual scaffold for material design widgets.
      return new Scaffold(
        // "Camera" as app bar of this app.
        appBar: new AppBar(
          title: new Text("Camera"),
          // Used for removing return button.
          automaticallyImplyLeading: false,
        ),
        // Creates a widget that combines common painting, positioning, and
        // sizing widgets.
        body: new Container(
          // Display its children in a vertical array.
          child: new Column(
            children: <Widget>[
              // Flexible widget for Camera created by
              // [CameraPreview(controller)].
              new Flexible(
                child: CameraPreview(controller),
              ),
              // Align the buttons.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 120.0,
                  padding: EdgeInsets.all(20.0),
                  // Creates a stack layout widget.
                  child: Stack(
                    children: <Widget>[
                      // Align the camera button at center.
                      Align(
                        alignment: Alignment.center,
                        // Camera button for taking the photo.
                        child: IconButton(
                          icon: Icon(Icons.camera),
                          iconSize: 40,
                          color: Colors.blueAccent,
                          highlightColor: Colors.red,
                          onPressed: _captureImage,
                        ),
                      ),
                      // Align the exit button at center left.
                      Align(
                        alignment: Alignment.centerLeft,
                        // Exit button to exit the camera view.
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          iconSize: 40,
                          color: Colors.blueAccent,
                          highlightColor: Colors.red,
                          onPressed: _exitCamera,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // In the preview view.
    else {
      // Creates a visual scaffold for material design widgets.
      return new Scaffold(
        // "Camera" as app bar of this app.
        appBar: new AppBar(
          title: new Text("Camera"),
          // Used for removing return button.
          automaticallyImplyLeading: false,
        ),
        // Creates a widget that combines common painting, positioning, and
        // sizing widgets.
        body: new Container(
          // Display its children in a vertical array.
          child: new Column(
            children: <Widget>[
              // Flexible widget for preview Image.
              new Flexible(child: new Image.file(File(imagePath))),
              // Align the buttons.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 120.0,
                  padding: EdgeInsets.all(20.0),
                  // Creates a stack layout widget.
                  child: Stack(
                    children: <Widget>[
                      // Align the exit button at center left.
                      Align(
                        alignment: Alignment.centerLeft,
                        // Exit button to exit the preview.
                        child: IconButton(
                          icon: Icon(Icons.close),
                          iconSize: 40,
                          color: Colors.blueAccent,
                          highlightColor: Colors.red,
                          onPressed: _exitPreview,
                        ),
                      ),
                      // Align the save button at center right.
                      Align(
                        alignment: Alignment.centerRight,
                        // Save button to save the image.
                        child: IconButton(
                          icon: Icon(Icons.done),
                          iconSize: 40,
                          color: Colors.blueAccent,
                          highlightColor: Colors.red,
                          onPressed: _saveImage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Open the camera, [cameraDescription] as the rear camera.
  void onCameraSelected(CameraDescription cameraDescription) async {
    // Reset the old camera.
    if (controller != null) await controller.dispose();
    // Open the camera by [CameraController] and set resolution.
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    // Add listener for the camera controller.
    controller.addListener(() {
      // If camera is using then refresh the camera view.
      if (mounted) setState(() {});
      // Else show error message.
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    // Initialize the camera controller to get the new camera view,
    // if error then navigate back.
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showException(e);
      Navigator.pop(context, false);
    }
    // If camera is using then refresh the camera view.
    if (mounted) setState(() {});
  }

  /// Get the timestamp of current time.
  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  /// Capture the photo take by user.
  void _captureImage() {
    // Call [takePicture()] to take a photo and get the file path.
    takePicture().then((String filePath) {
      if (mounted) {
        // Save the file path to [imagePath].
        setState(() {
          imagePath = filePath;
        });
        // Photo is saved if the file path is not null.
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          setCameraResult();
        }
      }
    });
  }

  /// Exit camera and pop [null] since no photo captured.
  void _exitCamera() {
    Navigator.pop(context, null);
  }

  /// Exit the preview view and show camera view.
  void _exitPreview() {
    // Delete the preview file since [imageCache.clear()] may not working.
    if (new File(imagePath).existsSync()) {
      new File(imagePath).deleteSync();
      showMessage('Picture $imagePath deleted');
    }
    // Clear the cache.
    imageCache.clear();
    setState(() {
      imagePath = null;
    });
    preview = false;
  }

  /// Save the image to gallery and navigate back to the main view.
  void _saveImage() {
    // Using [ImageGallerySaver] to save the image into gallery.
    ImageGallerySaver.saveFile(imagePath);
    preview = false;
    // Navigate back and pop [imagePath] as the path of the photo.
    Navigator.pop(context, imagePath);
  }

  /// User takes the photo, show the preview of the photo.
  void setCameraResult() {
    // If the photo exists.
    if (new File(imagePath).existsSync()) {
      setState(() {
        imagePath = imagePath;
      });
      // Set the [preview] status to true.
      preview = true;
    }
    // If the photo not exists then show error message.
    else {
      showMessage('Error: Image not exists.');
    }
  }

  /// Save the cache photo captured by user, return the path of the photo.
  Future<String> takePicture() async {
    // if the camera is not initialized, show error message.
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }
    // Get cache directory.
    final Directory extDir = await getApplicationDocumentsDirectory();
    // Create a new folder called cache.
    final String dirPath = '${extDir.path}/cache';
    await new Directory(dirPath).create(recursive: true);
    // Add timestamp into filename.
    final String filePath = '$dirPath/${timestamp()}.jpg';
    // A capture is already pending, do nothing.
    if (controller.value.isTakingPicture) {
      return null;
    }
    // Save the cache photo.
    try {
      await controller.takePicture(filePath);
    }
    // If error then return null else return the path of the photo.
    on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  /// Show error message in the Logcat, [e] as the exception.
  void showException(CameraException e) {
    showMessage('Error: ${e.code}\n${e.description}');
  }

  /// Show message in the Logcat, print the [message].
  void showMessage(String message) {
    print(message);
  }
}
