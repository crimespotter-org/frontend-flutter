import 'package:crime_spotter/src/common/datePicker.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

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
  final List<Text> selectedFilters = [];
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaseProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
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
                  buildMapOptions(),

                  // for(var t in selectedFilters){

                  // }

                  ElevatedButton(
                    onPressed: () {
                      try {
                        provider.applyFilter(
                            type: CaseType
                                .murder); // TODO: Richtige Werte filtern
                        mapProvider.rebuildInitialMarker(
                            controller: widget.controller,
                            caseProvider: provider,
                            markers: widget.markers);
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

  final RestorableDateTime _selectedDate =
      RestorableDateTime(DateTime(2021, 7, 25));
  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(
        () {
          _selectedDate.value = newSelectedDate;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
            ),
          );
        },
      );
    }
  }

  Widget buildMapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDivider(text: 'Inhalt filtern'),
        buildAutoComplete(
          title: 'Inhalt',
          type: FilterTypeTextbox.summary,
        ),
        buildDivider(text: 'Autor filtern'),
        buildAutoComplete(
          title: 'Autor',
          type: FilterTypeTextbox.creator,
        ),
        buildDivider(text: 'Tatort filtern'),
        buildAutoComplete(
          title: 'Tatort',
          type: FilterTypeTextbox.place,
        ),
        buildDivider(text: 'Fallart filtern'),
        buildAutoComplete(
          title: 'Fallart',
          type: FilterTypeTextbox.caseType,
        ),
        buildDivider(text: 'Status filtern'),
        buildRadioButtons(),
        buildDivider(text: 'Tatzeitpunkt filtern'),
        DatePicker(
            selectedDate: _selectedDate, selectedDateFunction: _selectDate),
      ],
    );
  }

  Widget buildAutoComplete(
      {required String title, required FilterTypeTextbox type}) {
    final provider = Provider.of<CaseProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            switch (type) {
              case FilterTypeTextbox.summary:
                return provider.filteredCases
                    .where(
                      (suggestion) => suggestion.title.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                    )
                    .map(
                      (e) => e.title,
                    );
              case FilterTypeTextbox.caseType:
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
              case FilterTypeTextbox.creator:
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
              case FilterTypeTextbox.place:
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
              default:
                return provider.filteredCases.map((e) => e.title);
            }
          },
          onSelected: (String selection) {
            selectedFilters.add(
              Text('$title: $selection'),
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
                          onSelected(option);
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

enum FilterTypeTextbox { summary, creator, place, caseType, status }
