import 'package:flutter/material.dart';
import 'package:provider/provider.dart'
;
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/helpers/show_alert.dart';

import 'package:chat/widgets/blue_button.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * .9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(
                  title: 'Registro',
                ),
                _Form(),
                Labels(
                  route: 'login',
                  title: '¿Ya tienes una cuenta?',
                  subtitle: 'Ingresa ahora',
                ),
                Text(
                  'Términos y condiciones',
                  style: TextStyle(fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            textController: nameCtrl,
          ),
          CustomInput(
            icon: Icons.email_outlined,
            placeholder: 'Email',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          BlueButton(
            text: 'Crear cuenta',
            onPressed: authService.isLoading ? null : () async {

              FocusScope.of(context).unfocus();
             
              final status = await authService.register(nameCtrl.text, emailCtrl.text.trim(), passCtrl.text.trim());
              if (status == true) {
                socketService.connect();
                Navigator.pushReplacementNamed(context, 'users');
              } else {
                showAlert(context, 'Error', status);
              }
            },
          )
        ],
      ),
    );
  }
}
