import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/core/component/loading_animation.dart';
import 'package:speech_to_text_iot_screen/core/decorations/button_decorations.dart';
import 'package:speech_to_text_iot_screen/core/ultis/show_notify.dart';
import 'package:speech_to_text_iot_screen/ui/home/class_selection_screen.dart';
import 'package:speech_to_text_iot_screen/ui/home/content_screen.dart';
import 'package:speech_to_text_iot_screen/ui/home/record_screen.dart';

import '../../model/lecture.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lectures_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lectures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.pushNamed(context, '/record');
          showCreateLectureDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New Lecture'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await lectureProvider.fetchLectures();
        },
        child: lectureProvider.isLoading
        ?Center(child: LoadingAnimation().circleLoadingAnimation(context),)
        :ListView.builder(
            itemCount: lectureProvider.lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectureProvider.lectures[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Adds a shadow effect
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(
                    lecture.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ContentScreen(lectureId: lecture.id)));
                  },
                  subtitle: Text(lecture.description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'update') {
                        showUpdateDialog(context, lecture);
                      } else if (value == 'delete') {
                        showDeleteConfirmationDialog(context, lecture.id);
                      } else if (value == 'add_student') {
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>
                            ClassSelectionScreen(lectureId: lecture.id, currentIsPublicTo: lecture.isPublicTo)));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'update',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Update'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_student',
                        child: ListTile(
                          leading: Icon(Icons.person_add, color: Colors.green),
                          title: Text('Add Student'),
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert), // Three dots menu
                  ),
                ),
              )
              ;
            }
        ),
      )
    );
  }

  void showUpdateDialog(BuildContext context, Lecture lecture) {
    final TextEditingController titleController = TextEditingController(text: lecture.title);
    final TextEditingController descriptionController = TextEditingController(text: lecture.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Lecture"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "New title",
                    prefixIcon: Icon(Icons.title),
                )),
                TextField(
                  controller: descriptionController,
                  maxLines: null,
                  minLines: 1,
                  decoration: const InputDecoration(
                    labelText: "New description",
                    prefixIcon: Icon(Icons.description),
                  )
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newTitle = titleController.text.trim();
                String newDescription = descriptionController.text.trim();

                if (newTitle.isNotEmpty && newDescription.isNotEmpty) {
                  bool updated = await context.read<LectureProvider>().updateLecture(
                    id:lecture.id,
                    title: newTitle,
                    description: newDescription
                  );

                  if (updated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lecture updated successfully")),
                    );
                    Navigator.pop(context); // Close dialog after updating
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update lecture")),
                    );
                  }
                }
              },
              style: ButtonDecorations.primaryButtonStyle(context: context,borderRadius: 30),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String lectureId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this lecture?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool deleted = await context.read<LectureProvider>().deleteLecture(lectureId);

                if (deleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lecture deleted successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete lecture")),
                  );
                }
                Navigator.pop(context); // Close the dialog
              },
              style: ButtonDecorations.primaryButtonStyle(context: context,borderRadius: 30),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void showCreateLectureDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Lecture"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: (){
                if(titleController.text.isNotEmpty){
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>
                      RecordScreen(title: titleController.text, description: descriptionController.text)
                  ));
                }else{
                  ShowNotify.showSnackBar(context, "Can't create lecture without title");
                }
              },
              style: ButtonDecorations.primaryButtonStyle(context: context,borderRadius: 30),
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }


}
