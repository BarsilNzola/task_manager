import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _error = '';
  
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signUpWithEmail(_email, _password);
        // Navigate to TaskListScreen after successful signup
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        setState(() => _error = e.toString());
      } finally {
      setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) => 
                    val!.isEmpty ? 'Enter email' : null,
                onChanged: (val) => setState(() => _email = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => 
                    val!.length < 6 ? 'Password must be 6+ chars' : null,
                onChanged: (val) => setState(() => _password = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context), // Back to login
                child: Text('Already have an account? Sign In'),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}