import 'package:flutter/material.dart';
import 'package:radial_button/widget/circle_floating_button.dart';

class RadialButton extends StatefulWidget {
  const RadialButton({super.key});

  @override
  State<RadialButton> createState() => _RadialButtonState();
}

class _RadialButtonState extends State<RadialButton> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

var itemsActionBar = [
  FloatingActionButton(
    heroTag: "firstMenu",
    backgroundColor: Colors.greenAccent,
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
  FloatingActionButton(
    heroTag: "secondMenu",
    backgroundColor: Colors.indigoAccent,
    onPressed: () {},
    child: const Icon(Icons.camera),
  ),
  FloatingActionButton(
    heroTag: "thirdMenu",
    backgroundColor: Colors.orangeAccent,
    onPressed: () {},
    child: const Icon(Icons.card_giftcard),
  ),
];

class _RadialButtonViewState extends State<RadialButton> {
  int _selectedIndex = 0; // Index to keep track of selected view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radial Button View'),
      ),
      body: Stack(
        children: [
          // Views
          _buildView(0, Colors.blue), // View 1
          _buildView(1, Colors.green), // View 2
          _buildView(2, Colors.orange), // View 3

          // Radial Button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleFloatingButton.floatingActionButton(
                items: itemsActionBar,
                color: Colors.redAccent,
                icon: Icons.ac_unit,
                duration: Duration(milliseconds: 1000),
                curveAnim: Curves.ease,
                useOpacity:
                    true, // Add this parameter if required by CircleFloatingButton implementation
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build individual views
  Widget _buildView(int index, Color color) {
    return AnimatedOpacity(
      opacity: _selectedIndex == index ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        color: color,
        child: Center(
          child: Text(
            'View ${index + 1}',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
