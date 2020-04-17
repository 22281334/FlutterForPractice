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

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_file;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

/// Edit view of the app.
class Edit extends StatefulWidget {
  Edit(this.originalPath);

  /// The path of the clicked image in GridView.
  final String originalPath;

  /// Creates the mutable state for this widget at a given location in the tree.
  @override
  State<StatefulWidget> createState() {
    return _EditHomeScreenState();
  }
}

/// Set the Edit view as Stateless.
class _EditHomeScreenState extends State<Edit> {
  /// List for the edited image files.
  List<File> imageTemp = new List();

  /// List for the undo image files.
  List<File> undoTemp = new List();

  /// When this object is inserted into the tree.
  @override
  void initState() {
    // Add the path of the clicked image into [imageTemp] list.
    imageTemp.add(new File(widget.originalPath));
    super.initState();
  }

  /// Override this method to build widgets that depend on the state of the
  /// listenable.
  @override
  Widget build(BuildContext context) {
    // Creates a visual scaffold for material design widgets.
    return new Scaffold(
      // "Image Editor" as app bar of this app.
      appBar: new AppBar(
        title: new Text("Image Editor"),
      ),
      // Creates a widget that combines common painting, positioning, and
      // sizing widgets.
      body: new Container(
        // Display its children in a vertical array.
        child: new Column(
          children: <Widget>[
            // Align the buttons.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60.0,
                padding: EdgeInsets.all(10.0),
                // Creates a stack layout widget.
                child: Stack(
                  children: <Widget>[
                    // Align the crop button at center left.
                    Align(
                      alignment: Alignment.centerLeft,
                      // Crop button for cropping the photo.
                      child: IconButton(
                        icon: Icon(Icons.crop),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _cropImage,
                      ),
                    ),
                    // Align the rotate button at center.
                    Align(
                      alignment: Alignment.center,
                      // Rotate button for rotating the photo.
                      child: IconButton(
                        icon: Icon(Icons.rotate_left),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _rotateImage,
                      ),
                    ),
                    // Align the monochrome button at center right.
                    Align(
                      alignment: Alignment.centerRight,
                      // Monochrome button for grayscaling the photo.
                      child: IconButton(
                        icon: Icon(Icons.monochrome_photos),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _grayscaleImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Flexible widget for the image.
            new Flexible(
              // Always show the last image in the [imageTemp] list.
              child: new Image.file(imageTemp[imageTemp.length - 1]),
            ),
            // Align the buttons.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60.0,
                padding: EdgeInsets.all(10.0),
                // Creates a stack layout widget.
                child: Stack(
                  children: <Widget>[
                    // Align the undo button at center left.
                    Align(
                      alignment: Alignment.centerLeft,
                      // Undo button to undo the last edit action.
                      child: IconButton(
                        icon: Icon(Icons.undo),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _undo,
                      ),
                    ),
                    // Align the save button at center.
                    Align(
                      alignment: Alignment.center,
                      // Save button to save the image from the last image in
                      // [imageTemp] list.
                      child: IconButton(
                        icon: Icon(Icons.save),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _saveImage,
                      ),
                    ),
                    // Align the redo button at center right.
                    Align(
                      alignment: Alignment.centerRight,
                      // Redo button to redo the last undo action.
                      child: IconButton(
                        icon: Icon(Icons.redo),
                        iconSize: 30,
                        color: Colors.blueAccent,
                        highlightColor: Colors.red,
                        onPressed: _redo,
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

  /// Crop the photo.
  Future<Null> _cropImage() async {
    // Using [ImageCropper] to crop the photo and receive the cropped file.
    File croppedFile = await ImageCropper.cropImage(
      // Using the last photo in the [imageTemp] list.
      sourcePath: imageTemp[imageTemp.length - 1].path,
      toolbarTitle: 'Image Editor',
      toolbarColor: Colors.blue,
      toolbarWidgetColor: Colors.white,
    );
    // If the cropped file is not null.
    if (croppedFile != null) {
      // Add the cropped file into the [imageTemp] list.
      imageTemp.add(croppedFile);
      // Clear the [undoTemp] list.
      undoTemp = new List();
    }
    // Refresh the edit view.
    setState(() {});
  }

  /// Undo the last edit action.
  void _undo() {
    // If the current photo is not the original photo.
    if (imageTemp.length > 1) {
      // Move the last image in [imageTemp] list into [undoTemp] list.
      undoTemp.add(imageTemp.removeLast());
    }
    // Refresh the edit view.
    setState(() {});
  }

  /// Redo the last undo action.
  void _redo() {
    // If there is a photo in the [undoTemp] list, which means able to redo.
    if (undoTemp.length > 0) {
      // Move the last image in [undoTemp] list into [imageTemp] list.
      imageTemp.add(undoTemp.removeLast());
    }
    // Refresh the edit view.
    setState(() {});
  }

  /// Get the timestamp of current time.
  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  /// Set the image into grayscale.
  Future<Null> _grayscaleImage() async {
    // Convert the last image file in [imageTemp] list to image format by
    // [image/image.dart].
    image_file.Image monoImage = image_file
        .decodeImage(imageTemp[imageTemp.length - 1].readAsBytesSync());
    // Set the image into grayscale.
    monoImage = image_file.grayscale(monoImage);
    // Get cache directory.
    Directory extDir = await getApplicationDocumentsDirectory();
    // Create a new folder called cache.
    String dirPath = '${extDir.path}/cache';
    await new Directory(dirPath).create(recursive: true);
    // Add timestamp into filename.
    String filePath = '$dirPath/${timestamp()}.jpg';
    // Save the monochrome image as a jpg file and add into tne [imageTemp]
    // list.
    imageTemp.add(File(filePath)
      ..writeAsBytesSync(image_file.encodeJpg(
        monoImage,
      )));
    // Clear the [undoTemp] list.
    undoTemp = new List();
    // Refresh the edit view.
    setState(() {});
  }

  /// Rotate the image by -90 degree.
  Future<Null> _rotateImage() async {
    // Convert the last image file in [imageTemp] list to image format by
    // [image/image.dart].
    image_file.Image rotateImage = image_file
        .decodeImage(imageTemp[imageTemp.length - 1].readAsBytesSync());
    // Rotate the image by -90 degree.
    rotateImage = image_file.copyRotate(rotateImage, -90);
    // Get cache directory.
    Directory extDir = await getApplicationDocumentsDirectory();
    // Create a new folder called cache.
    String dirPath = '${extDir.path}/cache';
    await new Directory(dirPath).create(recursive: true);
    // Add timestamp into filename.
    String filePath = '$dirPath/${timestamp()}.jpg';
    // Save the rotated image as a jpg file and add into tne [imageTemp] list.
    imageTemp.add(
        File(filePath)..writeAsBytesSync(image_file.encodeJpg(rotateImage)));
    // Clear the [undoTemp] list.
    undoTemp = new List();
    // Refresh the edit view.
    setState(() {});
  }

  /// Save the image into gallery.
  Future<Null> _saveImage() async {
    // Get the file of the path of the clicked image in GridView.
    File originalFile = new File(widget.originalPath);
    // Change the original file by the last image file in the [imageTemp] list,
    // which is the current image showed on the edit view.
    originalFile
        .writeAsBytesSync(imageTemp[imageTemp.length - 1].readAsBytesSync());
    // Clear the cache.
    imageCache.clear();
    // Navigate back to main view and pop the image file path.
    Navigator.pop(context, originalFile.path);
  }
}
