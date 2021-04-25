import 'package:flutter/material.dart';

import 'main.dart';

class MyGrabbingWidget extends StatelessWidget {
  final VoidCallback? tap;
  final bool reverse;
  final AuthRepository? auth;


  const MyGrabbingWidget({Key? key, this.tap, this.reverse = false, this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tap?.call();
      },
      child: Container(
        color: Colors.grey,
        padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
              flex: 1,
              child: Text(
                'Welcome back, ${this.auth?.user?.email}',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
              Icon(Icons.expand_less),
           ]
         )
      ),
    );
  }
}