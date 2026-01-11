import 'package:flutter/material.dart';

class ShowConfirmDialog {
  /// Shows a confirmation dialog with customizable title and content.
  /// Returns `true` if user confirms, `false` if cancels or dismisses.
  static Future<bool> show(
    BuildContext context, {
    String title = "Confirm deletion",
    String content = "Are you sure you want to delete this task?",
    String cancelText = "Cancel",
    String confirmText = "Confirm",
  }) async {
    final bool result =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap a button
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false; // if dialog is dismissed without selection, return false
    return result;
  }
}
