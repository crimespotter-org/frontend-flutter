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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10), // Adjust the value as needed
        child: Container(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userProvider.activeUsersIncludingCurrent
                        .firstWhere((element) => element.id == comment.user_id)
                        .name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (comment.user_id == userProvider.currentUser.id)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      iconSize: 20,
                      color: Colors.red,
                      onPressed: deleteComment,
                    ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical, //.horizontal
                child: Text(comment.text),
              ),
            ],
          ),
        ),
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
