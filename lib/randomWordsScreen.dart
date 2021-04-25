import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/myGrabbingWidget.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'main.dart';
import 'userProfileContent.dart';


class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final ScrollController _scrollController = ScrollController();
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _snapSheetcontroller = SnappingSheetController();
  final _snapPositions = [
    SnappingPosition.factor(
        positionFactor: 0,
        grabbingContentOffset: GrabbingContentOffset.top),
    SnappingPosition.factor(
      positionFactor: 0.5,
    )
  ];

  Widget _buildSuggestions(BuildContext context, Set<WordPair> savedStream) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          return _buildRow(context, _suggestions[index], savedStream);
        }
    );
  }

  Widget _buildRow(BuildContext context , WordPair pair, Set<WordPair> savedStream) {
    final alreadySaved = savedStream.contains(pair);
    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite: Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              Provider.of<SavedSet>(context, listen: false).removePair(pair, context);
            } else {
              Provider.of<SavedSet>(context, listen: false).addPair(pair, context);
            }
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Provider.of<SavedSet>(context, listen: false).savedStream,
        builder: (BuildContext cxt, AsyncSnapshot<Set<WordPair>> snap) {
          Set<WordPair> savedSuggestionsStream = snap.data ?? {};
          return Scaffold(
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: [
                IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
                IconButton(icon: Icon(Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated ? Icons.exit_to_app : Icons.login), onPressed: _pushLogin,)
              ],
            ),
            body: Provider.of<AuthRepository>(context, listen: false).isAuthenticated ? SnappingSheet(
              controller: _snapSheetcontroller,
              child: _buildSuggestions(context, savedSuggestionsStream),
              grabbingHeight: 55,
              grabbing: MyGrabbingWidget(
                tap: () {
                  setState(() {
                    _sheetUp();
                  });
                },
                auth: Provider.of<AuthRepository>(context, listen: true).autoRepo,
              ),
              snappingPositions: _snapPositions,
              onSheetMoved: (double _ ) {
                setState(() {
                });
              },
              sheetBelow: SnappingSheetContent (
                sizeBehavior: SheetSizeStatic(height: 150),
                draggable: true,
                child: UserProfileContent(auth: Provider.of<AuthRepository>(context, listen: true).autoRepo)
              ),
            ) : _buildSuggestions(context, savedSuggestionsStream)
          );
    });
  }

  void _sheetUp() {
    _snapSheetcontroller.snapToPosition(_snapPositions[1 - _snapPositions.indexOf(_snapSheetcontroller.currentSnappingPosition)]);
  }
  void _pushSaved() {
    Provider.of<SavedSet>(context, listen: false).update(Provider.of<AuthRepository>(context, listen: false).autoRepo);
    Navigator.pushNamed(context,
        '/saved',
    );
  }

  void _pushLogin() {
    if (Provider.of<AuthRepository>(context, listen: false).status != Status.Authenticated) {
      //not logged in will get you to login
      Provider.of<SavedSet>(context, listen: false).update(Provider.of<AuthRepository>(context, listen: false).autoRepo);
      Navigator.pushNamed(context, '/login');
    }
    else {
      // if logged in - sign out
      Provider.of<SavedSet>(context, listen: false).clearSet();
      Provider.of<AuthRepository>(context, listen: false).signOut();

    }
  }
}