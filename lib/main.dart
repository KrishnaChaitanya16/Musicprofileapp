import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muiscprofileapp/pages/landingpage.dart';
import 'package:muiscprofileapp/providers/BottomNavBarprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: 'AIzaSyB-yyZQjujuElK8EaEQK2h0USnFU6p3LyY', appId: "com.example.muiscprofileapp", messagingSenderId: 'messagingSenderId', projectId: "musicprofileapp",storageBucket: "musicprofileapp.appspot.com")
  );
  await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.playIntegrity);

    runApp(

        MyApp()
      );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavigationBarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Landingpage(),
      ),
    );
  }
}


