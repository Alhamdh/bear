import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String animationURL;
  Artboard? _teddyArtboard;
  SMITrigger? successTrigger, failTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? numLook;

  StateMachineController? stateMachineController;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    animationURL = 'assets/login.riv';
    rootBundle.load(animationURL).then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      stateMachineController =
          StateMachineController.fromArtboard(artboard, 'Login Machine');

      if (stateMachineController != null) {
        artboard.addController(stateMachineController!);
        stateMachineController!.inputs.forEach((e) {
          debugPrint(e.runtimeType.toString());
          debugPrint("name${e.name}End");
        });

        stateMachineController!.inputs.forEach((element) {
          if (element.name == "trigSuccess") {
            successTrigger = element as SMITrigger;
          } else if (element.name == "trigFail") {
            failTrigger = element as SMITrigger;
          } else if (element.name == "isHandsUp") {
            isHandsUp = element as SMIBool;
          } else if (element.name == "isChecking") {
            isChecking = element as SMIBool;
          } else if (element.name == "numLook") {
            numLook = element as SMINumber;
          }
        });
      }
      setState(() => _teddyArtboard = artboard);
    });
    super.initState();
  }

  void handsOnTheEyes() {
    isHandsUp?.change(true);
  }

  void lookOnTheField() {
    isHandsUp?.change(false);
    isChecking?.change(true);
    numLook?.change(0);
  }

  void moveEyeBalls(val) {
    numLook?.change(val.length.toDouble());
  }

  void login() async {
    await isChecking?.change(false);
    await isHandsUp?.change(false);

    if (_email.text == "Flutter" && _password.text == "Plabs") {
      successTrigger?.fire();
    } else {
      failTrigger?.fire();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd6e2ea),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 400,
              height: 300,
              child: Rive(
                artboard: _teddyArtboard!,
                fit: BoxFit.fitWidth,
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 400,
              padding: const EdgeInsets.only(bottom: 15),
              margin: const EdgeInsets.only(bottom: 15 * 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 15 * 2),
                    TextField(
                      controller: _email,
                      onTap: lookOnTheField,
                      onChanged: moveEyeBalls,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14),
                      cursorColor: const Color(0xffb04863),
                      decoration: const InputDecoration(
                        hintText: "Email",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusColor: Color(0xffb04863),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffb04863),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _password,
                      onTap: handsOnTheEyes,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      style: const TextStyle(fontSize: 14),
                      cursorColor: const Color(0xffb04863),
                      decoration: const InputDecoration(
                        hintText: "Password",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusColor: Color(0xffb04863),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffb04863),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb04863),
                      ),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
