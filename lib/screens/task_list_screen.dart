import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../widgets/task_list.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _auth = AuthService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_auth.isEmailVerified() && _auth.currentUser != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Verify Email'),
            content: Text('A verification link was sent to your email.'),
            actions: [
              TextButton(
                onPressed: () {
                  _auth.sendEmailVerification();
                  Navigator.pop(context);
                },
                child: Text('Resend'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Later'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Tasks"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: TaskList(
        taskService: _taskService,
        stream: _taskService.getTasksStream(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Task description'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(_selectedDate == null
                      ? 'No due date'
                      : 'Due: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _taskService.addTask(
                    _controller.text,
                    dueDate: _selectedDate,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
    _controller.dispose();
  }
}