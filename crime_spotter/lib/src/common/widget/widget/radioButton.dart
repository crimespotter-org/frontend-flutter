import 'package:crime_spotter/src/features/map/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:radial_button/widget/circle_floating_button.dart'
    as radial_button;

class TRadioButton extends StatefulWidget {
  const TRadioButton({super.key});

  @override
  State<TRadioButton> createState() => _TRadioButtonState();
}

class _TRadioButtonState extends State<TRadioButton> {
  late List<FloatingActionButton> itemsActionBar;
  @override
  Widget build(BuildContext context) {
    itemsActionBar = ButtonController.itemsActionBar(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: radial_button.CircleFloatingButton.floatingActionButton(
          items: itemsActionBar,
          color: Colors.orangeAccent,
          icon: Icons.no_food,
          duration: const Duration(milliseconds: 400),
          curveAnim: Curves.ease,
          useOpacity: true,
        ),
      ),
    );
  }
}
