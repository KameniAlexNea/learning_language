import 'package:discursia/utilities/topic_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String content;
  final Color? backgroundColor;
  final int previewLength;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.previewLength = 200,
  });

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.content));
        showSuccess(context, 'Content copied to clipboard!');
      },
      child: Card(
        color: widget.backgroundColor ?? Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: _isExpanded
                  ? widget.content
                  : widget.content.length > widget.previewLength
                      ? '${widget.content.substring(0, widget.previewLength)}...'
                      : widget.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14),
                ),
              ),
              if (widget.content.length > widget.previewLength)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// If you still want a build function, you can create a helper function
Widget buildCard(BuildContext context, String title, String content, {Color? backgroundColor, double elevation = 1.0, int previewLength = 200}) {
  return Card(
    elevation: elevation,
    color: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpandableCard(
      title: title,
      content: content,
      // titleStyle: Theme.of(context).textTheme.titleLarge,
      previewLength: previewLength,
      // padding: const EdgeInsets.all(16),
    ),
  );
}