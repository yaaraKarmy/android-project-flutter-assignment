import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:provider/provider.dart';
import 'randomWordsScreen.dart';
import 'loginScreen.dart';
import 'savedScreen.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class SavedSet with ChangeNotifier {
  Set<WordPair> _saved = <WordPair>{};
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final AuthRepository _authRepo;

  SavedSet(this._authRepo);

  void update(AuthRepository auth) async {
    if(auth.isAuthenticated) {
      DocumentSnapshot snap = await users.doc(auth.user!.uid).get();
      if(snap.exists) {
        Map<String,dynamic>? userDoc = snap.data();
        Set<WordPair> serverSaved = userDoc?['favorites'].map<WordPair>((e) => WordPair(e.split(" ")[0], e.split(" ")[1])).toSet();
        serverSaved.forEach((element) {
          this._saved.add(element);
        });
        notifyListeners();
      }
    }
  }

  Stream<Set<WordPair>> get _savedStream async* {
    yield _saved;
  }

  Stream<Set<WordPair>> get savedStream {
    if (_authRepo.isAuthenticated) {
      return users
          .doc(_authRepo.user?.uid)
          .snapshots()
          .map<Set<WordPair>>((snapshot) {
        Map<String, dynamic>? userDoc = snapshot.data();
        return userDoc?['favorites'].map<WordPair>((e) => WordPair(e.split(" ")[0], e.split(" ")[1])).toSet();
      });
    }
    return _savedStream;
  }

  Set<WordPair> get saved => _saved;
  AuthRepository get authRepo => _authRepo;

  Future<DocumentSnapshot> getUserData(String uid) async {
    return  users
        .doc(uid)
        .get();
  }

  Stream<DocumentSnapshot> getUserDoc(String uid) {
    return  db
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  Future<bool> checkDocExist(String uid) async {
        DocumentSnapshot snap = await db.collection('users').doc(uid).get();
        return snap.exists;
  }

  Future<void> addUserFavorites(String userId, String newFavorites) {
    return db
        .collection('users')
        .doc(userId)
        .update({'favorites': FieldValue.arrayUnion([newFavorites])});
  }

  Future<void> addUserDoc(String userId) async {
    return db
        .collection('users')
        .doc(userId)
        .set({
      'favorites': _saved.map((WordPair pair) => pair.first + " " + pair.second).toList(),
    });
  }

  Future<void> removeUserFavorites(String userId, String newFavorites) {
    return db
        .collection('users')
        .doc(userId)
        .update({'favorites': FieldValue.arrayRemove([newFavorites])});
  }

  void addPair(WordPair newPair, BuildContext context) {
    this._saved.add(newPair);
    if (Provider.of<AuthRepository>(context, listen: false).isAuthenticated &&
        Provider.of<AuthRepository>(context, listen: false).user != null) {
      String newStr = newPair.first + " " + newPair.second;
      addUserFavorites(Provider.of<AuthRepository>(context, listen: false).user!.uid, newStr);
    }
    notifyListeners();
  }
  void removePair(WordPair pair, BuildContext context) {
    this._saved.remove(pair);
    if (Provider.of<AuthRepository>(context, listen: false).isAuthenticated &&
        Provider.of<AuthRepository>(context, listen: false).user != null) {
      String newStr = pair.first + " " + pair.second;
      removeUserFavorites(Provider.of<AuthRepository>(context, listen: false).user!.uid, newStr);
    }
    notifyListeners();
  }

  void clearSet() {
    this._saved.clear();
    notifyListeners();
  }
}

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  AuthRepository get autoRepo => this;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=> AuthRepository.instance()),
          ChangeNotifierProvider(create: (_) => SavedSet(AuthRepository.instance())),
          ChangeNotifierProxyProvider<AuthRepository,SavedSet>(
              create: (_) => SavedSet(AuthRepository.instance()),
              update: (_,auth,saved) {
                saved?.update(auth);
                return saved as SavedSet;
              })
        ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) { return Scaffold(
          body: Center(
              child: Text(snapshot.error.toString(),
                  textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
        },
    ); }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RandomWords(),
        '/login': (context) => SignInScreen(),
        '/saved': (context) => SavedScreen(),
      },
    );
  }
}