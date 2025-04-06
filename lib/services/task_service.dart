// lib/services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user's tasks
  Stream<QuerySnapshot> getTasksStream() {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add a new task
  Future<void> addTask(String title, {bool isCompleted = false, DateTime? dueDate}) async {
    await _firestore.collection('tasks').add({
        'title': title,
        'isCompleted': isCompleted,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': Timestamp.now(),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
    });
   }

  // Toggle task completion
  Future<void> toggleTask(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}