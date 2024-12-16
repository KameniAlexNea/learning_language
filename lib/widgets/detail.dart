import 'package:flutter/material.dart';
import '../db/model.dart';

class DetailPage extends StatelessWidget {
  final DiscussionInteraction interaction;

  const DetailPage({super.key, required this.interaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail View")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Theme: ${interaction.theme}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("User Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(interaction.userAnswer),
            SizedBox(height: 20),
            Text("Feedback:"),
            Divider(),
            SizedBox(height: 10),
            Text(interaction.evaluation),
          ],
        ),
      ),
    );
  }
}
