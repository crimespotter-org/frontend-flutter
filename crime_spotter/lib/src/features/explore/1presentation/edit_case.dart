import 'dart:io';
import 'dart:typed_data';

import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/case_service.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
      var userProvider =
          Provider.of<UserDetailsProvider>(context, listen: false);
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
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: TColor.backgroundColor,
              surfaceTintColor: TColor.backgroundColor,
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Backgroung.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  backgroundColor: TColor.buttonColor,
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Display an error message if something went wrong
          return Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: TColor.backgroundColor,
              surfaceTintColor: TColor.backgroundColor,
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Backgroung.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        } else {
          // Data has been loaded successfully
          shownCase = snapshot.data!;
          return _buildMainView(context);
        }
      },
    );
  }

  Widget _buildMainView(context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: shownCase!.isNew
              ? const Text("Neuen Fall erstellen")
              : const Text("Fall bearbeiten"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Links'),
              Tab(text: 'Bilder'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
          ),
          foregroundColor: Colors.white,
          backgroundColor: TColor.backgroundColor,
          surfaceTintColor: TColor.backgroundColor,
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
                  _saveCase(context);
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
                    _showDeleteDialog(context);
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Backgroung.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: shownCase.title,
              onChanged: (value) {
                shownCase.title = value;
              },
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                labelText: 'Titel',
                labelStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Typ:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(
                                  color: Colors
                                      .white), // Set border color to white
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CaseType>(
                              value: shownCase.caseType,
                              onChanged: (value) {
                                setState(() {
                                  shownCase.caseType =
                                      value!; // Update the case type
                                });
                              },
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              dropdownColor: TColor.backgroundColor,
                              items: CaseType.values
                                  .map<DropdownMenuItem<CaseType>>(
                                      (CaseType value) {
                                return DropdownMenuItem<CaseType>(
                                  value: value,
                                  child: Text(
                                    TDeviceUtil.convertCaseTypeToGerman(value),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              underline: const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            borderSide: BorderSide(
                                color:
                                    Colors.white), // Set border color to white
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CaseStatus>(
                            value: shownCase.status,
                            onChanged: (value) {
                              setState(() {
                                shownCase.status =
                                    value!; // Update the case type
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            dropdownColor: TColor.backgroundColor,
                            items: CaseStatus.values
                                .map<DropdownMenuItem<CaseStatus>>(
                                    (CaseStatus value) {
                              return DropdownMenuItem<CaseStatus>(
                                value: value,
                                child: Text(
                                  TDeviceUtil.convertCaseStatusToGerman(value),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      initialValue: shownCase.zipCode.toString(),
                      onChanged: (value) {
                        try {
                          shownCase.zipCode = int.parse(value);
                        } catch (e) {
                          // ignore
                        }
                      },
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        labelText: 'Postleitzahl',
                        labelStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: shownCase.placeName,
                    onChanged: (value) {
                      shownCase.placeName = value;
                    },
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      labelText: 'Ortsname',
                      labelStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextFormField(
                      readOnly: true,
                      initialValue: DateFormat('dd.MM.yyyy')
                          .format(shownCase.crimeDateTime),
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        labelText: 'Datum der Tat',
                        labelStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.buttonColor,
                    ),
                    child: const Text(
                      'Datum wählen',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.buttonColor,
              ),
              child: const Text(
                "Ort wählen",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                GeoPoint? result = await showSimplePickerLocation(
                  contentPadding: const EdgeInsets.all(12),
                  radius: 12,
                  context: context,
                  isDismissible: true,
                  title: "Ort wählen",
                  textConfirmPicker: "Ok",
                  textCancelPicker: "Abbrechen",
                  initCurrentUserPosition: const UserTrackingOption(
                    unFollowUser: false,
                    enableTracking: true,
                  ),
                );

                if (result != null) {
                  shownCase.latitude = result.latitude;
                  shownCase.longitude = result.longitude;
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Längengrad:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          shownCase.latitude.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Breitengrad:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        shownCase.longitude.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Zusammenfassung:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextFormField(
              initialValue: shownCase.summary,
              onChanged: (value) {
                shownCase.summary = value;
              },
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          shownCase != null ? shownCase!.crimeDateTime : DateTime.now(),
      firstDate: DateTime(1500),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        shownCase!.crimeDateTime = picked;
      });
    }
  }

  Widget _buildLinksTab(CaseDetails shownCase) {
    links = shownCase.furtherLinks ?? [];
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Backgroung.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: shownCase.furtherLinks.length,
              itemBuilder: (context, index) {
                return _buildLinkItem(index, shownCase.furtherLinks[index]);
              },
            ),

            const SizedBox(height: 5),
            // Add Link button
            IconButton(
              onPressed: () {
                _addLink();
              },
              icon: const Icon(
                Icons.add_link,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  List<Links> links = [];
  Widget _buildLinkItem(int index, Links link) {
    return Row(
      children: [
        // Dropdown for link type
        DropdownButton<String>(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: TColor.backgroundColor,
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
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
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
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'URL eingeben',
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        // Remove link button
        IconButton(
          icon: const Icon(
            Icons.link_off,
            color: Colors.white,
          ),
          onPressed: () {
            _deleteLink(index);
          },
        ),
      ],
    );
  }

  Widget _buildImagesTab(CaseDetails shownCase) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Backgroung.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Image button
            Row(
              children: [
                const Text(
                  "Bild hinzufügen:",
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _uploadImage(
                        ImageSource.gallery,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.crop_original,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _uploadImage(ImageSource.camera);
                    });
                  },
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                  ),
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
              itemCount: shownCase.images.length,
              itemBuilder: (context, index) {
                return _buildImageItem(index, shownCase.images[index].image);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
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
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.remove_circle_outline_outlined,
              color: Colors.redAccent,
            ),
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

  // Future<void> _updateLinkInSupabase(Links link) async {
  //   await SupaBaseConst.supabase.from('furtherlinks').update({
  //     'url': link.url,
  //     'type': link.type,
  //   }).match({'id': link.id});
  // }

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

  Future<void> _saveCase(context) async {
    //case
    if (shownCase!.isNew) {
      _saveNewCase(context);
    } else {
      _updateCase(context);
    }
  }

  Future<void> _updateCase(context) async {
    try {
      //case
      var updatedCase =
          await SupaBaseConst.supabase.rpc('update_case_angular', params: {
        'p_case_id': shownCase!.id,
        'p_title': shownCase!.title,
        'p_summary': shownCase!.summary,
        'p_place_name': shownCase!.placeName,
        'p_zip_code': shownCase!.zipCode,
        'p_case_type': TDeviceUtil.convertCaseTypeToString(shownCase!.caseType),
        'p_status': TDeviceUtil.convertCaseStatusToString(shownCase!.status),
        'p_longitude': shownCase!.longitude,
        'p_latitude': shownCase!.latitude,
        'p_crime_date_time': shownCase!.crimeDateTime.toIso8601String(),
        'p_links': null, //all links get deleted
      });

      //links
      for (var link in links.where((element) => !element.delete)) {
        _saveLinkToSupaBase(link);
      }

      //images
      for (var image in _imagesToAdd) {
        await _uploadImageToSupabase(image.file);
      }
      for (var image in _imagesTodelete) {
        await _deleteImageFromBucket(image);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speichern erfolgreich!'),
            backgroundColor: Colors.greenAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speichern fehlgeschlagen!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _saveNewCase(context) async {
    try {
      //case
      var createdCase = await SupaBaseConst.supabase
          .rpc('create_crime_case_angular', params: {
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
      shownCase!.isNew = false;
      //links
      for (var link in links.where((element) => element.isNew)) {
        _saveLinkToSupaBase(link);
      }

      //images
      for (var image in _imagesToAdd) {
        await _uploadImageToSupabase(image.file);
      }

      if (mounted) {
        var provider = Provider.of<CaseProvider>(context, listen: false);
        provider.resetCases();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speichern erfolgreich!'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speichern fehlgeschlagen!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(parentcontext) {
    showDialog(
      context: parentcontext,
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
                _deleteCase(parentcontext);
              },
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCase(context) async {
    try {
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

      if (mounted) {
        var provider = Provider.of<CaseProvider>(context, listen: false);
        provider.removeCaseFromLists(shownCase!.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Löschen erfolgreich!'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Löschen fehlgeschlagen!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
