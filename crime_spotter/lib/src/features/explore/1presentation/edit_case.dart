import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:flutter/material.dart';

class EditCase extends StatefulWidget {
  const EditCase({Key? key}) : super(key: key);

  @override
  State<EditCase> createState() => _EditCaseState();
}

class _EditCaseState extends State<EditCase> {
  @override
  Widget build(BuildContext context) {
    final shownCase =
        ModalRoute.of(context)!.settings.arguments as ExploreCardData;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shownCase.title),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Links'),
              Tab(text: 'Images'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildSummaryTab(shownCase),
                _buildLinksTab(shownCase),
                _buildImagesTab(shownCase),
              ],
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: ElevatedButton(
                onPressed: () {
                  //_saveCase();
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(ExploreCardData shownCase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Title:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            initialValue: shownCase.title,
            onChanged: (value) {
              shownCase.title = value;
            },
          ),
          SizedBox(height: 20),
          Text(
            'Summary:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            initialValue: shownCase.summary,
            onChanged: (value) {
              shownCase.summary = value;
            },
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksTab(ExploreCardData shownCase) {
    links = shownCase.buttons!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add Link button
          ElevatedButton(
            onPressed: () {
              setState(() {
                shownCase.buttons == null
                    ? {
                        shownCase.buttons = [],
                        shownCase.buttons!.add(MediaButton('default', ''))
                      }
                    : shownCase.buttons!.add(MediaButton('default', ''));
              });
            },
            child: Text('Add Link'),
          ),
          SizedBox(height: 20),
          // List of links
          ListView.builder(
            shrinkWrap: true,
            itemCount: shownCase.buttons!.length,
            itemBuilder: (context, index) {
              return _buildLinkItem(index, shownCase.buttons![index]);
            },
          ),
        ],
      ),
    );
  }

  List<MediaButton> links = [];
  Widget _buildLinkItem(int index, MediaButton link) {
    return Row(
      children: [
        // Dropdown for link type
        DropdownButton<String>(
          value: link.type,
          onChanged: (value) {
            setState(() {
              links[index] = link.copyWith(type: value); // Update the link type
            });
          },
          items: ['Website', 'Video', 'Document', 'default']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(width: 10),
        // Text field for link URL
        Expanded(
          child: TextFormField(
            initialValue: link.url,
            onChanged: (value) {
              setState(() {
                links[index] = link.copyWith(url: value); // Update the link URL
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter URL',
            ),
          ),
        ),
        // Remove link button
        IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: () {
            setState(() {
              links.removeAt(index); // Remove the link from the list
            });
          },
        ),
      ],
    );
  }

  Widget _buildImagesTab(ExploreCardData shownCase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Implement images tab UI here
        ],
      ),
    );
  }
}
