import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/core/ultis/show_notify.dart';
import 'package:speech_to_text_iot_screen/providers/classes_provider.dart';
import 'package:speech_to_text_iot_screen/providers/lectures_provider.dart';

class ClassSelectionScreen extends StatefulWidget {
  final String lectureId;
  final List<String> currentIsPublicTo;
  const ClassSelectionScreen({super.key,required this.lectureId,required this.currentIsPublicTo});

  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
      classesProvider.addStudentsToSelected(widget.currentIsPublicTo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(context,listen: false);
    final classesProvider = Provider.of<ClassesProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a class'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: ()async{
              final success =  await lectureProvider.addStudentToLecture(lectureId: widget.lectureId, studentIds: classesProvider.selectedStudents.toList());
              if(success){
                ShowNotify.showSnackBar(context,"Students added to lecture success");
                Navigator.pop(context);
              }else{
                ShowNotify.showSnackBar(context, "Failed to add students to lecture");
              }
            },
          ),
        ],
      ),
      body:Consumer<ClassesProvider>(
        builder: (context, classesProvider, child) {
          if(classesProvider.classes.isEmpty){
            return const Center(
              child: Text("No classes found"),
            );
          }
            return ListView.builder(
              itemCount: classesProvider.classes.length,
              itemBuilder: (context, index) {
                final currentClass = classesProvider.classes[index];
                return ExpansionTile(
                  title: Row(
                    children: [
                      Checkbox(
                        value: classesProvider.selectedClasses[currentClass.id]??false,
                        onChanged: (value) {
                          classesProvider.toggleClassSelection(currentClass.id);
                        },
                      ),
                      Text(currentClass.id),
                    ],
                  ),
                  children:currentClass.students.map((student) =>
                      Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Row(
                            children: [
                              Checkbox(
                                value: classesProvider.selectedStudents.contains(student),
                                onChanged: (value) {
                                  if(value!){
                                    classesProvider.addStudentToSelected(student);
                                  }else{
                                    classesProvider.removeStudentFromSelected(student);
                                  }
                                },
                              ),
                              Text(student),
                            ],
                          )),
                  ).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

