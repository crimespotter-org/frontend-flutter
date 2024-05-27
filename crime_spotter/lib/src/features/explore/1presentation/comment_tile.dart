import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserDetailsProvider>(context);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/LogIn-Card.png"),
          fit: BoxFit.cover,
        ),
        borderRadius:
            BorderRadius.circular(10), // Adjust the border radius as needed
        border: Border.all(
          color: Colors.black, // Set the color of the border
          width: 1, // Set the width of the border
        ),
      ),
      alignment: Alignment.centerLeft,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        horizontalTitleGap: 5,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: userProvider.profilePictures
                  .any((element) => element.userId == comment.userId)
              ? Image.memory(userProvider.profilePictures
                      .where((element) => element.userId == comment.userId)
                      .first
                      .imageInBytes)
                  .image
              : const AssetImage(
                  "assets/placeholder.jpg",
                ),
        ),
        title: Text(
          userProvider.activeUsersIncludingCurrent
              .firstWhere((element) => element.id == comment.userId)
              .name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: SingleChildScrollView(
          scrollDirection: Axis.vertical, //.horizontal
          child: Text(
            comment.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        trailing: comment.userId == userProvider.currentUser.id
            ? IconButton(
                icon: const Icon(Icons.delete),
                iconSize: 20,
                color: Colors.white,
                onPressed: deleteComment,
              )
            : null,
      ),
    );
  }

  Future<void> deleteComment() async {
    await SupaBaseConst.supabase
        .from('comments')
        .delete()
        .match({'id': comment.id});
  }
}
