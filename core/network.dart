import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({Key? key, required this.child}) : super(key: key);

  @override
  _NetworkAwareWidgetState createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  late Stream<List<ConnectivityResult>> _connectivityStream; // استخدام Stream<List<ConnectivityResult>>
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged; // استخدم Stream<List<ConnectivityResult>> مباشرة
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>( // تحديث نوع البيانات إلى List<ConnectivityResult>
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // في حال وجود بيانات، نحدد ما إذا كانت الشبكة متوفرة
          _isOffline = snapshot.data?.contains(ConnectivityResult.none) ?? false;
        }

        return Stack(
          children: [
            widget.child, // المحتوى الرئيسي للتطبيق
            if (_isOffline) ...[
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 80, color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
