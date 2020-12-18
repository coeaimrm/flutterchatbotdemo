import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Facts extends StatelessWidget {
  Facts({this.text, this.name, this.user});

  final String text;
  final String name;
  final bool user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
                bottomLeft: user ? Radius.circular(10) : Radius.zero,
                bottomRight: !user ? Radius.circular(10) : Radius.zero,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}
