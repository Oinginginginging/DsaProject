import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';
import 'package:prototype/getX/data_controller.dart';

import './components/calendar_week.dart';
import './components/calendar_day.dart';
import './components/calendar_month.dart';

//https://velog.io/@jun7332568/%ED%94%8C%EB%9F%AC%ED%84%B0flutter-%EB%8B%AC%EB%A0%A5-Event-%EA%B5%AC%ED%98%84%ED%95%B4%EB%B3%B4%EA%B8%B0-Tablecalendar-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC
void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OING',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime setDate = DateTime.now();
  var selectedIndex = 0;
  var title = 'Monthly Views';
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.put(DataController());
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = CalendarMonth(dataController);
        title = 'Monthly Views';
        break;
      case 1:
        page = CalendarWeek(dataController);
        title = 'Weekly Views';
        break;
      case 2:
        page = CalendarDay(dataController);
        title = 'Daily Views';
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
          iconSize: 30,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 25.0),
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 33,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 25.0),
            onPressed: () {},
            icon: const Icon(Icons.account_box_rounded),
            tooltip: 'User Info',
          )
        ],
        centerTitle: true,
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Month'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week_outlined), label: 'Week'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Daily'),
        ], // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
