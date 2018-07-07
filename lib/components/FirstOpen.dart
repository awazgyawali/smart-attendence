import 'package:flutter/material.dart';

class FirstOpenPrompt extends StatefulWidget {
  @override
  _FirstOpenPromptState createState() => _FirstOpenPromptState();
}

class _FirstOpenPromptState extends State<FirstOpenPrompt> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Text("Yay, you created your company profile sucessfully."),
      ),
    );
  }
}
