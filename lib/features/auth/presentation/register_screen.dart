import 'package:flutter/material.dart';
import 'package:job_portal_app/core/utils/validators.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterJobSeekerScreen extends StatefulWidget {
  const RegisterJobSeekerScreen({super.key});

  @override
  State<RegisterJobSeekerScreen> createState() =>
      _RegisterJobSeekerScreenState();
}

class _RegisterJobSeekerScreenState extends State<RegisterJobSeekerScreen> {
  final formKey = GlobalKey<FormState>();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Register Job Seeker')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: fullNameCtrl,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: Validators.required,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validators.password,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          auth.registerJobSeeker(
                            fullNameCtrl.text,
                            emailCtrl.text,
                            passwordCtrl.text,
                          );
                        }
                      },
                child: Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class RegisterEmployerScreen extends StatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  State<RegisterEmployerScreen> createState() =>
      _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends State<RegisterEmployerScreen> {
  final formKey = GlobalKey<FormState>();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final companyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Register Employer')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: fullNameCtrl,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: Validators.required,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validators.password,
              ),
              TextFormField(
                controller: companyCtrl,
                decoration: InputDecoration(labelText: 'Company Name'),
                validator: Validators.required,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          auth.registerEmployer(
                            fullNameCtrl.text,
                            emailCtrl.text,
                            passwordCtrl.text,
                            companyCtrl.text,
                          );
                        }
                      },
                child: Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
