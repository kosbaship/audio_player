import 'package:flutter/material.dart';

class DownloadProgressNotifier extends ValueNotifier<int> {
  DownloadProgressNotifier() : super(_initialValue);
  static const _initialValue = 0;
}
