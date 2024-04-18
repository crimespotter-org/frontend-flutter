import 'package:crime_spotter/src/features/map/4data/fetch_data.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TSearchBar extends StatefulWidget {
  const TSearchBar({super.key});

  @override
  State<TSearchBar> createState() => _TSearchBarState();
}

class _TSearchBarState extends State<TSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FetchData fetchData = FetchData();
  List<LocationData> _fetchedLocations = <LocationData>[];

  void _runFilter(String value) async {
    List<LocationData> result = [];

    if (value.isEmpty) {
      result = [];
    } else {
      result = await fetchData.searchLocation(value);
    }

    setState(
      () {
        _fetchedLocations = result;
        _fetchedLocations = TDeviceUtil.removeDuplicates(_fetchedLocations);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TSize.defaultSpace),
              child: Container(
                width: TDeviceUtil.getScreenWidth(context),
                padding: const EdgeInsets.all(TSize.md),
                decoration: BoxDecoration(
                    color: Colors.white, ///////////////////
                    borderRadius: BorderRadius.circular(15), //////////////
                    border: Border.all(color: Colors.grey)),
                child: TextField(
                  onSubmitted: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                    labelText: 'Suche',
                    suffixIcon: Icon(
                      Iconsax.search_favorite,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _fetchedLocations.length,
                itemBuilder: (context, index) => Card(
                  key: Key(_fetchedLocations[index].addressType),
                  color: Colors.blue,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Text(
                      _fetchedLocations[index].name,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Lat: ${_fetchedLocations[index].lat}, Lon: ${_fetchedLocations[index].lon}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
