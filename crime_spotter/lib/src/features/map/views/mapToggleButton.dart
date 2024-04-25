import 'package:crime_spotter/src/features/map/views/mapOption.dart';
import 'package:crime_spotter/src/features/map/views/mapSwipeCases.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:provider/provider.dart';

class TMapToggleButton extends StatefulWidget {
  final MapController controller;
  const TMapToggleButton({super.key, required this.controller});

  @override
  State<TMapToggleButton> createState() => _TMapToggleButtonState();
}

enum ToggleButton { map, heatMap, cases, options }

class _TMapToggleButtonState extends State<TMapToggleButton> {
  final List<bool> _selectedToggle = <bool>[true, false, false, false];
  bool _showSwipeableCases = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              direction: Axis.horizontal,
              onPressed: (int index) {
                setState(
                  () {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == index;
                    }
                  },
                );
                if (index == ToggleButton.map.index) {
                  setState(
                    () {
                      _showSwipeableCases = false;
                    },
                  );
                } else if (index == ToggleButton.heatMap.index) {
                  setState(
                    () {
                      _showSwipeableCases = false;
                    },
                  );
                } else if (index == ToggleButton.cases.index) {
                  setState(
                    () {
                      _showSwipeableCases = true;
                    },
                  );
                } else if (index == ToggleButton.options.index) {
                  setState(
                    () {
                      _showSwipeableCases = false;
                    },
                  );
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return TMapOption(controller: widget.controller);
                    },
                  );
                }
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.red[700],
              selectedColor: Colors.white,
              fillColor: Colors.red[200],
              color: Colors.red[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: _selectedToggle,
              children: const [
                Text('Karte'),
                Text('Heatmap'),
                Text('Fallakten'),
                Text('Optionen'),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Visibility(
              visible: _showSwipeableCases,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    buildCases(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: buildButtons(),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildCases() {
    final provider = Provider.of<CaseProvider>(context);
    final urlImages = provider.urlImages;

    return urlImages.isEmpty
        ? Center(
            child: ElevatedButton(
              child: const Text('Neu beginnen'),
              onPressed: () {
                final provider =
                    Provider.of<CaseProvider>(context, listen: false);

                provider.resetCases();
              },
            ),
          )
        : Stack(
            children: urlImages
                .map((urlImage) => TMapSwipeCases(
                      image: urlImage,
                      isFront: urlImages.last == urlImage,
                    ))
                .toList(),
          );
  }

  Widget buildButtons() {
    final provider = Provider.of<CaseProvider>(context);
    final cases = provider.urlImages;

    final status = provider.getStatus();
    final isLike = status == CaseStatus.like;
    final isDislike = status == CaseStatus.dislike;

    return
        // cases.isEmpty
        //     ? ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(16),
        //           ),
        //         ),
        //         child: const Text('Neu beginnen'),
        //         onPressed: () {
        //           final provider =
        //               Provider.of<CaseProvider>(context, listen: false);

        //           provider.resetCases();
        //         },
        //       )
        //     :
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<CaseProvider>(context, listen: false);

            provider.dislike();
          },
          style: ButtonStyle(
            overlayColor: getColor(Colors.white, Colors.red, isDislike),
            foregroundColor: getColor(Colors.white, Colors.red, isDislike),
            backgroundColor: getColor(Colors.white, Colors.red, isDislike),
          ),
          child: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 20,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<CaseProvider>(context, listen: false);
            provider.like();
          },
          style: ButtonStyle(
            overlayColor: getColor(Colors.white, Colors.green, isLike),
            foregroundColor: getColor(Colors.white, Colors.green, isLike),
            backgroundColor: getColor(Colors.white, Colors.green, isLike),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.teal,
            size: 20,
          ),
        ),
      ],
    );
  }

  MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed, bool force) {
    getColor(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }

  MaterialStateProperty<BorderSide> getBorder(
      Color color, Color colorPressed, bool force) {
    getBorder(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return const BorderSide(color: Colors.transparent);
      } else {
        return BorderSide(color: color, width: 3);
      }
    }

    return MaterialStateProperty.resolveWith(getBorder);
  }
}
