import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:flutter/material.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                userProvider.activeUsersIncludingCurrent
                    .firstWhere((element) => element.id == comment.userId)
                    .name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (comment.userId == userProvider.currentUser.id)
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  color: Colors.white,
                  onPressed: deleteComment,
                ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical, //.horizontal
            child: Text(
              comment.text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
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
