import 'dart:async';
import 'package:flutter/material.dart';
import 'objectbox.g.dart';
import 'User.dart';
import 'package:animations/animations.dart';
import 'profile.dart';
import 'signup.dart';  // Import the profile page

Timer? _debounce;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await openStore(); // Open the ObjectBox store
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store store;

  MyApp({required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', store: store),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Store store;

  const MyHomePage({super.key, required this.title, required this.store});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool visibility = true;
  bool isTapped = false;

  void _toggleButton() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 200), () {
      setState(() {
        isTapped = !isTapped;
      });
    });
  }

  void _login() async {
    final box = widget.store.box<User>();
    final users = box.query(
        User_.email.equals(_emailController.text) &
        User_.password.equals(_passwordController.text)
    ).build().find();

    if (users.isNotEmpty) {
      final userId = users.first.id;
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProfilePage(store: widget.store,userId: userId,), // Pass the store to ProfilePage
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: Image.asset("assets/images/img.png", height: 300)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "LOGIN",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  contentPadding: EdgeInsets.all(5),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TextField(
                controller: _passwordController,
                obscureText: visibility,
                decoration: InputDecoration(
                  hintText: "Password",
                  contentPadding: EdgeInsets.all(5),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        visibility = !visibility;
                      });
                    },
                    icon: Icon(
                        visibility ? Icons.visibility_off : Icons.visibility),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 25.0),
                      child: Container(
                        width: 40,
                        height: 20,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: (isTapped) ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(100),
                            bottom: Radius.circular(100),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: (isTapped) ? null : 0,
                              right: (isTapped) ? 0 : null,
                              top: 0,
                              child: InkWell(
                                onTap: _toggleButton,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  alignment: (isTapped)
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white60,
                                        width: 2,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "Remember me",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: Text("Forgot Password?"),
                  ),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: _login,
              child: Text("LOGIN"),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.black,
                fixedSize: Size(200, 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "OR",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Log in with",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset("assets/images/logos.png"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  child: Text("Register now"),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(seconds: 1),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Signup(store: widget.store), // Pass the store to Signup page
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
