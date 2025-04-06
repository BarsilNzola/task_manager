import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/task_service.dart';

class TaskListItem extends StatelessWidget {
  final DocumentSnapshot task;
  final TaskService taskService;
  final Function()? onUndoDelete;

  const TaskListItem({
    required this.task,
    required this.taskService,
    this.onUndoDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(color: Colors.red),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        final confirmed = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete Task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task deleted'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  if (onUndoDelete != null) onUndoDelete!();
                },
              ),
            ),
          );
        }
        return confirmed;
      },
      onDismissed: (_) => taskService.deleteTask(task.id),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(
            task['title'],
            style: TextStyle(
              decoration: task['isCompleted']
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: task['dueDate'] != null
              ? Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task['dueDate'].toDate())}',
                )
              : null,
          trailing: Checkbox(
            value: task['isCompleted'],
            onChanged: (value) => taskService.toggleTask(task.id, value!),
          ),
        ),
      ),
    );
  }
}