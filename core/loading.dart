import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'color.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
      return Center(
        child: SpinKitRipple(
          color: ColorApp.oasisGreen,
          size: 56.0,
        ),
      );
  }
}
