import 'dart:io';
import 'dart:typed_data';

import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCase extends StatefulWidget {
  const EditCase({super.key});

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
          bottom: const TabBar(
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
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(ExploreCardData shownCase) {
    if (shownCase == null) {
      return const Center(
        child: Text('No data available'),
      );
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
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
            const SizedBox(height: 20),
            const Text(
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
            child: const Text('Add Link'),
          ),
          const SizedBox(height: 20),
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
          items: ['website', 'podcast', 'newspaper', 'default']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 10),
        // Text field for link URL
        Expanded(
          child: TextFormField(
            initialValue: link.url,
            onChanged: (value) {
              setState(() {
                links[index] = link.copyWith(url: value); // Update the link URL
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter URL',
            ),
          ),
        ),
        // Remove link button
        IconButton(
          icon: const Icon(Icons.remove_circle),
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
          // Add Image button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectAndUploadImage();
              });
            },
            child: const Text('Add Image'),
          ),
          const SizedBox(height: 20),
          // List of images
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  2, // Adjust the number of images per row as needed
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: shownCase.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImageItem(index, shownCase.imageUrls[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(int index, Uint8List imageUrl) {
    return Stack(
      children: [
        // Image
        Image.memory(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        // Remove image button
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              setState(() {
                // Add logic to remove image
              });
            },
          ),
        ),
      ],
    );
  }

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _selectAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload the selected image
      final path = await uploadImageToSupabase(_imageFile!);
      print('Uploaded image to Supabase: $path');
    }
  }

  Future<String> uploadImageToSupabase(File imageFile) async {
    final String fileName = imageFile.path.split('/').last;
    final String path = await SupaBaseConst.supabase.storage
        .from('media')
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return path;
  }
}
