import 'dart:io';
import 'dart:typed_data';

import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCase extends StatefulWidget {
  const EditCase({super.key});

  @override
  State<EditCase> createState() => _EditCaseState();
}

class _EditCaseState extends State<EditCase> {
  CaseDetails? shownCase;
  late Future<CaseDetails> _caseFuture;

  Future<CaseDetails> getCase(String id) async {
    if (id == "-1") {
      var newCase = CaseDetails.createNew();
      var userProvider = Provider.of<UserDetailsProvider>(context);
      newCase.createdBy = userProvider.currentUser.id;
      return newCase;
    }
    var provider = Provider.of<CaseProvider>(context);
    try {
      var temp =
          provider.casesDetailed.firstWhere((element) => element.id == id);
      return temp;
    } on Exception catch (_) {
      return CaseService.getCaseDetailedById(id);
    }
  }

  Future<void> loadData() async {
    if (shownCase == null) {
      final caseID = ModalRoute.of(context)?.settings.arguments as String?;
      _caseFuture = getCase(caseID!);
    }
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CaseDetails>(
      future: _caseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while waiting for the data
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Display an error message if something went wrong
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Data has been loaded successfully
          shownCase = snapshot.data!;
          return _buildMainView();
        }
      },
    );
  }

  Widget _buildMainView() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: shownCase!.isNew
              ? const Text("Neuen Fall erstellen")
              : const Text("Fall bearbeiten"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Zusammenfassung'),
              Tab(text: 'Links'),
              Tab(text: 'Bilder'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildSummaryTab(shownCase!),
                _buildLinksTab(shownCase!),
                _buildImagesTab(shownCase!),
              ],
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                heroTag: "saveCase",
                backgroundColor: Colors.greenAccent,
                onPressed: () {
                  _saveCase();
                },
                tooltip: "Speichern",
                child: const Icon(Icons.save),
              ),
            ),
            if (!shownCase!.isNew)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: FloatingActionButton(
                  heroTag: "deleteCase",
                  backgroundColor: Colors.redAccent,
                  onPressed: () async {
                    _showDeleteDialog();
                  },
                  tooltip: "Fall löschen",
                  child: const Icon(Icons.delete),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(CaseDetails shownCase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Titel:',
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
            'Typ:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<CaseType>(
            value: shownCase.caseType,
            onChanged: (value) {
              setState(() {
                shownCase.caseType = value!; // Update the case type
              });
            },
            items: CaseType.values
                .where((element) => element != CaseType.unknown)
                .map<DropdownMenuItem<CaseType>>((CaseType value) {
              return DropdownMenuItem<CaseType>(
                value: value,
                child: Text(TDeviceUtil.convertCaseTypeToGerman(value)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Zusammenfassung:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            initialValue: shownCase!.summary,
            onChanged: (value) {
              shownCase.summary = value;
            },
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksTab(CaseDetails shownCase) {
    links = shownCase!.furtherLinks ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: shownCase!.furtherLinks.length,
            itemBuilder: (context, index) {
              return _buildLinkItem(index, shownCase!.furtherLinks[index]);
            },
          ),

          const SizedBox(height: 5),
          // Add Link button
          IconButton(
            onPressed: () {
              _addLink();
            },
            icon: const Icon(Icons.add_link),
          ),
        ],
      ),
    );
  }

  List<Links> links = [];
  Widget _buildLinkItem(int index, Links link) {
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
          items: ['book', 'podcast', 'newspaper']
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
              hintText: 'URL eingeben',
            ),
          ),
        ),
        // Remove link button
        IconButton(
          icon: const Icon(Icons.link_off),
          onPressed: () {
            _deleteLink(index);
          },
        ),
      ],
    );
  }

  Widget _buildImagesTab(CaseDetails shownCase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add Image button
          Row(
            children: [
              const Text("Bild hinzufügen:"),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _uploadImage(ImageSource.gallery);
                  });
                },
                icon: const Icon(Icons.crop_original),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  setState(() {
                    _uploadImage(ImageSource.camera);
                  });
                },
                icon: const Icon(Icons.photo_camera),
              ),
            ],
          ),

          // List of images
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  2, // Adjust the number of images per row as needed
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: shownCase!.images.length,
            itemBuilder: (context, index) {
              return _buildImageItem(index, shownCase!.images[index].image);
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
                _deleteImage(index);
              });
            },
          ),
        ),
      ],
    );
  }

  final ImagePicker _picker = ImagePicker();
  final List<MediaToAdd> _imagesToAdd = [];
  final List<Media> _imagesTodelete = [];

  Future<void> _uploadImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imagesToAdd.add(
            MediaToAdd(pickedFile.path.split('/').last, File(pickedFile.path)));
      });

      // Read the selected image file as bytes
      List<int> imageBytes = await _imagesToAdd.last.file.readAsBytes();
      String fileName = pickedFile.path.split('/').last;

      // Add the image bytes to your list
      setState(() {
        shownCase!.images
            .add(Media(image: Uint8List.fromList(imageBytes), name: fileName));
      });
    }
  }

  Future<void> _addLink() async {
    setState(() {
      shownCase!.furtherLinks ??= [];
      shownCase!.furtherLinks.add(Links.createNew());
    });
  }

  Future<String> _uploadImageToSupabase(File imageFile) async {
    final String fileName = imageFile.path.split('/').last;
    String storageDir = 'case-${shownCase!.id}';
    final String path = await SupaBaseConst.supabase.storage
        .from('media')
        .upload(
          '$storageDir/$fileName',
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return path;
  }

  Future<void> _deleteImage(int index) async {
    if (_isNotInAddImageList(shownCase!.images[index])) {
      _imagesTodelete.add(shownCase!.images[index]);
    }
    setState(() {
      shownCase!.images.removeAt(index);
    });
  }

  Future<void> _deleteImageFromBucket(Media image) async {
    String storageDir = 'case-${shownCase!.id}';
    final String fileName = image.name;
    final List<FileObject> objects = await SupaBaseConst.supabase.storage
        .from('media')
        .remove(['$storageDir/$fileName']);
  }

  Future<void> _deleteLink(int index) async {
    if (_isNotInAddLinkList(links[index])) {
      links[index].delete = true;
    }
    setState(() {
      links.removeAt(index); // Remove the link from the list
    });
  }

  Future<void> _deleteLinkFromSupabase(Links link) async {
    await SupaBaseConst.supabase
        .from('furtherlinks')
        .delete()
        .match({'id': link.id});
  }

  Future<void> _saveLinkToSupaBase(Links link) async {
    await SupaBaseConst.supabase.from('furtherlinks').insert({
      'case_id': shownCase!.id,
      'url': link.url,
      'link_type': link.type,
    });
  }

  Future<void> _updateLinkInSupabase(Links link) async {
    await SupaBaseConst.supabase.from('furtherlinks').update({
      'url': link.url,
      'type': link.type,
    }).match({'id': link.id});
  }

  bool _isNotInAddLinkList(Links linkToCheck) {
    for (var link in links.where((element) => element.isNew)) {
      if (link.hashCode == linkToCheck.hashCode) {
        return false; // Found a matching link, so it's in the list
      }
    }
    return true; // No matching link found, so it's not in the list
  }

  bool _isNotInAddImageList(Media imageToCheck) {
    for (var image in _imagesToAdd) {
      if (image.hashCode == imageToCheck.hashCode) {
        return false; // Found a matching link, so it's in the list
      }
    }
    return true; // No matching link found, so it's not in the list
  }

  Future<void> _saveCase() async {
    //case
    if (shownCase!.isNew) {
      _saveNewCase();
    } else {
      _updateCase();
    }
  }

  Future<void> _updateCase() async {
    //case
    await SupaBaseConst.supabase.from('cases').update({
      'title': shownCase!.title,
      'summary': shownCase!.summary,
      'case_type': shownCase!.caseType,
    }).match({'id': shownCase!.id});

    //links
    for (var link in links.where((element) => element.isNew)) {
      _saveLinkToSupaBase(link);
    }
    for (var link in links) {
      if (link.updated && _isNotInAddLinkList(link)) {
        await _updateLinkInSupabase(link);
      }
    }
    for (var link in links.where((element) => element.delete)) {
      await _deleteLinkFromSupabase(link);
    }

    //images
    for (var image in _imagesToAdd) {
      final path = await _uploadImageToSupabase(image.file);
      print('Uploaded image to Supabase: $path');
    }
    for (var image in _imagesTodelete) {
      await _deleteImageFromBucket(image);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Speichern erfolgreich!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveNewCase() async {
    //case
    var createdCase =
        await SupaBaseConst.supabase.rpc('create_crime_case_angular', params: {
      'p_title': shownCase!.title,
      'p_summary': shownCase!.summary,
      'p_created_by': shownCase!.createdBy,
      'p_place_name': shownCase!.placeName,
      'p_zip_code': shownCase!.zipCode,
      'p_case_type': TDeviceUtil.convertCaseTypeToString(shownCase!.caseType),
      'p_status': TDeviceUtil.convertCaseStatusToString(shownCase!.status),
      'p_longitude': shownCase!.longitude,
      'p_latitude': shownCase!.latitude,
      'p_crime_date_time': shownCase!.crimeDateTime.toIso8601String(),
      'p_links': null,
    });
    shownCase!.id = createdCase;
    //links
    for (var link in links.where((element) => element.isNew)) {
      _saveLinkToSupaBase(link);
    }

    //images
    for (var image in _imagesToAdd) {
      await _uploadImageToSupabase(image.file);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Speichern erfolgreich!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fall löschen'),
          content: const Text('Wollen sie den Fall wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCase();
              },
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCase() async {
    //links
    for (var link in shownCase!.furtherLinks) {
      _deleteLinkFromSupabase(link);
    }

    //images
    for (var image in shownCase!.images) {
      await _deleteImageFromBucket(image);
    }
    //case
    await SupaBaseConst.supabase
        .from('cases')
        .delete()
        .match({'id': shownCase!.id});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Löschen erfolgreich!'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }
}
