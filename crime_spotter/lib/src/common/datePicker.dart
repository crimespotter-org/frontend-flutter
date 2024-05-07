import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  final Function(DateTime?)? selectedDateFunction;
  final RestorableDateTime selectedDate;
  const DatePicker(
      {super.key,
      required this.selectedDateFunction,
      required this.selectedDate,
      this.restorationId});

  final String? restorationId;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  late final RestorableRouteFuture<DateTime?> restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: widget.selectedDateFunction,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: widget.selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2025),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(widget.selectedDate, 'selected_date');
    registerForRestoration(
        restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => restorableDatePickerRouteFuture.present(),
        child: const Text('Datum anpassen'),
      ),
    );
  }
}
