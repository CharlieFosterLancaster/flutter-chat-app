import 'package:chat/pages/login_page.dart';
import 'package:chat/pages/users_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkToken(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }

  Future checkToken(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isValid = await authService.verifyToken();
    if (isValid) {
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: ( _, __, ___) => UsersPage(),
        transitionDuration: Duration(milliseconds: 0)
      ));
    } else {
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: ( _, __, ___) => LoginPage(),
        transitionDuration: Duration(milliseconds: 0)
      ));
    }
  }
}