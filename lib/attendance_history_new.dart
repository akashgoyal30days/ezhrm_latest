/*
credit to data
0 -> Absent
1 -> Leave Full Day
2 -> Leave Half Day
3 -> Attendance Full Day
4 -> Attendance Half Day
5 -> Work From Home
6 -> Short Leave
7 -> Attendance Submitted
8 -> ---------
9 -> Official Holiday
 */

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import 'constants.dart';
import 'drawer.dart';
import 'services/shared_preferences_singleton.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key key}) : super(key: key);

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CalendarController _calendarController = CalendarController();
  DateTime userSelectedDate = DateTime.now(), dateTimeToday;

  final List loadedMonths = [];
  final Map allLoadedDates = {};
  final Map<DateTime, List> holidays = {};
  bool showLoading = false;

  @override
  void initState() {
    dateTimeToday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    getAttendanceHistory(userSelectedDate);
    super.initState();
  }

  getAttendanceHistory(DateTime date) async {
    if (showLoading) return;
    if (date.difference(dateTimeToday).inDays > 0) return setState(() {});
    setState(() {
      showLoading = true;
    });
    String month = "${date.month.toString()}-${date.year.toString()}";
    if (loadedMonths.contains(month)) {
      setState(() {
        showLoading = false;
      });
      return;
    }
    loadedMonths.add(month);
    var urii = "$customurl/controller/process/app/attendance.php";
    final responsenew = await http.post(urii, body: {
      'type': 'fetch',
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'uid': SharedPreferencesInstance.getString('uid'),
      'month': date.month.toString(),
      'year': date.year.toString(),
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    var mydataatt = json.decode(responsenew.body);
    List responseDates = mydataatt["data"]["attendance"] ?? [];
    for (var element in responseDates) {
      if (element["date"] == null) continue;
      String creditID = element["credit_id"].toString();
      element["color"] = creditID == '0'
          ? Colors.red[800]
          : creditID == '1'
              ? Colors.red
              : creditID == '2'
                  ? Colors.red.shade100
                  : creditID == '3'
                      ? Colors.blue
                      : creditID == '4'
                          ? Colors.yellow
                          : creditID == '5'
                              ? Colors.blueAccent
                              : creditID == '6'
                                  ? Colors.purple
                                  : creditID == '7'
                                      ? Colors.black
                                      : creditID == '9'
                                          ? Colors.red
                                          : Colors.grey[300];
      /*
credit to data
0 -> Absent
1 -> Leave Full Day
2 -> Leave Half Day
3 -> Attendance Full Day
4 -> Attendance Half Day
5 -> Work From Home
6 -> Short Leave
7 -> Attendance Submitted
8 -> ---------
9 -> Official Holiday
 */

      element["credit"] = creditID == '0'
          ? "Absent"
          : creditID == '1'
              ? "Full Day Leave"
              : creditID == '2'
                  ? "Half Day Leave"
                  : creditID == '3'
                      ? "Full Day Attendance"
                      : creditID == '4'
                          ? "Half Day Attendance"
                          : creditID == '5'
                              ? "Work From Home"
                              : creditID == '6'
                                  ? "Short Leave"
                                  : creditID == '7'
                                      ? "Attendance Submitted"
                                      : creditID == '9'
                                          ? "Official Holiday"
                                          : "";
      allLoadedDates[element["date"]] = element;
      if (element["credit_id"].toString() == "9") {
        String date = element["date"];
        holidays[DateTime(
            int.parse(date.substring(0, 4)),
            int.parse(date.substring(5, 7)),
            int.parse(date.substring(8)))] = const [];
      }
    }
    log(allLoadedDates.toString());
    setState(() {
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDate =
        "${DateFormat("y").format(userSelectedDate)}-${DateFormat("MM").format(userSelectedDate)}-${DateFormat("dd").format(userSelectedDate)}";
    final bool checkInAvailable =
        (allLoadedDates[selectedDate] ?? {})["in_time"] != null &&
            (allLoadedDates[selectedDate] ?? {})["in_time"].toString() != " ";
    final bool checkOutAvailable =
        (allLoadedDates[selectedDate] ?? {})["out_time"] != null &&
            (allLoadedDates[selectedDate] ?? {})["out_time"].toString() != " ";
    final bool isOfficialHoliday =
        (allLoadedDates[selectedDate] ?? {})["credit_id"] == "9";
    return Scaffold(
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.attendanceHistory),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context, builder: (_) => const InfoWidget());
              },
              icon: const Icon(Icons.info))
        ],
        backgroundColor: Colors.blue,
        bottomOpacity: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          "Attendance History",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo,
                Colors.blue[600],
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              holidays: holidays,
              builders: CalendarBuilders(
                dayBuilder: (context, date, events) {
                  if (date.weekday == 7) {
                    return Center(
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (date.difference(dateTimeToday).inDays <= 0) {
                    String month = date.month < 10 ? "0" : "";
                    month = month + "${date.month}";
                    String day = date.day < 10 ? "0" : "";
                    day = day + "${date.day}";
                    var item = allLoadedDates["${date.year}-$month-$day"];
                    if (item != null) {
                      if (item["credit_id"].toString() == "9") {
                        return Center(
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: (item["color"] as Color).withOpacity(0.5),
                              shape: BoxShape.circle),
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ));
                    }
                  }
                  return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Color(0xff072a99)),
                      ));
                },
                selectedDayBuilder: (context, date, events) {
                  var now = dateTimeToday;
                  if (date.difference(now).inDays == 0) {
                    return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Color(0xff072a99), shape: BoxShape.circle),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  }
                  if (date.difference(now).inDays > 0) {
                    return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xff072a99),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  }
                  String month = date.month < 10 ? "0" : "";
                  month = month + "${date.month}";
                  String day = date.day < 10 ? "0" : "";
                  day = day + "${date.day}";
                  var item = allLoadedDates["${date.year}-$month-$day"];
                  if (item != null) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (item["color"] as Color).withOpacity(0.8),
                          shape: BoxShape.circle),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xff072a99), shape: BoxShape.circle),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                todayDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0x99072a99), shape: BoxShape.circle),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                canEventMarkersOverflow: true,
                holidayStyle: TextStyle(color: Colors.orange),
                weekendStyle: TextStyle(color: Color.fromRGBO(183, 28, 28, 1)),
              ),
              onVisibleDaysChanged: (_, ___, __) {
                getAttendanceHistory(_);
              },
              calendarController: _calendarController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDate, _, __) {
                setState(() => userSelectedDate = selectedDate);
                if (loadedMonths.contains(
                    "${userSelectedDate.month.toString()}-${userSelectedDate.year.toString()}")) {
                  return;
                }
                getAttendanceHistory(userSelectedDate);
              },
              weekendDays: const [DateTime.sunday],
            ),
            const Divider(indent: 5, endIndent: 5),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      DateFormat("dd MMM, y").format(userSelectedDate),
                      style: const TextStyle(
                        color: Color(0xff072a99),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  showLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: LoadingAnimationWidget.twistingDots(
                              leftDotColor: const Color(0xff072a99),
                              rightDotColor: Colors.blue,
                              size: 40,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            if (userSelectedDate
                                        .difference(dateTimeToday)
                                        .inDays <=
                                    0 &&
                                (allLoadedDates[selectedDate] ??
                                        {})["credit"] !=
                                    null &&
                                (allLoadedDates[selectedDate] ??
                                        {})["credit"] !=
                                    "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (allLoadedDates[selectedDate] ??
                                                {})["credit"]
                                            .toString() ??
                                        "",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: (allLoadedDates[selectedDate] ??
                                            {})["color"]),
                                  ),
                                ),
                              ),
                            if ((allLoadedDates[selectedDate] ??
                                        {})["credit_id"]
                                    .toString() !=
                                "0")
                              if (!isOfficialHoliday)
                                !checkInAvailable && !checkOutAvailable
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: const [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.orange,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  "No Data",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          if (checkInAvailable)
                                            Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    "Check In",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff072a99),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (allLoadedDates[
                                                              selectedDate] ??
                                                          {})["in_time"],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (checkOutAvailable)
                                            Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    "Check Out",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff072a99),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (allLoadedDates[
                                                              selectedDate] ??
                                                          {})["out_time"],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  "Attendance History",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff072a99)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Text(
                  "To understand the different colors used in the Attendance, please go through the data below",
                ),
              ),
              const InfoWidgetItems(
                  title: "Attendance Full Day", color: Colors.blue),
              const InfoWidgetItems(
                  title: "Attendance Half Day ", color: Colors.yellow),
              const InfoWidgetItems(
                  title: "Attendance Submitted", color: Colors.black),
              const InfoWidgetItems(title: "Leave Full Day", color: Colors.red),
               InfoWidgetItems(
                  title: "Leave Half Day", color: Colors.red.shade100),
              const InfoWidgetItems(title: "Short Leave", color: Colors.purple),
               InfoWidgetItems(
                  title: "Absent", color: Colors.red.shade800),
              const InfoWidgetItems(
                  title: "Work From Home", color: Colors.blueAccent),
              const InfoWidgetItems(title: "Others", color: Colors.grey),
              Center(
                child: TextButton(
                  onPressed: Navigator.of(context).pop,
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(const Color(0xff072a99))),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoWidgetItems extends StatelessWidget {
  const InfoWidgetItems({Key key, @required this.title, @required this.color})
      : super(key: key);
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          Expanded(
              child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ))
        ],
      ),
    );
  }
}
