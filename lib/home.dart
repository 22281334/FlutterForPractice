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
import 'package:image_gallery/image_gallery.dart';
import 'package:toast/toast.dart';

import 'package:comp5216assignment2/constants.dart';
import 'package:comp5216assignment2/edit.dart';

/// Home view of the app.
class Home extends StatefulWidget {
  Home();

  /// Creates the mutable state for this widget at a given location in the tree.
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

/// Set the Home view as Stateless.
class _MyHomePageState extends State<Home> {
  // List of images in GridView.
  List<Object> images = new List();
  // Detect camera permission.
  bool cameraPermission = true;

  /// When this object is inserted into the tree.
  @override
  void initState() {
    super.initState();
    // Get images from gallery.
    loadImageList();
    // Refresh the GridView every 3 seconds in order to avoid image changing
    // by other apps.(temporarily comment)
    /*
    setState(() {
      const oneSecond = const Duration(seconds: 3);
      new Timer.periodic(oneSecond, (Timer t) => loadImageList());
    });
    */
  }

  /// Get images from gallery into [images] list.
  Future<void> loadImageList() async {
    // Get all images by [FlutterGallaryPlugin] in [image_gallery].

    // By the error "_TypeError (type '_InternalLinkedHashMap<dynamic, dynamic>'
    // is not a subtype of type 'List<Object>')", in image_gallery - android -
    // FlutterGalleryPlugin, ArrayList<String> is returned instead of
    // HashMap<String, List>.
    List imagesTemp = await FlutterGallaryPlugin.getAllImages;

    // Refresh the view by the new [images] list.
    setState(() {
      this.images = imagesTemp;
    });
  }

  /// Override this method to build widgets that depend on the state of the
  /// listenable.
  @override
  Widget build(BuildContext context) {
    /// Creates a visual scaffold for material design widgets.
    return new Scaffold(
      // "Camera" as app bar of this app.
      appBar: new AppBar(
        title: new Text("Camera"),
      ),
      // Creates a widget that combines common painting, positioning, and
      // sizing widgets.
      body: new Container(
        // Display its children in a vertical array.
        child: new Column(
          children: <Widget>[
            // Flexible widget for GridView created by [_buildGrid()].
            new Flexible(
              child: _buildGrid(),
            ),
            // Display its children in a vertical array.
            new Column(
              children: [
                // Camera icon button used to open camera view.
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  color: Colors.blueAccent,
                  highlightColor: Colors.red,
                  // Click the button to open camera view by [_openCamera()].
                  onPressed: _openCamera,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Activate the camera which takes user to the camera view.
  Future _openCamera() async {
    print("Open Camera Button Clicked");
    // Check the camera permission.
    if (cameraPermission) {
      // Navigate to Camera view, return [imagePath] as the path of the new
      // image.
      final imagePath = await Navigator.of(context).pushNamed(CAMERA);
      print(imagePath);
      // If the camera is not allowed.
      if (imagePath == false) {
        // Show toast.
        Toast.show("MediaRecorderCamera permission not granted", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        // Set the camera permission to false.
        cameraPermission = false;
      }
      // If a photo is captured.
      if (imagePath != null) {
        // Since there is a delay for image stored in gallery,
        // delay one second and refresh the GridView.
        await new Future.delayed(new Duration(milliseconds: 1000));
        // Refresh the GridView
        loadImageList();
      }
    }
    // if the the camera is not allowed, show toast.
    else {
      Toast.show("MediaRecorderCamera permission not granted", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  /// Image in the GridView is clicked.
  ///
  /// Once the image in the GridView is clicked, take user to the Edit view and
  /// push [image[index]] as the path of the image where [index] is the index of
  /// the [images] list.
  Future _onImageClicked(index) async {
    print(images[index]);
    // Navigate to Edit view and push [image[index]].
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Edit(images[index])),
    );
  }

  /// Build the GridView, return GridView.extent constructor.
  Widget _buildGrid() {
    /// Creates a scrollable, 2D array of widgets with tiles that each have a
    /// maximum cross-axis extent.
    return GridView.extent(
        maxCrossAxisExtent: 150.0,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        // Return List<Widget> by [_buildGridTileList(images.length)].
        children: _buildGridTileList(images.length));
  }

  /// Return List<Widget> to create a GridView, [count] is the [images.length],
  /// the size of the [images] list.
  List<Container> _buildGridTileList(int count) {
    // Set [Container] as a [Widget].
    return List<Container>.generate(
      count,
      (int index) => Container(
        // Use [InkResponse] to handle click event.
        child: new InkResponse(
          // Convert every image paths to [Image] type.
          child: Image.file(
            File(images[index].toString()),
            width: 96.0,
            height: 96.0,
            fit: BoxFit.contain,
          ),
          // Image in the GridView is clicked and call [_onImageClicked(index)]
          // where [index] is the index in the [images] list.
          onTap: () => _onImageClicked(index),
        ),
      ),
    );
  }
}
