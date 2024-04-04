import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'src/features/LogIn/presentation/login.dart';
import 'src/shared/4data/const.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crime Spotter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crime Spotter'),
      initialRoute: UIData.logIn,
      routes: <String, WidgetBuilder>{
        UIData.homeRoute: (BuildContext context) =>
            const MyHomePage(title: 'Crime Spotter'),
        UIData.logIn: (BuildContext context) => const LogIn()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          child: ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: Column(
              children: [
                const Text(
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    'Kürzlich hinzugefügte Falle:'),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: CustomGridDelegate(dimension: 240.0),
                    // itemCount: 10, // Pagination??
                    scrollDirection: Axis.horizontal,
                    //reverse: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GridTile(
                        header: GridTileBar(
                          title: Text('$index',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        child: Container(
                            margin: const EdgeInsets.all(12.0),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              gradient: const RadialGradient(
                                colors: <Color>[
                                  Color.fromARGB(1, 21, 209, 242),
                                  Color(0x2F0099BB)
                                ],
                              ),
                            ),
                            child: const Placeholder()),
                      );
                    },
                  ),
                ),
                const Text(
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    'In deiner Nähe:'),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: CustomGridDelegate(dimension: 240.0),
                    itemCount: 20, // Pagination??
                    scrollDirection: Axis.vertical,
                    //reverse: true,
                    itemBuilder: (BuildContext context, int index) {
                      final math.Random random = math.Random(index);
                      return GridTile(
                        header: GridTileBar(
                          title: Text('$index',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(12.0),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            gradient: const RadialGradient(
                              colors: <Color>[
                                Color.fromARGB(1, 21, 209, 242),
                                Color(0x2F0099BB)
                              ],
                            ),
                          ),
                          child: FlutterLogo(
                            style: FlutterLogoStyle.values[
                                random.nextInt(FlutterLogoStyle.values.length)],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Button 1'),
                      onPressed: () {
                        Navigator.pushNamed(context, UIData.logIn);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class CustomGridDelegate extends SliverGridDelegate {
  CustomGridDelegate({required this.dimension});

  final double dimension;

  // The layout is two rows of squares, then one very wide cell, repeat.

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Determine how many squares we can fit per row.
    int count = constraints.crossAxisExtent ~/ dimension;
    if (count < 1) {
      count = 1; // Always fit at least one regardless.
    }
    final double squareDimension = constraints.crossAxisExtent / count;
    return CustomGridLayout(
      crossAxisCount: count,
      fullRowPeriod:
          3, // Number of rows per block (one of which is the full row).
      dimension: squareDimension,
    );
  }

  @override
  bool shouldRelayout(CustomGridDelegate oldDelegate) {
    return dimension != oldDelegate.dimension;
  }
}

class CustomGridLayout extends SliverGridLayout {
  const CustomGridLayout({
    required this.crossAxisCount,
    required this.dimension,
    required this.fullRowPeriod,
  })  : assert(crossAxisCount > 0),
        assert(fullRowPeriod > 1),
        loopLength = crossAxisCount * (fullRowPeriod - 1) + 1,
        loopHeight = fullRowPeriod * dimension;

  final int crossAxisCount;
  final double dimension;
  final int fullRowPeriod;

  // Computed values.
  final int loopLength;
  final double loopHeight;

  @override
  double computeMaxScrollOffset(int childCount) {
    // This returns the scroll offset of the end side of the childCount'th child.
    // In the case of this example, this method is not used, since the grid is
    // infinite. However, if one set an itemCount on the GridView above, this
    // function would be used to determine how far to allow the user to scroll.
    if (childCount == 0 || dimension == 0) {
      return 0;
    }
    return (childCount ~/ loopLength) * loopHeight +
        ((childCount % loopLength) ~/ crossAxisCount) * dimension;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    // This returns the position of the index'th tile.
    //
    // The SliverGridGeometry object returned from this method has four
    // properties. For a grid that scrolls down, as in this example, the four
    // properties are equivalent to x,y,width,height. However, since the
    // GridView is direction agnostic, the names used for SliverGridGeometry are
    // also direction-agnostic.
    //
    // Try changing the scrollDirection and reverse properties on the GridView
    // to see how this algorithm works in any direction (and why, therefore, the
    // names are direction-agnostic).
    final int loop = index ~/ loopLength;
    final int loopIndex = index % loopLength;
    if (loopIndex == loopLength - 1) {
      // Full width case.
      return SliverGridGeometry(
        scrollOffset: (loop + 1) * loopHeight - dimension, // "y"
        crossAxisOffset: 0, // "x"
        mainAxisExtent: dimension, // "height"
        crossAxisExtent: crossAxisCount * dimension, // "width"
      );
    }
    // Square case.
    final int rowIndex = loopIndex ~/ crossAxisCount;
    final int columnIndex = loopIndex % crossAxisCount;
    return SliverGridGeometry(
      scrollOffset: (loop * loopHeight) + (rowIndex * dimension), // "y"
      crossAxisOffset: columnIndex * dimension, // "x"
      mainAxisExtent: dimension, // "height"
      crossAxisExtent: dimension, // "width"
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    return loops * loopLength + extra * crossAxisCount;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // (See commentary above.)
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    final int count = loops * loopLength + extra * crossAxisCount;
    if (extra == fullRowPeriod - 1) {
      return count;
    }
    return count + crossAxisCount - 1;
  }
}
