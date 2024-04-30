import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:provider/provider.dart';

class TMapOption extends StatefulWidget {
  final MapController controller;
  const TMapOption({super.key, required this.controller});

  @override
  State<TMapOption> createState() => _TMapOptionState();
}

class _TMapOptionState extends State<TMapOption> {
  final double? spaceBetweenOptions = 8;
  @override
  Widget build(BuildContext context) {
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

  Widget buildMapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inhalt',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Text(
          'Ersteller*in',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Tatzeitpunkt',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        buildTextbox(title: 'Tatort', filterType: FilterTypeTextbox.place),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Fallart',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Status der Ermittlung',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
      ],
    );
  }

  Widget buildTextbox({
    required String title,
    required FilterTypeTextbox filterType,
  }) {
    final provider = Provider.of<CaseProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title),
        // const SizedBox(
        //   height: 5,
        // ),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            //labelText: 'Enter your username',
          ),
          onFieldSubmitted: (value) => {
            switch (filterType) {
              FilterTypeTextbox.creator =>
                provider.filterCreatedBy(filter: value),
              FilterTypeTextbox.summary =>
                provider.filterTitlesAndSummary(filter: value),
              FilterTypeTextbox.status => provider.filterCaseStatus(
                  filter: TDeviceUtil.convertStringToCaseStatus(value)),
              FilterTypeTextbox.caseType => provider.filterCaseType(
                  filter: TDeviceUtil.convertStringtoCaseType(value)),
              FilterTypeTextbox.place =>
                provider.filterPlaceName(filter: value),
            },
          },
        )
      ],
    );
  }

  Widget buildAutoComplete(
      {required String title,
      required List<CaseDetails> cases,
      required String type}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(
          height: 10,
        ),
        Autocomplete<CaseDetails>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            switch (type) {
              case "caseType":
                return cases.where(
                  (suggestion) => suggestion.title.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                );
              default:
                return cases;
            }
          },
          onSelected: (CaseDetails selection) {
            print('You selected: ${selection.title}');
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
              decoration: const InputDecoration(
                labelText: 'Geben Sie Ihren Filter ein:',
                border: OutlineInputBorder(),
              ),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<CaseDetails> onSelected,
              Iterable<CaseDetails> options) {
            return Material(
              elevation: 4.0,
              child: ListView(
                children: options
                    .map((CaseDetails option) => ListTile(
                          title: Text(option.title),
                          onTap: () {
                            onSelected(option);
                          },
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

enum FilterTypeTextbox { summary, creator, place, caseType, status }
