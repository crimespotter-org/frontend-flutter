import 'package:crime_spotter/src/features/explore/1presentation/comment_tile.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentSection extends StatefulWidget {
  final CaseDetails shownCase;
  const CommentSection({
    super.key,
    required this.shownCase,
  });
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late CaseDetails shownCase;
  late TextEditingController commentText;
  late UserDetailsProvider userProvider;

  @override
  void initState() {
    shownCase = widget.shownCase;
    SupaBaseConst.supabase
        .channel('comments')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'comments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'case_id',
              value: shownCase.id,
            ),
            callback: (payload) {
              updateCommentList(payload);
            })
        .subscribe();
    commentText = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    commentText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserDetailsProvider>(context);
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10), // Adjust the value as needed
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Text(shownCase.comments.length.toString()),
                const SizedBox(width: 5),
                const Text('Kommentare'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined),
                  color: Colors.black,
                  onPressed: () {
                    addComment();
                  },
                ),
                const SizedBox(width: 15),
              ],
            ),
            if (shownCase.comments.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: shownCase.comments.length,
                  itemBuilder: (context, index) {
                    return CommentTile(
                      comment: shownCase.comments[index],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateCommentList(PostgresChangePayload payload) async {
    if (payload.newRecord.isNotEmpty) {
      shownCase.comments.add(Comment.fromJson(payload.newRecord));
      shownCase.comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    if (payload.oldRecord.isNotEmpty) {
      shownCase.comments
          .removeWhere((element) => element.id == payload.oldRecord['id']);
    }
    setState(() {});
  }

  Future<void> addComment() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kommentar:'),
        content: TextField(
          autofocus: true,
          controller: commentText,
          maxLines: null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.black,
            onPressed: submit,
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    Navigator.of(context).pop();
    var input = commentText.text;
    if (input.isNotEmpty) {
      await SupaBaseConst.supabase.from('comments').insert({
        'case_id': shownCase.id,
        'user_id': userProvider.currentUser.id,
        'text': input,
      });
    }
    commentText.text = '';
  }
}
