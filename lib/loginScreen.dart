import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordSignUpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool inProgress = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 10.0, left: 16.0, right: 16.0),
              child: Center(
                child: Container(
                    child: Text(
                      'Welcome to Startup Names Generator, please log in below',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    )),
              ),
            ), Padding(
              padding: const EdgeInsets.only(left:16.0,right: 16.0,top:0,bottom: 0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email'),
              ),
            ), Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 15.0, bottom: 20.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password'),
              ),
            ),Container(
              height: 35,
              width: 360,
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(15)),
              child: inProgress ? TextButton(
                onPressed: () async {
                  setState(() {
                    inProgress = false;
                  });
                  var value = await Provider.of<AuthRepository>(context, listen: false).signIn(emailController.text, passwordController.text);
                  setState(() {
                    inProgress = true;
                  });
                  if (value == false) {
                    final snackBar = SnackBar(
                      content: Text('There was an error logging into the app'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    // sign success
                    Set<WordPair> currSaved = Provider.of<SavedSet>(context, listen: false).saved;
                    String uid = Provider.of<AuthRepository>(context, listen: false).user!.uid;
                    bool isExist = await Provider.of<SavedSet>(context, listen: false).checkDocExist(uid);
                    if (!isExist) {
                      await Provider.of<SavedSet>(context, listen: false).addUserDoc(uid);
                    } else {
                      currSaved.forEach((element) {
                        Provider.of<SavedSet>(context, listen: false).addUserFavorites(uid, element.first + " " + element.second);
                      });
                    }

                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Log in',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
                ),
              ) : Center(child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),),
            ), Padding (
                padding: const EdgeInsets.only(left:16.0,right: 16.0,top:8,bottom: 0),
                child: Container(
                height: 35,
                width: 360,
                decoration: BoxDecoration(
                    color: Colors.teal, borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: ()  {
                    showModalBottomSheet(
                      context: context,
                     builder: (context) =>  _showSignUpBottomSheet()
                    );
                  },
                  child: Text(
                    'New user? Click to sign up',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showSignUpBottomSheet() {
    return Container(
      height: 200.0,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
              Center(
                child: Text(
                  'Please confirm your password below:',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                ),
              ),
              Divider(), //borderline after the 1st title
              TextFormField(
                controller: passwordSignUpController,
                obscureText: true,
                validator: (val) {
                  if (val != passwordController.text) {
                    return 'Passwords must match';
                  }
                  else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide:
                      BorderSide(
                        color: Colors.red,
                      )
                    ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ),
              Divider(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.teal,
                      shadowColor: Colors.grey.withAlpha(50),
                      minimumSize: Size(120.0, 35.0),
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      )
                  ),
                  onPressed: () async {
                    if(!_formKey.currentState!.validate()) {
                      return;
                    }
                    if (passwordController.text == passwordSignUpController.text) {
                      await Provider.of<AuthRepository>(context, listen: false).signUp(emailController.text, passwordController.text);
                      Set<WordPair> currSaved = Provider.of<SavedSet>(context, listen: false).saved;
                      String uid = Provider.of<AuthRepository>(context, listen: false).user!.uid;
                      bool isExist = await Provider.of<SavedSet>(context, listen: false).checkDocExist(uid);
                      if (!isExist) {
                        await Provider.of<SavedSet>(context, listen: false).addUserDoc(uid);
                      } else {
                        currSaved.forEach((element) {
                          Provider.of<SavedSet>(context, listen: false).addUserFavorites(uid, element.first + " " + element.second);
                        });
                      }
                      Navigator.pushNamed(context, '/');
                    }
                  },
                  child: Text('Confirm',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),)
              ),
            ],
          ),
      )
    );
  }
}


