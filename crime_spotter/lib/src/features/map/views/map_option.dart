import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/map_provider.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

enum FilterType {
  createdBy,
  caseType,
  status,
  title,
  placeName,
  createdAt,
}

class TMapOption extends StatefulWidget {
  final MapController controller;
  final Map<GeoPoint, List<Placemark>> markers;
  final Map<FilterType, String?> selectedFilter;
  const TMapOption(
      {super.key,
      required this.controller,
      required this.markers,
      required this.selectedFilter});

  @override
  State<TMapOption> createState() => _TMapOptionState();
}

class _TMapOptionState extends State<TMapOption> {
  bool dateIsFiltered = false;
  DateTime selectedDate = DateTime.now();

  final TextEditingController _titelController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();

  final List<String> filterName = [
    'Autor',
    'Fallart',
    'Status',
    'Titel',
    'Tatort',
    'Tatdatum',
  ];

  @override
  void initState() {
    super.initState();
    _titelController.text = widget.selectedFilter[FilterType.title] ?? '';
    _placeNameController.text =
        widget.selectedFilter[FilterType.placeName] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaseProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage("assets/Backgroung.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Optionen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: const DecorationImage(
                                image: AssetImage("assets/LogIn-Card.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: ListTile(
                              subtitle: FilterType.values[index] !=
                                      FilterType.createdAt
                                  ? buildInputBox(
                                      title: filterName[index],
                                      type: FilterType.values[index],
                                    )
                                  : buildDatePicker(),
                              trailing: GestureDetector(
                                onTap: () => {
                                  setState(
                                    () {
                                      widget.selectedFilter[
                                          FilterType.values[index]] = null;

                                      if (FilterType.values[index] ==
                                          FilterType.createdAt) {
                                        dateIsFiltered = false;
                                      } else if (FilterType.values[index] ==
                                          FilterType.placeName) {
                                        _placeNameController.text = '';
                                      } else if (FilterType.values[index] ==
                                          FilterType.title) {
                                        _titelController.text = '';
                                      }
                                    },
                                  ),
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemCount: filterName.length,
                      ),
                    ),
                    const Divider(),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            TColor.buttonColor),
                      ),
                      onPressed: () {
                        try {
                          provider.applyFilter(
                            createdAt: dateIsFiltered ? selectedDate : null,
                            title: widget.selectedFilter[FilterType.title],
                            createdBy:
                                widget.selectedFilter[FilterType.createdBy],
                            placeName:
                                widget.selectedFilter[FilterType.placeName],
                            type: TDeviceUtil.convertStringToCaseType(
                                widget.selectedFilter[FilterType.caseType]),
                            status: TDeviceUtil.convertStringToCaseStatus(
                                widget.selectedFilter[FilterType.status]),
                          );
                          mapProvider.rebuildInitialMarker(
                              controller: widget.controller,
                              caseProvider: provider,
                              markers: widget.markers);
                          mapProvider.updateSelectedToggle(0);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Filter angewendet!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (ex) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Filtern fehlgeschlagen!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Filter anwenden',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dateIsFiltered
            ? Text(
                'Es wird nach dem ${selectedDate.day}.${selectedDate.month}.${selectedDate.year} gefiltert',
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white),
              )
            : const Text(
                'Tatdatum auswählen:',
                style: TextStyle(color: Colors.white),
              ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(TColor.buttonColor),
            ),
            onPressed: () {
              showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
                initialDate: selectedDate,
              ).then(
                (DateTime? pickedDate) {
                  if (pickedDate != null) {
                    setState(
                      () {
                        selectedDate = pickedDate;
                        dateIsFiltered = true;
                      },
                    );
                  } else {
                    setState(
                      () {
                        dateIsFiltered = false;
                      },
                    );
                  }
                },
              );
            },
            child: const Text(
              'Datum auswählen',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInputBox({required String title, required FilterType type}) {
    final provider = Provider.of<CaseProvider>(context);
    final userProvider = Provider.of<UserDetailsProvider>(context);
    return type == FilterType.title || type == FilterType.placeName
        ? TextFormField(
            controller: type == FilterType.title
                ? _titelController
                : _placeNameController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              widget.selectedFilter[type] = value;
            },
            decoration: InputDecoration(
              labelText:
                  type == FilterType.title ? 'Titel filtern' : 'Tatort filtern',
              labelStyle: const TextStyle(color: Colors.white),
            ),
          )
        : Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              switch (type) {
                case FilterType.status:
                  return ["Offen", "Abgeschlossen"].where((status) => status
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));

                case FilterType.createdBy:
                  return userProvider.activeUsersIncludingCurrent
                      .where(
                        (suggestion) =>
                            suggestion.name.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                ) &&
                            suggestion.role != UserRole.crimespotter,
                      )
                      .map(
                        (e) => e.name,
                      )
                      .toSet();

                case FilterType.caseType:
                  return provider.cases
                      .where(
                        (suggestion) => TDeviceUtil.convertCaseTypeToGerman(
                                suggestion.caseType)
                            .toLowerCase()
                            .contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                      )
                      .map(
                        (e) => TDeviceUtil.convertCaseTypeToGerman(e.caseType),
                      )
                      .toSet();

                default:
                  return provider.cases.map((e) => e.title).toSet();
              }
            },
            onSelected: (String selection) {
              setState(
                () {
                  widget.selectedFilter[type] = selection;
                },
              );
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              textEditingController.text = widget.selectedFilter[type] ?? '';
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '$title filtern',
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options) {
              return Material(
                elevation: 4.0,
                child: ListView(
                  children: options
                      .map(
                        (String option) => ListTile(
                          title: Text(
                            option,
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            setState(() {
                              onSelected(option);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
  }
}
