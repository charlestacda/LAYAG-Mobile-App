import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/components/events.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/components/app_drawer.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Events>> selectedEvents;
  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;
  String date = DateFormat('MMMM dd, yyyy').format(DateTime.now());

  List<Events> getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  List<Events> getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final day in days) ...getEventsForDay(day),
    ];
  }

  @override
  void initState() {
    super.initState();

    selectedDay = focusedDay;
    selectedEvents = ValueNotifier(getEventsForDay(selectedDay!));
  }

  @override
  void dispose() {
    selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/school_calendar_header.png',
                  width: double.infinity,
                ),
              ),
              TableCalendar<Events>(
                focusedDay: focusedDay,
                firstDay: eventFirstDay,
                lastDay: eventLastDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                rangeStartDay: rangeStart,
                rangeEndDay: rangeEnd,
                calendarFormat: calendarFormat,
                rangeSelectionMode: rangeSelectionMode,
                eventLoader: getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xffD94141),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: AppConfig.appSecondaryTheme,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  defaultTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(color: AppConfig.appSecondaryTheme),
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  if (!isSameDay(selectedDay, selectedDay)) {
                    setState(() {
                      selectedDay = selectedDay;
                      focusedDay = focusedDay;
                      rangeStart = null;
                      rangeEnd = null;
                      rangeSelectionMode = RangeSelectionMode.toggledOff;
                    });

                    selectedEvents.value = getEventsForDay(selectedDay);
                  }
                },
                onRangeSelected: (DateTime? start, DateTime? end, DateTime focusedDay) {
                  setState(() {
                    selectedDay = null;
                    focusedDay = focusedDay;
                    rangeStart = start;
                    rangeEnd = end;
                    rangeSelectionMode = RangeSelectionMode.toggledOn;
                  });

                  if (start != null && end != null) {
                    selectedEvents.value = getEventsForRange(start, end);
                  } else if (start != null) {
                    selectedEvents.value = getEventsForDay(start);
                  } else if (end != null) {
                    selectedEvents.value = getEventsForDay(end);
                  }
                },
                onFormatChanged: (format) {
                  if (calendarFormat != format) {
                    setState(() {
                      calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: ValueListenableBuilder<List<Events>>(
                  valueListenable: selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () => {},
                              title: Text('${value[index]}'),
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ));
}
