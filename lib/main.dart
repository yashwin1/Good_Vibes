import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:splashscreen/splashscreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
List<Quote> quotes = [];

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));

  var initializationSettingsAndroid = AndroidInitializationSettings('codex_logo');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: (String? payload) async {
      await onSelectNotifications(payload);
    });

  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(MyApp());
}

tz.TZDateTime _nextInstance(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  print(now);
  print(scheduledDate);
  // if (scheduledDate.isBefore(now)) {
  //   scheduledDate = scheduledDate.add(const Duration(days: 1));
  // }
  return scheduledDate;
}

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

  await fetchQuotes();

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
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 43);

  if (id == 1){
    scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 02);
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Dose of positivity',
    quotes[0].quote,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_notif',
        'alarm_notif',
        'Channel for Alarm notification',
        icon: 'codex_logo',
        // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: quotes[0].key);

  // await flutterLocalNotificationsPlugin.schedule(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.periodicallyShow(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
}

Future onSelectNotifications(String? payload) async {

  if (payload == "0") {
    await scheduleNotification(id: 1);
  }
  else {
    await scheduleNotification(id: 0);
  }
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 10), () {
      Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key? key, required this.title}) : super(key: key);
  // final String title;

  @override
  MainScreen createState() => MainScreen();
}

class MainScreen extends State<MyHomePage> {
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
  //
  // // Future<void> _scheduleDailyNotification(int hour, int minute) async {
  // //
  // //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  // //   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  // //
  // //   print(now);
  // //   print(scheduledDate);
  // //
  // //   await flutterLocalNotificationsPlugin.zonedSchedule(
  // //     0,
  // //     'Office',
  // //     'Wazzup',
  // //     scheduledDate,
  // //     const NotificationDetails(
  // //       android: AndroidNotificationDetails(
  // //         'alarm_notif',
  // //         'alarm_notif',
  // //         'Channel for Alarm notification',
  // //         icon: 'codex_logo',
  // //         // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
  // //         largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
  // //       ),
  // //     ),
  // //     androidAllowWhileIdle: true,
  // //     uiLocalNotificationDateInterpretation:
  // //     UILocalNotificationDateInterpretation.absoluteTime,
  // //     matchDateTimeComponents: DateTimeComponents.time);
  // // }
  //
  // Future<void> scheduleNotification() async {
  //   var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'alarm_notif',
  //     'alarm_notif',
  //     'Channel for Alarm notification',
  //     icon: 'codex_logo',
  //     // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
  //     largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
  //   );
  //
  //   var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   Random random = new Random();
  //   int hour = random.nextInt(7) + 8;
  //   int minute = random.nextInt(60);
  //
  //   print(hour);
  //   print(minute);
  //
  //   // await _scheduleDailyNotification(18, 45);
  //   await fetchQuotes();
  //
  //
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 26);
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
  //
  //   // await flutterLocalNotificationsPlugin.schedule(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  //   // await flutterLocalNotificationsPlugin.periodicallyShow(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  //   // await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  // }
  //
  // Future onSelectNotification(String payload) async {
  //   scheduleNotification();
  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return new AlertDialog(
  //         title: Text("PayLoad"),
  //         content: Text("Payload : $payload"),
  //       );
  //     },
  //   );
  // }
  //
  // Future<void> fetchQuotes() async{
  //   databaseReference.child("Quotes").once().then((DataSnapshot snapshot){
  //     Map<dynamic, dynamic> quotesMap = snapshot.value;
  //
  //     quotesMap.forEach((key, value) {
  //       Quote quote = new Quote(value['Quote'], value['Sent'], value['Upvotes'], value['Downvotes']);
  //       quotes.add(quote);
  //     });
  //     // print(quotes);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
        title: Text('Good Vibes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '1',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _incrementCounter,
        onPressed: scheduleNotification,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Quote{
  final String quote, key;
  final int sent, upvotes, downvotes;

  Quote(this.key, this.quote, this.sent, this.upvotes, this.downvotes);


}