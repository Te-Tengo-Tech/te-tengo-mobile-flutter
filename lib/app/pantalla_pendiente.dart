import 'package:flutter/material.dart';

/// Screen whose task in docs/WORK_PLAN.md is still pending: only the prototype title.
class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente(this.titulo, {super.key});

  final String titulo;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text(titulo)));
}
