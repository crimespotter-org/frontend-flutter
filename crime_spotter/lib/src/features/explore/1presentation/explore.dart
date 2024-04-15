import 'dart:math' as math;
import 'dart:ui';

import 'package:crime_spotter/main.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<ExploreCard> cards = [
    ExploreCard(
      imageUrl: 'https://via.placeholder.com/300',
      buttons: ['Button 1', 'Button 2', 'Button 3'],
      text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          'Fusce eu dui non nisi luctus commodo eu ut ipsum. '
          'Nullam ut vestibulum odio. Integer et quam vel turpis molestie elementum.',
    ),
    ExploreCard(
      imageUrl: 'https://via.placeholder.com/300',
      buttons: ['Button 4', 'Button 5', 'Button 6'],
      text: 'Proin eget tortor a libero posuere scelerisque. '
          'Maecenas nec est vitae mauris sodales dictum. '
          'Fusce condimentum magna ut urna facilisis, et consequat ante tempor.',
    ),
    ExploreCard(
      imageUrl: 'https://via.placeholder.com/300',
      buttons: ['Button 9', 'Button 5', 'Button 6'],
      text: 'Proin eget tortor a libero posuere scelerisque. '
          'Maecenas nec est vitae mauris sodales dictum. '
          'Fusce condimentum magna ut urna facilisis, et consequat ante tempor.',
    ),
    ExploreCard(
      imageUrl: 'https://via.placeholder.com/300',
      buttons: ['Button 6', 'Button 5', 'Button 6'],
      text: 'Proin eget tortor a libero posuere scelerisque. '
          'Maecenas nec est vitae mauris sodales dictum. '
          'Fusce condimentum magna ut urna facilisis, et consequat ante tempor.',
    ),
    // Add more cards as needed
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0 && currentIndex > 0) {
            setState(() {
              currentIndex--;
            });
          } else if (details.primaryVelocity! < 0 && currentIndex < cards.length - 1) {
            setState(() {
              currentIndex++;
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: Image.network(cards[currentIndex].imageUrl, fit: BoxFit.cover),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cards[currentIndex].buttons.map((buttonText) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(buttonText),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(cards[currentIndex].text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreCard {
  final String imageUrl;
  final List<String> buttons;
  final String text;

  ExploreCard({required this.imageUrl, required this.buttons, required this.text});
}
