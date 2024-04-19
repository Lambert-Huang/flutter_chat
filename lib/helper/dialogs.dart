import 'package:flutter/material.dart';

abstract class SnackContent {
  const SnackContent();
  Color get backgroundColor;
  String get content;
}

class SnackContentMessage extends SnackContent {
  final String message;
  const SnackContentMessage({required this.message});
  @override
  Color get backgroundColor => Colors.blue.withOpacity(.8);
  @override
  String get content => message;
}

class SnackContentError extends SnackContent {
  final String errorMessage;
  const SnackContentError({required this.errorMessage});
  @override
  Color get backgroundColor => Colors.red.withOpacity(.8);
  @override
  String get content => 'Error: $errorMessage';
}

class Dialogs {
  static void showSnackbar(BuildContext context, SnackContent snackContent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackContent.content),
        backgroundColor: snackContent.backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
