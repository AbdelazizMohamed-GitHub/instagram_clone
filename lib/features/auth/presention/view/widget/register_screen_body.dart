import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_app/core/utils/app_colors.dart';
import 'package:instagram_app/core/utils/app_images.dart';
import 'package:instagram_app/core/widget/custom_button.dart';
import 'package:instagram_app/core/widget/custom_text_form.dart';
import 'package:instagram_app/features/auth/presention/view/widget/custom_or_divider.dart';
import 'package:instagram_app/features/auth/presention/view/widget/facebook_login.dart';
import 'package:instagram_app/features/auth/presention/view/widget/have_account.dart';

class RegisterScreenBody extends StatefulWidget {
  const RegisterScreenBody({super.key});

  @override
  State<RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<RegisterScreenBody> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  bool isObscure = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 100,
                ),
                SvgPicture.asset(AppImages.instagramWord),
                const SizedBox(
                  height: 24,
                ),
                CustomTextForm(
                  pIcon: Icons.person,
                  text: "Name",
                  textController: nameController,
                  obscureText: false,
                  kTybe: TextInputType.name,
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextForm(
                  pIcon: Icons.email,
                  text: "Email",
                  textController: emailController,
                  obscureText: false,
                  kTybe: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextForm(
                  pIcon: Icons.lock,
                  text: "Password",
                  textController: passwordController,
                  sIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: isObscure
                          ? const Icon(
                              Icons.visibility,
                              color: AppColors.blue,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: AppColors.blue,
                            )),
                  obscureText: isObscure,
                  kTybe: TextInputType.text,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(onPressed: () {}, text: "Register"),
                const SizedBox(
                  height: 15,
                ),
                const HaveAccount(),
                const SizedBox(
                  height: 15,
                ),
                const CustomOrDivider(),
                const SizedBox(
                  height: 50,
                ),
                const CustomFacebookLogin(
                  text: "Register in with Facebook",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
