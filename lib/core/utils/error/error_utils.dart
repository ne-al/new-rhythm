import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ErrorUtils {
  void featureNotAvailable(BuildContext context) {
    toastification.show(
      context: context,
      description: const Text('This feature is not available yet'),
      autoCloseDuration: const Duration(seconds: 5),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      closeOnClick: true,
      showProgressBar: true,
    );
  }
}
