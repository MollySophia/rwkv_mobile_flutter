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
