import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/providers/lectures_provider.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key,required this.lectureTitle,required this.lectureDescription});
  final String lectureTitle;
  final String lectureDescription;
  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lectureTitle),
        actions: [
          Consumer<LectureProvider>(
            builder: (context,lectureProvider,child){
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  final content = jsonEncode(_controller.document.toDelta().toJson());
                  final title = widget.lectureTitle;
                  final description = widget.lectureDescription;

                  bool success = await lectureProvider.createLecture(
                    title: title,
                    content: content,
                    description: description,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lecture created successfully')),
                    );
                    Navigator.pop(context); // Navigate back to the previous screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create lecture')),
                    );
                  }
                },
              );
            },
          )
        ],
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
            children: [
              quill.QuillSimpleToolbar(
                  controller: _controller,
                  config: const quill.QuillSimpleToolbarConfig()
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
              Expanded(
                  child: quill.QuillEditor(
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      controller: _controller,
                  )
              )
            ],
          )
      ),
    );
  }
}
