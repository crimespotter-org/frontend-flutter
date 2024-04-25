import 'dart:math';
import 'dart:typed_data';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TMapSwipeCases extends StatefulWidget {
  final Uint8List image;
  final bool isFront;
  const TMapSwipeCases({super.key, required this.image, required this.isFront});

  @override
  State<TMapSwipeCases> createState() => _TMapSwipeCasesState();
}

class _TMapSwipeCasesState extends State<TMapSwipeCases> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final size = MediaQuery.of(context).size;

        final provider = Provider.of<CaseProvider>(context, listen: false);
        provider.setScreenSize(size);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.image.isEmpty
        ? const Card(
            child: Column(
              children: [
                Text('Keine Fälle gefunden'),
                CircularProgressIndicator()
              ],
            ),
          )
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1],
              ),
            ),
            child: SizedBox.expand(
              child: widget.isFront ? buildFrontCard() : buildCard(),
            ),
          );
  }

  Widget buildFrontCard() => GestureDetector(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = Provider.of<CaseProvider>(context);
            final position = provider.position;
            final milliseconds = provider.isDragging ? 0 : 400;

            final center = constraints.smallest.center(Offset.zero);

            final angle = provider.angle * pi / 180;
            final rotatedMatrix = Matrix4.identity()
              ..translate(center.dx, center.dy)
              ..rotateZ(angle)
              ..translate(-center.dx, -center.dy);

            return AnimatedContainer(
              curve: Curves.easeInOut,
              transform: rotatedMatrix..translate(position.dx, position.dy),
              duration: Duration(milliseconds: milliseconds),
              child: Stack(
                children: [
                  buildCard(),
                  buildStamps(),
                ],
              ),
            );
          },
        ),
        onPanStart: (details) {
          final provider = Provider.of<CaseProvider>(context, listen: false);

          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CaseProvider>(context, listen: false);

          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CaseProvider>(context, listen: false);

          provider.endPosition();
        },
      );

  Widget buildCard() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          widget.image,
          fit: BoxFit.cover,
        ),
      );

  Widget buildStamps() {
    final provider = Provider.of<CaseProvider>(context);
    final status = provider.getStatus();
    final opacity = provider.getStatusOpacity();

    switch (status) {
      case CaseStatus.like:
        final child = buildStamp(
            angle: -0.5, color: Colors.green, text: 'LIKE', opacity: opacity);
        return Positioned(top: 10, left: 10, child: child);

      case CaseStatus.dislike:
        final child = buildStamp(
            angle: 0.5, color: Colors.red, text: 'DISLIKE', opacity: opacity);
        return Positioned(top: 10, left: 10, child: child);
      default:
        return Container();
    }
  }

  Widget buildStamp({
    double angle = 0,
    required Color color,
    required String text,
    required double opacity,
  }) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
