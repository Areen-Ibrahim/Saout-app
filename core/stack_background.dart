import 'package:flutter/cupertino.dart';

class StackBackground extends StatelessWidget {
  final String urlImage;
  const StackBackground({super.key,
    required this.urlImage});

  @override
  Widget build(BuildContext context) {
    return  Opacity(
      opacity: 0.8,
      child: Container(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(urlImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
