import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/domain/blocs/blocs.dart';
import 'package:login/ui/helpers/helpers.dart';
import 'package:login/ui/screens/home/home_page.dart';
import 'package:login/ui/screens/login/find_pw_page.dart';
import 'package:login/ui/screens/login/find_id_page.dart';
import 'package:login/ui/screens/login/find_pw_page.dart';
// import 'package:login/ui/screens/login/verify_email_page.dart';
import 'package:login/ui/themes/theme_colors.dart';
import 'package:login/ui/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController idController;
  late TextEditingController passwordController;
  final _keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    idController.clear();
    idController.dispose();
    passwordController.clear();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoadingAuthentication) {
          modalLoading(context, '확인 중...');
        } else if (state is FailureAuthentication) {
          Navigator.pop(context);

          // if (state.error == '메일을 확인해주세요') {
          //   Navigator.push(
          //       context,
          //       routeSlide(
          //           page: VerifyEmailPage(user_email: idController.text.trim())));
          // }

          errorMessageSnack(context, state.error);
        } else if (state is SuccessAuthentication) {
          userBloc.add(OnGetUserAuthenticationEvent());
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context, routeSlide(page: const HomePage()), (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SingleChildScrollView(
              child: Form(
                key: _keyForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    const TextCustom(
                        text: '앱 이름',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        color: ThemeColors.secondary),
                    const SizedBox(height: 10.0),
                    const TextCustom(
                      text: '계속하려면 로그인하세요',
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                    const SizedBox(height: 70.0), // 아이디
                    TextFieldNaru(
                      controller: idController,
                      hintText: '아이디',
                      // keyboardType: TextInputType.emailAddress,
                      // validator: validatedEmail,
                    ),
                    const SizedBox(height: 30.0), // 비밀번호
                    TextFieldNaru(
                      controller: passwordController,
                      hintText: '비밀번호',
                      isPassword: true,
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 80.0),
                    BtnNaru(
                      text: '로그인',
                      width: size.width,
                      onPressed: () {
                        if (_keyForm.currentState!.validate()) {
                          authBloc.add(OnLoginEvent(idController.text.trim(),
                              passwordController.text.trim()));
                        }
                      },
                    ),
                    const SizedBox(height: 30.0), // 비밀번호 찾기
                    Center(
                        child: InkWell(
                            onTap: () => Navigator.push(context,
                                routeSlide(page: const FindPasswordPage())),
                            child: const TextCustom(text: '비밀번호 찾기'))),
                    const SizedBox(height: 30.0), // 아이디 찾기
                    Center(
                        child: InkWell(
                            onTap: () => Navigator.push(
                                context, routeSlide(page: const FindIDPage())),
                            child: const TextCustom(text: '아이디 찾기')))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
