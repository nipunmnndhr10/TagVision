import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/screens/gallery_screen.dart';
import 'package:img_cls/screens/signup_screen.dart';
import 'package:img_cls/utils/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //! LOGIN FUNC
  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.toString(),
        password: _passwordController.text.toString(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GalleryScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ShowPopup.showError(context, e.toString());
    } catch (e) {
      debugPrint(e.toString());
      ShowPopup.showError(context, e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // login() {
  //   _auth
  //       .signInWithEmailAndPassword(
  //         email: _emailController.text.toString(),
  //         password: _passwordController.text.toString(),
  //       )
  //       .then((value) {})
  //       .onError((error, stackTrace) {
  //         ShowPopup.showError(context, error.toString());
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // close app with confirmation
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF121212),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //
              const SizedBox(height: 15),

              // Logo and title
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/TagVision_logo.png",
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(height: 24),
                    Text(
                      "Join TagVision",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Smart Gallery management starts here.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF888888),
                        // fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Email field
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Email Address',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    const SizedBox(height: 8),

                    //!FORMS
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF2D2D2D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide
                                    .none, // remove white outline of field
                              ),
                              hintText: "hello@gmail.com",
                              hintStyle: TextStyle(color: Colors.grey[400]),

                              //spacing between the text and the field’s border
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Cannot leave this empty.";
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          //password field
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF2D2D2D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[400],
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),

                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return "Enter a strong password";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          //confirm pw field
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Confirm Password",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,

                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF2D2D2D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[400],
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    //! signup button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // login func
                          if (_formKey.currentState!.validate()) {
                            // refers to curr state of each form and calls the validator of every TextField
                            // if each validator returns:
                            //  null -> field is valid
                            // String -> error message
                            // print("nav to sign up");
                            login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7AFF),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            loading
                                ? CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                            const SizedBox(width: 8),
                            // const Icon(
                            //   Icons.arrow_forward,
                            //   color: Colors.white,
                            // ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    //divider with "or continue with"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[600], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or Continue with",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[600], thickness: 1),
                        ),
                      ],
                    ),

                    //Google logo button
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/google-1015751_640.webp',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // navigate to sign up Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: const Color(0xFF4A7AFF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
