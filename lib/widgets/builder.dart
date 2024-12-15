import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String content;
  final Color? backgroundColor;
  final int previewLength;

  const ExpandableCard({
    Key? key,
    required this.title,
    required this.content,
    this.backgroundColor,
    this.previewLength = 200,
  }) : super(key: key);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content copied to clipboard!')),
        );
      },
      child: Card(
        color: widget.backgroundColor ?? Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
Widget buildCard(BuildContext context, String title, String content, {Color? backgroundColor, int previewLength = 200}) {
  return ExpandableCard(
    title: title,
    content: content,
    backgroundColor: backgroundColor,
    previewLength: previewLength,
  );
}