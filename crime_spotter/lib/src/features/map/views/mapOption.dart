import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

enum FilterType { title, createdBy, placeName, caseType, status, createdAt }

class TMapOption extends StatefulWidget {
  final MapController controller;
  final Map<GeoPoint, List<Placemark>> markers;
  const TMapOption(
      {super.key, required this.controller, required this.markers});

  @override
  State<TMapOption> createState() => _TMapOptionState();
}

class _TMapOptionState extends State<TMapOption> {
  final double? spaceBetweenOptions = 8;
  final Map<FilterType, String> selectedFilter = {};
  DateTime selectedDate = DateTime.now();
  List<bool> _picked = [false, true];
  final List<String> filterName = [
    "Titel",
    'Autor',
    'Tatort',
    'Fallart',
    "Status",
    'Tatdatum',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaseProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    bool filterTime = false;
    return Card(
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
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                  //buildMapOptions(),

                  // for(var t in selectedFilters){

                  // }

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Visibility(
                            visible: FilterType.values[index] ==
                                    FilterType.createdAt &&
                                filterTime,
                            child: Text('${filterName[index]} auswählen:'),
                          ),
                          subtitle:
                              FilterType.values[index] != FilterType.createdAt
                                  ? buildAutoComplete(
                                      title: filterName[index],
                                      type: FilterType.values[index])
                                  : buildDatePicker(),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(); //buildDivider(text: filterName[index]);
                      },
                      itemCount: filterName.length,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      try {
                        provider.applyFilter(
                          createdAt: _selectedDate.value,
                          title: selectedFilter[FilterType.title],
                          createdBy: selectedFilter[FilterType.createdBy],
                          placeName: selectedFilter[FilterType.placeName],
                          type: TDeviceUtil.convertStringtoCaseType(
                              selectedFilter[FilterType.caseType]),
                          status: TDeviceUtil.convertStringToCaseStatus(
                              selectedFilter[FilterType.status]),
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
                    child: const Text('Filter anwenden'),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.clear),
            )
          ],
        ),
      ),
    );
  }

  final RestorableDateTime _selectedDate = RestorableDateTime(
    DateTime(2021, 7, 25),
  );

  Widget buildDatePicker() {
    return ToggleButtons(
      direction: Axis.horizontal,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.red[700],
      selectedColor: Colors.white,
      fillColor: Colors.red[200],
      color: Colors.red[400],
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 80.0,
      ),
      isSelected: _picked,
      onPressed: (int index) {
        if (index == 0) {
          showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2025),
            initialDate: selectedDate,
          );
        }

        setState(
          () {
            _picked = <bool>[index == 0, index == 1];
          },
        );
      },
      children: const [
        Text('Filtern'),
        Text('Nicht filtern'),
      ],
    );
  }

  Widget buildAutoComplete({required String title, required FilterType type}) {
    final provider = Provider.of<CaseProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            switch (type) {
              case FilterType.title:
                return provider.filteredCases
                    .where(
                      (suggestion) => suggestion.title.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                    )
                    .map(
                      (e) => e.title,
                    );
              case FilterType.caseType:
                return provider.filteredCases
                    .where(
                      (suggestion) =>
                          suggestion.caseType ==
                          TDeviceUtil.convertStringtoCaseType(
                              textEditingValue.text.toLowerCase()),
                    )
                    .map(
                      (e) => e.caseType.toString(),
                    );
              case FilterType.createdBy:
                return provider.filteredCases
                    .where(
                      (suggestion) =>
                          suggestion.createdBy.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                    )
                    .map(
                      (e) => e.createdBy,
                    );
              case FilterType.placeName:
                return provider.filteredCases
                    .where(
                      (suggestion) =>
                          suggestion.placeName.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                    )
                    .map(
                      (e) => e.placeName,
                    );
              case FilterType.status:
              // return provider.filteredCases
              //     .where(
              //       (suggestion) =>
              //           suggestion.status.toLowerCase().contains(
              //                 textEditingValue.text.toLowerCase(),
              //               ),
              //     )
              //     .map(
              //       (e) => e.placeName,
              //     );
              default:
                return provider.filteredCases.map((e) => e.title);
            }
          },
          onSelected: (String selection) {
            setState(
              () {
                selectedFilter[type] = selection;
              },
            );
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (String value) {
                onFieldSubmitted();
              },
              decoration: InputDecoration(
                labelText: '$title filtern',
                suffixIcon: const Icon(
                  Icons.abc,
                  color: Colors.grey,
                ),
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
                        title: Text(option),
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
        ),
      ],
    );
  }

  Widget buildRadioButtons() {
    CaseStatus? character = CaseStatus.open;
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Beendete Ermittlungen'),
          leading: Radio<CaseStatus>(
            value: CaseStatus.closed,
            groupValue: character,
            onChanged: (CaseStatus? value) {
              setState(
                () {
                  character = value;
                },
              );
            },
          ),
        ),
        ListTile(
          title: const Text('Laufende Ermittlungen'),
          leading: Radio<CaseStatus>(
            value: CaseStatus.open,
            groupValue: character,
            onChanged: (CaseStatus? value) {
              setState(
                () {
                  character = value;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildDivider({required String text}) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        const SizedBox(
          width: 5,
          height: 50,
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.blue),
        ),
        const SizedBox(
          width: 5,
          height: 50,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// Widget buildTextbox({
//   required String title,
//   required FilterTypeTextbox filterType,
// }) {
//   final provider = Provider.of<CaseProvider>(context);
//   return TextFormField(
//     decoration: InputDecoration(
//       labelText: title,
//       suffixIcon: const Icon(
//         Icons.abc_outlined,
//         color: Colors.grey,
//       ),
//     ),
//     onFieldSubmitted: (value) => {
//       switch (filterType) {
//         FilterTypeTextbox.creator => provider.filterCreatedBy(filter: value),
//         FilterTypeTextbox.summary =>
//           provider.filterTitlesAndSummary(filter: value),
//         FilterTypeTextbox.status => provider.filterCaseStatus(
//             filter: TDeviceUtil.convertStringToCaseStatus(value)),
//         FilterTypeTextbox.caseType => provider.filterCaseType(
//             filter: TDeviceUtil.convertStringtoCaseType(value)),
//         FilterTypeTextbox.place => provider.filterPlaceName(filter: value),
//       },
//     },
//   );
// }
