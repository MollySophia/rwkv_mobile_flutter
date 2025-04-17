import 'package:flutter/material.dart';
import 'package:halo/halo.dart';

class TextFieldTest extends StatefulWidget {
  const TextFieldTest({super.key});

  @override
  State<TextFieldTest> createState() => _TextFieldTestState();
}

class _TextFieldTestState extends State<TextFieldTest> {
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextFieldTest'),
      ),
      body: GD(
        onTap: () {
          _focusNode.unfocus();
        },
        child: C(
          decoration: const BD(color: kW),
          child: Co(
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
