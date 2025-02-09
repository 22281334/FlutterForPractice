package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.camera.CameraPlugin;
import vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin;
import adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin;
import com.example.imagegallerysaver.ImageGallerySaverPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    CameraPlugin.registerWith(registry.registrarFor("io.flutter.plugins.camera.CameraPlugin"));
    ImageCropperPlugin.registerWith(registry.registrarFor("vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin"));
    FlutterGallaryPlugin.registerWith(registry.registrarFor("adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin"));
    ImageGallerySaverPlugin.registerWith(registry.registrarFor("com.example.imagegallerysaver.ImageGallerySaverPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
