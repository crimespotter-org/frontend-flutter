import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExploreFilter extends StatefulWidget {
  const ExploreFilter({super.key});

  @override
  State<ExploreFilter> createState() => _ExploreFilterState();
}

class _ExploreFilterState extends State<ExploreFilter> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _tatortController = TextEditingController();
  TextEditingController _autorController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  CaseTypeNullable caseType = CaseTypeNullable.none;
  CaseStatusNullable caseState = CaseStatusNullable.none;
  DateTime? dateFilter;
  DateTime dateFilterBack = DateTime.now();
  bool filterDate = false;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(
          Icons.check,
          color: Colors.white,
        );
      }
      return const Icon(
        Icons.close,
        color: Colors.white,
      );
    },
  );
  final MaterialStateProperty<Color?> trackColor =
      MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return TColor.buttonColor2;
      }
      return null;
    },
  );
  final MaterialStateProperty<Color?> overlayColor =
      MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return TColor.buttonColor2;
      }
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey.shade400;
      }
      return null;
    },
  );
  @override
  void dispose() {
    _titleController.dispose();
    _tatortController.dispose();
    _autorController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/Backgroung.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            onChanged: (value) {
                              _titleController.text = value;
                            },
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                              labelText: 'Titel',
                              labelStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _titleController.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _autorController,
                            onChanged: (value) {
                              _autorController.text = value;
                            },
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                              labelText: 'Autor',
                              labelStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _autorController.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tatortController,
                            onChanged: (value) {
                              _tatortController.text = value;
                            },
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                              labelText: 'Tatort',
                              labelStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _tatortController.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Typ:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Set border color to white
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CaseTypeNullable>(
                                value: caseType,
                                onChanged: (value) {
                                  setState(() {
                                    caseType = value!;
                                  });
                                },
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                dropdownColor: TColor.backgroundColor,
                                items: CaseTypeNullable.values
                                    .map<DropdownMenuItem<CaseTypeNullable>>(
                                        (CaseTypeNullable value) {
                                  return DropdownMenuItem<CaseTypeNullable>(
                                    value: value,
                                    child: Text(
                                      TDeviceUtil
                                          .convertNullableCaseTypeToGerman(
                                              value),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                underline: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              caseType = CaseTypeNullable.none;
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Set border color to white
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CaseStatusNullable>(
                                value: caseState,
                                onChanged: (value) {
                                  setState(() {
                                    caseState = value!;
                                  });
                                },
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                dropdownColor: TColor.backgroundColor,
                                items: CaseStatusNullable.values
                                    .map<DropdownMenuItem<CaseStatusNullable>>(
                                        (CaseStatusNullable value) {
                                  return DropdownMenuItem<CaseStatusNullable>(
                                    value: value,
                                    child: Text(
                                      TDeviceUtil
                                          .convertNullableCaseStatusToGerman(
                                              value),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                underline: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              caseState = CaseStatusNullable.none;
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _dateController,
                                  cursorColor: Colors.white,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    labelText: 'Datum der Tat',
                                    labelStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Switch(
                              thumbIcon: thumbIcon,
                              value: filterDate,
                              overlayColor: overlayColor,
                              trackColor: trackColor,
                              thumbColor: const MaterialStatePropertyAll<Color>(
                                  Colors.black),
                              onChanged: (bool value) {
                                setState(() {
                                  if (value == false) {
                                    if (dateFilter != null) {
                                      dateFilterBack = dateFilter!;
                                    }
                                    dateFilter = null;
                                    _dateController.clear();
                                  } else {
                                    dateFilter ??= dateFilterBack;
                                    _dateController.text =
                                        DateFormat('dd.MM.yyyy')
                                            .format(dateFilter!);
                                  }
                                  filterDate = value;
                                });
                              },
                            ),
                          ],
                        ),
                        if (filterDate) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _selectDate(context),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: TColor.buttonColor,
                                  fixedSize: const Size(175, 40)),
                              child: const Text(
                                'Datum wählen',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 16,
                    endIndent: 16,
                  ),
                  ElevatedButton(
                    onPressed: () => _filter(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.buttonColor,
                        fixedSize: const Size(175, 40)),
                    child: const Text(
                      'Filter anwenden',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _filter(BuildContext context) {
    if (mounted) {
      var provider = Provider.of<CaseProvider>(context, listen: false);
      var userProvider =
          Provider.of<UserDetailsProvider>(context, listen: false);

      provider.filterForExplore(
          createdAt: filterDate == true ? dateFilter : null,
          title: _titleController.text,
          placeName: _tatortController.text,
          createdBy: _autorController.text,
          type: caseType,
          status: caseState,
          userProvider: userProvider);

      Navigator.pop(context);
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? dateFilterBack,
      firstDate: DateTime(1500),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateFilter = picked;

        if (dateFilter == null) {
          _dateController.clear();
        } else {
          _dateController.text = DateFormat('dd.MM.yyyy').format(dateFilter!);
        }
      });
    }
  }
}
