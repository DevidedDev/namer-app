//import 'dart:ffi';

import 'package:google_fonts/google_fonts.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // var myTest = MyTestClass<String>(myValue: "Hello", input: 3);
  // myTest.write();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: TextTheme(titleMedium: GoogleFonts.anekBangla()),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var counter = 0;

  var favorites = <WordPair>[];
  var favIconState = Icons.favorite_border;

  void getNext() {
    current = WordPair.random();
    favIconState = Icons.favorite_border;

    notifyListeners();
  }

  void changeCounter() {
    counter++;
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
      print("- $current REMOVED");
      favIconState = Icons.favorite_border;
    } else {
      favorites.add(current);
      print("+ $current ADDED");
      favIconState = Icons.favorite;
    }
    print(favorites);
    notifyListeners();
  }

  void removeFavorite(WordPair wordPair) {
    if (favorites.contains(wordPair)) {
      favorites.remove(wordPair);
      notifyListeners();
    }
  }

  /* 
  void buildPopup(FavouriteTile tile) {
    print("long press ${tile.wordPair.asCamelCase}");
    removeFavorite(tile.wordPair);
  }
  */
}

// ...

// Extends means that MyHomePage is a subclass of StatefulWidget
// Like a child that wouldi nherit all the genes from his parents --
// --but then when he grows up, but god is like no, wait, let's switch things up too
// and for a stateful widget it's like, ok you're growin up, you're updating and changing states
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (context, constraints) {
      //Layout builder -  changes layout every time something changes (like screen resize)
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    // makes sure the UI updates
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  //@override - makes sure that the parets class doesn't override the values that we set
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigCard(pair: pair),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(icon),
                    label: Text('Like'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    //var pair = appState.current;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text("You have ${favorites.length} favorites: "),
          SizedBox(
            height: 20,
          ),
          Wrap(
            children: [
              SizedBox(height: 12),
              for (var wordPair in favorites)
                FavouriteTile(
                  wordPair: wordPair,
                  appState: appState,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavouriteTile extends StatelessWidget {
  const FavouriteTile(
      {super.key, required this.wordPair, required this.appState});

  final WordPair wordPair;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    const color = Colors.black;
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => appState.removeFavorite(wordPair),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            child: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            wordPair.asPascalCase,
            style: TextStyle(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class RemoveAlert extends StatelessWidget {
  const RemoveAlert({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var color = Theme.of(context).colorScheme.onBackground;
    return AlertDialog(
        elevation: 12,
        backgroundColor: Theme.of(context).colorScheme.background,
        // icon: Icon(Icons.remove_circle_outline),
        title: Text(
          "Remove element?",
          style: TextStyle(color: color),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            child: Text(
              "Yes",
              style: TextStyle(color: color),
            ),
            onPressed: () {
              Navigator.pop(context);
              appState.removeFavorite(wordPair);
            },
          ),
          TextButton(
            child: Text(
              "No",
              style: TextStyle(color: color),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]);
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //give me a copy of the current style and a add this color on top
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, //gives well fitting clr to theme clr
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 12,
      child: AnimatedSize(
        duration: Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: MergeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  pair.first.toLowerCase(),
                  style: style.copyWith(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
class MyTestClass<MyType> {
  MyType myValue;
  int myInt;

  MyTestClass({required MyType myValue, int input = 0})
      : myValue = myValue,
        myInt = input;

  void write() {
    print(myValue);
  }
}
*/
