import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_database/firebase_database.dart';

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
      if (payload != null) {
        debugPrint('notification payload:  + $payload');
      }
    });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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

  Future<void> _scheduleDailyNotification(int hour, int minute) async {

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    print(now);
    print(scheduledDate);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Office',
      'Wazzup',
      scheduledDate,
      // _nextInstance(),

      // const NotificationDetails(
      //   android: AndroidNotificationDetails(
      //     'daily notification channel id',
      //     'daily notification channel name',
      //     'daily notification description'),
      // ),
      // androidAllowWhileIdle: true,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: DateTimeComponents.time);

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
      matchDateTimeComponents: DateTimeComponents.time);
  }

  void scheduleAlarm() async {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      // sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _scheduleDailyNotification(18, 45);
    await fetchQuotes();

    // await flutterLocalNotificationsPlugin.schedule(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
    // await flutterLocalNotificationsPlugin.periodicallyShow(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
    // await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Office', 'Wazzup', scheduledNotificationDateTime, platformChannelSpecifics);
  }

  Future<void> fetchQuotes() async{
    databaseReference.child("Quotes").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> quotesMap = snapshot.value;

      quotesMap.forEach((key, value) {
        Quote quote = new Quote(value['Quote'], value['Sent'], value['Upvotes'], value['Downvotes']);
        quotes.add(quote);
      });
      // print(quotes);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _incrementCounter,
        onPressed: scheduleAlarm,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Quote{
  final String quote;
  final int sent, upvotes, downvotes;

  Quote(this.quote, this.sent, this.upvotes, this.downvotes);


}