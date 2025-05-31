import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class TextFieldTest extends ConsumerStatefulWidget {
  const TextFieldTest({super.key});

  @override
  ConsumerState<TextFieldTest> createState() => _TextFieldTestState();
}

class _TextFieldTestState extends ConsumerState<TextFieldTest> {
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final kW = ref.watch(P.app.qw);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextFieldTest'),
      ),
      body: GD(
        onTap: () {
          _focusNode.unfocus();
        },
        child: C(
          decoration: BD(color: kW),
          child: Column(
            children: [
              TextField(
                focusNode: _focusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
