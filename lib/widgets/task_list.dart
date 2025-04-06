import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/task_service.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final TaskService taskService;
  final Stream<QuerySnapshot> stream;

  const TaskList({
    required this.taskService,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs;

        if (tasks.isEmpty) {
          return Center(child: Text('No tasks yet!'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListItem(
              task: task,
              taskService: taskService,
              onUndoDelete: () => _undoDelete(task),
            );
          },
        );
      },
    );
  }

  void _undoDelete(DocumentSnapshot task) {
    taskService.addTask(
      task['title'],
      isCompleted: task['isCompleted'],
      dueDate: task['dueDate'],
    );
  }
}