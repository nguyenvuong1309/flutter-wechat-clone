import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: '26',
    countryCode: 'ZM',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Zambia',
    example: 'Zambia',
    displayName: 'Zambia',
    displayNameNoCountryCode: 'ZM',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(AssetsMenager.chatBubble),
            ),
            Text(
              'Flutter Chat Pro',
              style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add your phone number will send you a code to verify',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneNumberController,
              maxLength: 10,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                setState(() {
                  _phoneNumberController.text = value;
                });
              },
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Phone Number',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.fromLTRB(
                    8.0,
                    12.0,
                    8.0,
                    12.0,
                  ),
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                      );
                    },
                    child: Text(
                      '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                suffixIcon: _phoneNumberController.text.length > 9
                    ? authProvider.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : InkWell(
                            onTap: () {
                              // sign in with phone number
                              authProvider.signInWithPhoneNumber(
                                phoneNumber:
                                    '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                context: context,
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SignInWithEmailAndPasswordForm(onSubmit: signInWithEmailAndPassword)
          ],
        ),
      ),
    )));
  }

  void signInWithEmailAndPassword(String email, String password) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    authProvider.signInWithEmailAndPassword(
        email: email,
        password: password,
        onSuccess: () async {
          // 1. check if user exists in firestore
          bool userExists = await authProvider.checkUserExists();

          if (userExists) {
            // 2. if user exists,

            // * get user information from firestore
            await authProvider.getUserDataFromFireStore();

            // * save user information to provider / shared preferences
            await authProvider.saveUserDataToSharedPreferences();

            // * navigate to home screen
            navigate(userExits: true);
          } else {
            // 3. if user doesn't exist, navigate to user information screen
            navigate(userExits: false);
          }
        },
       
        onError: () {
          showSnackBar(context, "Login failed");
        });
  }

  void navigate({required bool userExits}) {
    if (userExits) {
      showSnackBar(context, "Login success");
      // navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      // navigate to user information screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}

class SignInWithEmailAndPasswordForm extends StatefulWidget {
  final void Function(String email, String password)? onSubmit;

  const SignInWithEmailAndPasswordForm({Key? key, this.onSubmit})
      : super(key: key);

  @override
  _SignInFormWidgetState createState() => _SignInFormWidgetState();
}

class _SignInFormWidgetState extends State<SignInWithEmailAndPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(
          _emailController.text,
          _passwordController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Add more email validation logic if necessary
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                // Add more password validation logic if necessary
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Center(child: Text('Sign In')),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthenticationProvider>(context, listen: false);
                authProvider.signInWithGoogle(
                  onSuccess: () async {
                    // 1. check if user exists in firestore
                    bool userExists = await authProvider.checkUserExists();

                    if (userExists) {
                      // 2. if user exists,

                      // * get user information from firestore
                      await authProvider.getUserDataFromFireStore();

                      // * save user information to provider / shared preferences
                      await authProvider.saveUserDataToSharedPreferences();

                      // * navigate to home screen
                      navigate(userExits: true);
                    } else {
                      // 3. if user doesn't exist, navigate to user information screen
                      navigate(userExits: false);
                    }
                  },
                );
              },
              child: const Center(child: Text('Sign In with Google')),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthenticationProvider>(context, listen: false);
                authProvider.signInWithFacebook(
                  onSuccess: () async {
                    // 1. check if user exists in firestore
                    bool userExists = await authProvider.checkUserExists();

                    if (userExists) {
                      // 2. if user exists,

                      // * get user information from firestore
                      await authProvider.getUserDataFromFireStore();

                      // * save user information to provider / shared preferences
                      await authProvider.saveUserDataToSharedPreferences();

                      // * navigate to home screen
                      navigate(userExits: true);
                    } else {
                      // 3. if user doesn't exist, navigate to user information screen
                      navigate(userExits: false);
                    }
                  },
                );
              },
              child: const Center(child: Text('Sign In with Facebook')),
            ),
          
          ],
        ),
      ),
    );
  }
  void navigate({required bool userExits}) {
    if (userExits) {
      showSnackBar(context, "Login success");
      // navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      // navigate to user information screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}
