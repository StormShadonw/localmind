import 'package:flutter/material.dart';

void showError(context, message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.error,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      content: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.white),
      ),
    ),
  );
}
