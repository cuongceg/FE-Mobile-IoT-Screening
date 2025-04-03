import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/providers/lectures_provider.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key,required this.lectureId});
  final String lectureId;
  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void dispose() {
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lectureProvider = Provider.of<LectureProvider>(context, listen: false);
      lectureProvider.getLectureById(widget.lectureId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lectureProvider.currentLecture?.title ?? "Lecture"),
        actions: [
          Consumer<LectureProvider>(
            builder: (context,lectureProvider,child){
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  final content = jsonEncode(lectureProvider.controller.document.toDelta().toJson());

                  bool success = await lectureProvider.updateLectureContent(
                    id: widget.lectureId,
                    content: content,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lecture updated successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update lecture')),
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
          child: Consumer<LectureProvider>(
            builder: (context,lectureProvider,child){
              return Column(
                children: [
                  quill.QuillSimpleToolbar(
                      controller: lectureProvider.controller,
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
                        controller: lectureProvider.controller,
                      )
                  )
                ],
              );
            },
          )
      ),
    );
  }
}