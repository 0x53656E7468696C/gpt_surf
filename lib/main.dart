import 'package:flutter/material.dart';
import 'package:gpt_wrapped/wid/webloader.dart';


void main()  {
  WidgetsFlutterBinding.ensureInitialized();
 

  runApp(const GPTSurfers());
}

class GPTSurfers extends StatelessWidget {
  const GPTSurfers({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Center(
          child: Scaffold(
            
            backgroundColor: Colors.transparent,
            body: Webloader(),
            
          ),
        ),
      ),
    );
    }
    }