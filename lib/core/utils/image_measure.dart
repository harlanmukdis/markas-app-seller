import 'dart:async';

import 'package:flutter/widgets.dart';

/// Reads the pixel size of a network image.
///
/// `photos_json` entries must carry real `width`/`height`: the backend's photo
/// gate reads those numbers and never opens the file, so a wrong or missing
/// size makes `photos_ok` fail forever with nothing to point at. There is no
/// upload endpoint either — the store pastes a URL it hosts elsewhere — so
/// measuring is the only way the app can fill those fields honestly.
///
/// Returns null when the image cannot be loaded. On web that is usually the
/// host omitting CORS headers rather than a broken link, which the caller
/// cannot distinguish and the store must resolve by typing the size in.
Future<Size?> measureNetworkImage(
  String url, {
  Duration timeout = const Duration(seconds: 15),
}) {
  final completer = Completer<Size?>();
  final stream = NetworkImage(url).resolve(ImageConfiguration.empty);

  late final ImageStreamListener listener;
  void finish(Size? size) {
    if (completer.isCompleted) return;
    stream.removeListener(listener);
    completer.complete(size);
  }

  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      final size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      info.dispose();
      finish(size);
    },
    onError: (Object _, StackTrace? __) => finish(null),
  );

  stream.addListener(listener);
  return completer.future.timeout(timeout, onTimeout: () {
    finish(null);
    return null;
  });
}
