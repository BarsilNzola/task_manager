import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  String _error = '';
  
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signInWithEmail(_email, _password);
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
                onChanged: (val) => setState(() => _email = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password too short' : null,
                onChanged: (val) => setState(() => _password = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign In'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text('Create Account'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                child: Text('Forgot Password?'),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Divider(),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _auth.signInWithGoogle();
                  } catch (e) {
                    setState(() => _error = e.toString());
                  }
                },
                icon: Icon(Icons.login),
                label: Text('Sign In with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}