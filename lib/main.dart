import 'dart:async';

import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/FirebaseService.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
List<Quote> quotes = [];
double height = 0;
double width = 0;
FirebaseService service = new FirebaseService();
bool inBackground = true;
bool throughNotif = false;
String currQuote = '';
String currQuoteID = '';
String? selectedNotificationPayload;
BuildContext? globalBuildContext;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  // quotes.clear();
  await fetchQuotes();
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));

  var initializationSettingsAndroid = AndroidInitializationSettings('codex_logo');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: (String? payload) async {
      throughNotif = true;
      await onSelectNotifications(payload);
    });

  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? true) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    // String quoteID = selectedNotificationPayload!.substring(1);
    print(selectedNotificationPayload);
    throughNotif = true;
    onSelectNotifications(selectedNotificationPayload);
    print('throughNotif: $throughNotif');

    // SplashScreen();
    // print(payload);
    // print(quoteID);
    // fetchQuote(quoteID);

  }
  else {
    runApp(MyApp());
  }

  runApp(MyApp());

}

// tz.TZDateTime _nextInstance(int hour, int minute) {
//   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
//   print(now);
//   print(scheduledDate);
//   // if (scheduledDate.isBefore(now)) {
//   //   scheduledDate = scheduledDate.add(const Duration(days: 1));
//   // }
//   return scheduledDate;
// }

// Future<void> _scheduleDailyNotification(int hour, int minute) async {
//
//   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
//
//   print(now);
//   print(scheduledDate);
//
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     0,
//     'Office',
//     'Wazzup',
//     scheduledDate,
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'alarm_notif',
//         'alarm_notif',
//         'Channel for Alarm notification',
//         icon: 'codex_logo',
//         // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
//         largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
//       ),
//     ),
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//     UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.time);
// }

Future<void> scheduleNotification({int id = 0}) async {
  // var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
  print('function called');
  // quotes = [];
  fetchQuotes();

  // await fetchQuotes();

  // const BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
  //   quotes[0].quote,
  //   htmlFormatBigText: true,
  //   htmlFormatContentTitle: true,
  //   htmlFormatSummaryText: true,
  // );

  // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //   'alarm_notif',
  //   'alarm_notif',
  //   'Channel for Alarm notification',
  //   icon: 'codex_logo',
  //   // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
  //   largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
  //   // styleInformation: bigTextStyleInformation,
  // );

  // var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  Random random = new Random();
  int hour = random.nextInt(7) + 8;
  int minute = random.nextInt(60);

  if (id == 1){
    hour = random.nextInt(7) + 16;
  }

  // await _scheduleDailyNotification(18, 45);


  //TODO: Change schceduled time to hour, minute
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  // tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 13, 13);
  tz.TZDateTime scheduledDate = now;
  scheduledDate = scheduledDate.add(const Duration(seconds: 15));
  print(now);
  print(scheduledDate);

  // if (id == 1){
  //   scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 13, 12);
  // }

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  //TODO: Change notification icon
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Dose of positivity',
    quotes[0].quote,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'Dose of Positivity',
        'Dose of Positivity',
        'Channel for Dose of Positivity',
        icon: 'codex_logo',
        // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: id.toString() + quotes[0].key);

  quotes.clear();

  // await flutterLocalNotificationsPlugin.schedule(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.periodicallyShow(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
}

Future onSelectNotifications(String? payload) async {

  String quoteID = payload!.substring(1);
  currQuoteID = quoteID;
  fetchQuote(quoteID);
  // await fetchQuotes();

  // scheduleNotification();

  if (payload[0] == "0") {
    // main();
    // SplashScreen();
    // String quoteID = payload.substring(1);
    // fetchQuote(quoteID);
    // DoseOfPositivity(payload);
    scheduleNotification(id: 1);
  }
  else {
    // fetchQuote(quoteID);
    scheduleNotification(id: 0);
  }

  if (!inBackground) {
    Navigator.of(globalBuildContext!).pushReplacement(MaterialPageRoute(builder: (_) => SplashScreen()));
  }

}

//TODO: Call this function during splash screen loading to avoid delay and error of fetchcing from firebase database
Future<void> fetchQuote(String quoteID) async{
  // print(quoteID);
  databaseReference.child("Quotes/$quoteID").once().then((DataSnapshot snapshot){
    currQuote = snapshot.value['Quote'];
    print('fetchQuote: $currQuote');
  });
}

Future<void> fetchQuotes() async{
  databaseReference.child("Quotes").orderByChild('Sent').once().then((DataSnapshot snapshot){
    Map<dynamic, dynamic> quotesMap = snapshot.value;

    quotesMap.forEach((key, value) {
      Quote quote = new Quote(key, value['Quote'], value['Sent'], value['Upvotes'], value['Downvotes']);
      quotes.add(quote);
    });
  });
}

Future<void> likeQuote(String quoteID) async{
  databaseReference.child("Quotes/$quoteID/Upvotes").set(ServerValue.increment(1));
}

Future<void> dislikeQuote(String quoteID) async{
  databaseReference.child("Quotes/$quoteID/Upvotes").set(ServerValue.increment(-1));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: SplashScreen(),
    );
  }
}

///////////////////////////////////////////// SPLASH SCREEN ///////////////////////////////////////////

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 4), () {

      print('throughNotif: $throughNotif');

      if (FirebaseAuth.instance.currentUser != null){

        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DoseOfPositivity()));
        if (throughNotif){
          throughNotif = false;
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DoseOfPositivity()));
        }
        else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        }
      }
      else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double widthTemp = MediaQuery.of(context).size.width;
    double heightTemp = MediaQuery.of(context).size.height;
    width = widthTemp;
    height = heightTemp;
    globalBuildContext = context;

    return Scaffold(
      backgroundColor: Color(0xffBCDAEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.15,
            ),
            Image.asset(
              'assets/splash_image.png',
              height: height * 0.45,
              width: width,
            ),
            CircularProgressIndicator(),
            SizedBox(
              height: height * 0.07,
            ),
            Text(
              'Good Vibes',
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Text(
              'Vibe high and the magic around \n you will unfold.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////// LOGIN SCREEN ///////////////////////////////////////////

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    globalBuildContext = context;

    return Scaffold(
      backgroundColor: Color(0xffBCDAEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            Text(
              'Good Vibes',
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
            Image.asset(
              'assets/login_image.png',
              height: height * 0.45,
              width: width,
            ),
            SizedBox(
              height: height * 0.1,
            ),
            // TODO: Replace mail icon with google icon
            SignInButtonBuilder(
              text: 'Sign in with Google',
              textColor: Colors.black87,
              icon: Icons.email,
              iconColor: Colors.black12,
              // image: Image.asset('assets/google_icon'),
              // mini: true,
              // onPressed: () {},
              backgroundColor: Colors.white,
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  await service.signInwithGoogle();
                  if (throughNotif){
                    throughNotif = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DoseOfPositivity()));
                  }
                  else {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
                  }
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
                  // Navigator.pushNamedAndRemoveUntil(context, Constants.homeNavigate, (route) => false);
                } catch(e){
                  if(e is FirebaseAuthException){
                    Fluttertoast.showToast(
                      msg: e.message!,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1
                    );
                  }
                }
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


///////////////////////////////////////////// HOMEPAGE SCREEN ///////////////////////////////////////////

class HomePage extends StatefulWidget {
  // MyHomePage({Key? key, required this.title}) : super(key: key);
  // final String title;

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    inBackground = state == AppLifecycleState.paused;
    print('inBackground: $inBackground');
  }

  void notifDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        // double width = MediaQuery.of(context).size.width;
        // double height = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.7),
          content: Container(
            width: width * 0.8,
            height: height * 0.2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      'Do you want to receive motivation, inspiration, and positivity everyday in the form of handpicked quotes?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: Color(0xff886F75),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: 'Subscribed successfully!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1
                    );
                    scheduleNotification(id: 0);
                  },
                  child: Text(
                    'Yes',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff886F75),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.6)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
                    elevation: MaterialStateProperty.all(0),
                  )
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await flutterLocalNotificationsPlugin.cancelAll();
                    Fluttertoast.showToast(
                      msg: 'Unsubscribed successfully!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1
                    );
                  },
                  child: Text(
                    'No',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff886F75),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.6)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
                    elevation: MaterialStateProperty.all(0),
                  )
                ),
              ],
            ),
            SizedBox(
              height: height * 0.01,
            ),
          ],
        );
      });
  }

  final myController = TextEditingController();
  // @override
  // void dispose() {
  //   // Clean up the controller when the widget is removed from the widget tree.
  //   myController.clear();
  //   super.dispose();
  // }

  Future<void> addQuoteToDB(String quoteText) async{
    databaseReference.child('Users/${FirebaseAuth.instance.currentUser!.uid}/NewQuotes').push().set({
      'quote': quoteText,
    });

    databaseReference.child('NewQuotes/').push().set({
      'quote': quoteText,
    });

  }

  void quoteAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // double width = MediaQuery.of(context).size.width;
        // double height = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.7),
          content: Container(
            width: width * 0.8,
            height: height * 0.2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      controller: myController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'Enter Quote',
                        hintStyle: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xff886F75).withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ),
                      style: GoogleFonts.manrope(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xff886F75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: 'Quote added successfully!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1
                    );
                    await addQuoteToDB(myController.text);
                    myController.clear();
                    // print(myController.text);
                    // dispose();
                  },
                  child: Text(
                    'Add',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff886F75),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.6)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 35)),
                    elevation: MaterialStateProperty.all(0),
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    myController.clear();
                    // dispose();
                  },
                  child: Text(
                    'Discard',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff886F75),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.6)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                    elevation: MaterialStateProperty.all(0),
                  )
                ),
              ],
            ),
            SizedBox(
              height: height * 0.01,
            ),
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {

    // print(throughNotif);
    // if (throughNotif){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DoseOfPositivity()));
    // }

    globalBuildContext = context;

    double widthTemp = MediaQuery.of(context).size.width;
    double heightTemp = MediaQuery.of(context).size.height;
    width = widthTemp;
    height = heightTemp;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: new AppBar(
        title: new Text("",),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Sign out"),
                value: 1,
              ),
            ],
            onSelected: (value) {
              service.signOutFromGoogle();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/homepage_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Welcome, \n ${FirebaseAuth.instance.currentUser!.displayName!}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.indieFlower(
                    textStyle: TextStyle(
                      fontSize: 46,
                      // color: Colors.white,
                      color: Color(0xff744B63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.5,
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: width * 0.75, height: height * 0.075),
                child: ElevatedButton.icon(
                  onPressed: notifDialog,
                  label: Text(
                    'Dose of Positivity',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.notifications),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xffBF9D9B).withOpacity(0.9)),
                    // padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                  )
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: width * 0.75, height: height * 0.075),
                child: ElevatedButton.icon(
                  onPressed: quoteAddDialog,
                  label: Text(
                    'Add Quotes',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.add),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.50)),
                    // padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///////////////////////////////////////////// DOSE OF POSITIVITY SCREEN ///////////////////////////////////////////

class DoseOfPositivity extends StatefulWidget {
  const DoseOfPositivity({Key? key}) : super(key: key);

  @override
  _DoseOfPositivityState createState() => _DoseOfPositivityState();
}

class _DoseOfPositivityState extends State<DoseOfPositivity> {

  @override
  Widget build(BuildContext context) {

    double widthTemp = MediaQuery.of(context).size.width;
    double heightTemp = MediaQuery.of(context).size.height;
    width = widthTemp;
    height = heightTemp;
    print('DoseOfPositivity: $currQuote');
    globalBuildContext = context;
    bool upvoted = false;
    bool downvoted = false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: new AppBar(
        title: new Text("",),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
          },
          child: Icon(
            Icons.home,
          ),
        ),
        actions: [
          PopupMenuButton(
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Sign out"),
                value: 1,
              ),
            ],
            onSelected: (value) {
              service.signOutFromGoogle();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/homepage_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: height * 0.15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Dose of Positivity',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.indieFlower(
                    textStyle: TextStyle(
                      fontSize: 46,
                      // color: Colors.white,
                      color: Color(0xff744B63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Container(
                  width: width * 0.8,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 20.0),
                          child: Text(
                            currQuote,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                fontSize: 24,
                                color: Color(0xff886F75),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    color: Colors.green.withOpacity(0.8),
                    iconSize: 30.0,
                    onPressed: () {
                      if (!upvoted){
                        likeQuote(currQuoteID);
                        Fluttertoast.showToast(
                          msg: 'Upvoted! :)',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                        upvoted = true;
                      }
                      else{
                        Fluttertoast.showToast(
                          msg: 'Already upvoted',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    color: Colors.red.withOpacity(0.8),
                    iconSize: 30.0,
                    onPressed: () {
                      if (!downvoted){
                        dislikeQuote(currQuoteID);
                        Fluttertoast.showToast(
                          msg: 'Downvoted :(',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1
                        );
                        downvoted = true;
                      }
                      else{
                        if (downvoted){
                          Fluttertoast.showToast(
                            msg: 'Already downvoted',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1
                          );
                        }
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


///////////////////////////////////////////// QUOTE CLASS ///////////////////////////////////////////

class Quote{
  final String quote, key;
  final int sent, upvotes, downvotes;

  Quote(this.key, this.quote, this.sent, this.upvotes, this.downvotes);

}