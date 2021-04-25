import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _biggerFont = const TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Provider.of<SavedSet>(context, listen: false).savedStream,
        builder: (BuildContext cxt, AsyncSnapshot<Set<WordPair>> snap) {
          Set<WordPair> streamData = snap.data ?? {};
          if (snap.hasError) {
            return Text("Error");
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          final tiles = streamData.map(
                (WordPair pair) {
              return ListTile(
                trailing: IconButton(icon: Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      Provider.of<SavedSet>(context, listen: false).removePair(
                          pair, context);
                    });
                  },),
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isEmpty ? <Widget>[] : ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text("Saved Suggestions"),
            ),
            body: ListView(children: divided),
          );
        });
    }
}
