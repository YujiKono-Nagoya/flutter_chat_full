import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool watch;

  MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.watch,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool visibility = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: visibility ? 1 : null,
      controller: widget.controller,
      obscureText: widget.watch ? visibility : false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.watch
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    visibility = !visibility;
                  });
                },
                child: Icon(
                  visibility ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }
}

class MyEmailTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool watch;
  late bool emailvalidation;

  MyEmailTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.watch,
    required this.emailvalidation,
  }) : super(key: key);

  @override
  State<MyEmailTextField> createState() => _MyEmailTextFieldState();
}

class _MyEmailTextFieldState extends State<MyEmailTextField> {
  late bool visibility = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: visibility ? 1 : null,
      controller: widget.controller,
      obscureText: widget.watch ? visibility : false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: widget.emailvalidation
              ? BorderSide(color: Colors.red)
              : BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: widget.emailvalidation
              ? BorderSide(color: Colors.red)
              : BorderSide(color: Colors.black, width: 2),
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.watch
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    visibility = !visibility;
                  });
                },
                child: Icon(
                  visibility ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }
}

class MyPasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool watch;
  late bool passwordvalidation;

  MyPasswordTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.watch,
    required this.passwordvalidation,
  }) : super(key: key);

  @override
  State<MyPasswordTextField> createState() => _MyPasswordTextFieldState();
}

class _MyPasswordTextFieldState extends State<MyPasswordTextField> {
  late bool visibility = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: visibility ? 1 : null,
      controller: widget.controller,
      obscureText: widget.watch ? visibility : false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: widget.passwordvalidation
              ? BorderSide(color: Colors.red)
              : BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: widget.passwordvalidation
              ? BorderSide(color: Colors.red)
              : BorderSide(color: Colors.black, width: 2),
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.watch
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    visibility = !visibility;
                  });
                },
                child: Icon(
                  visibility ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }
}
