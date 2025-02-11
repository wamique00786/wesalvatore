import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final List<TaskItem> tasks;

  const TaskCard({super.key, required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...tasks.map((task) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(task.title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(task.description),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          child: Text(task.buttonLabel),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskItem {
  final String title;
  final String description;
  final String buttonLabel;

  TaskItem(
      {required this.title,
      required this.description,
      required this.buttonLabel});
}
