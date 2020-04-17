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

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_for_practice/camera.dart';
import 'package:flutter_for_practice/constants.dart';
import 'package:flutter_for_practice/edit.dart';
import 'package:flutter_for_practice/home.dart';

/// The list of available cameras.
List<CameraDescription> cameras;

/// Main function of the app.
Future<void> main() async {
  // Forced to use vertical orientation to avoid problems in camera.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.toString());
  }

  /// Inflate the given widget and attach it to the screen.
  runApp(
    // Using material design.
    MaterialApp(
      // Title of the app.
      title: "Camera",
      // Remove the "DEBUG" banner.
      debugShowCheckedModeBanner: false,
      // Theme of the app is blue.
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the [Home()] Page as the homepage.
      home: Home(),

      /// Set three views by routes.
      routes: <String, WidgetBuilder>{
        // Home view.
        HOME: (BuildContext context) => Home(),
        // Camera view, [cameras] as available cameras.
        CAMERA: (BuildContext context) => Camera(cameras),
        // Edit view, [null] as image path.
        EDIT: (BuildContext context) => Edit(null),
      },
    ),
  );
}
