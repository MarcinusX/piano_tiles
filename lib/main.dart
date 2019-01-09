import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Banner(message: "Flutter rocks!", location: BannerLocation.topEnd,child: MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  List<Note> notes = initNotes();
  Duration noteDuration = Duration(milliseconds: 300);
  AnimationController _animationController;

  int currentNoteIndex = 0;
  AudioCache player = new AudioCache();

  void _onTileTap(Note note) {
    int indexOfNote = notes.indexOf(note);
    bool areAllPreviousTapped =
        notes.sublist(0, indexOfNote).every((n) => n.state == NoteState.tapped);
    if (areAllPreviousTapped && (isPlaying || !hasStarted)) {
      if (!hasStarted) {
        setState(() {
          hasStarted = true;
          _animationController.forward();
        });
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        points++;
      });
    }
  }

  bool isPlaying = true;
  bool hasStarted = false;
  int points = 0;

  _playNote(Note note) {
    switch (note.line) {
      case 0:
        player.play('a.wav');
        return;
      case 1:
        player.play('c.wav');
        return;
      case 2:
        player.play('e.wav');
        return;
      case 3:
        player.play('f.wav');
        return;
    }
  }

  bool get everyClicked => notes
      .sublist(0, currentNoteIndex + 1)
      .every((n) => n.state == NoteState.tapped);

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: noteDuration);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (everyClicked) {
          _animationController.forward(from: 0);
          setState(() {
            if (currentNoteIndex == notes.length - 5) {
              isPlaying = false;
              _showFinishDialog();
            } else {
              currentNoteIndex++;
            }
          });
        } else {
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          _animationController.reverse();
          _showFinishDialog();
        }
      }
    });
  }

  _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = initNotes();
      points = 0;
      currentNoteIndex = 0;
    });
  }

  _showFinishDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Score: $points"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restart();
                  },
                  child: Text("RESTART"),
                )
              ],
            ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Note> get currentNotes =>
      notes.sublist(currentNoteIndex, currentNoteIndex + 5).toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Line(
                      animation: _animationController,
                      lineNumber: 0,
                      height: constraints.maxHeight,
                      currentNotes: currentNotes,
                      onTileTap: _onTileTap,
                    ),
                  ),
                  _divider(),
                  Expanded(
                    child: Line(
                      animation: _animationController,
                      lineNumber: 1,
                      height: constraints.maxHeight,
                      currentNotes: currentNotes,
                      onTileTap: _onTileTap,
                    ),
                  ),
                  _divider(),
                  Expanded(
                    child: Line(
                      animation: _animationController,
                      lineNumber: 2,
                      height: constraints.maxHeight,
                      currentNotes: currentNotes,
                      onTileTap: _onTileTap,
                    ),
                  ),
                  _divider(),
                  Expanded(
                    child: Line(
                      animation: _animationController,
                      lineNumber: 3,
                      height: constraints.maxHeight,
                      currentNotes: currentNotes,
                      onTileTap: _onTileTap,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    "$points",
                    style: TextStyle(color: Colors.red, fontSize: 60),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Container(
        height: double.infinity,
        width: 1,
        color: Colors.white,
      );
}

class Line extends AnimatedWidget {
  final int lineNumber;
  final List<Note> currentNotes;
  final double height;
  final Function(Note) onTileTap;

  const Line(
      {Key key,
      this.height,
      this.currentNotes,
      this.lineNumber,
      this.onTileTap,
      Animation animation})
      : super(key: key, listenable: animation);

  double get tileHeight => height / 4;

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;

    List<Widget> tiles =
        currentNotes.where((note) => note.line == lineNumber).map((note) {
      int index = currentNotes.indexOf(note);
      double baseOffset = (currentNotes.length - index - 2) * tileHeight;
      double offset = baseOffset + animation.value * tileHeight;

      Tile tile = Tile(
        height: tileHeight,
        state: note.state,
        onTap: () => onTileTap(note),
      );
      return Transform.translate(
        offset: Offset(0, offset),
        child: tile,
      );
    }).toList();
    return SizedBox.expand(
      child: Stack(
        children: tiles,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final NoteState state;
  final double height;
  final VoidCallback onTap;

  const Tile({Key key, this.height, this.state, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: color,
        ),
      ),
    );
  }

  Color get color {
    switch (state) {
      case NoteState.ready:
        return Colors.black;
      case NoteState.missed:
        return Colors.red;
      case NoteState.tapped:
        return Colors.transparent;
      default:
        return Colors.black;
    }
  }
}

enum NoteState { ready, tapped, missed }

class Note {
  final int orderNumber;
  final int line;
  NoteState state = NoteState.ready;

  Note(this.orderNumber, this.line);
}

List<Note> initNotes() {
  return [
    Note(0, 0),
    Note(1, 1),
    Note(2, 2),
    Note(3, 1),
    Note(4, 3),
    Note(5, 0),
    Note(6, 1),
    Note(7, 2),
    Note(8, 3),
    Note(9, 2),
    Note(10, 3),
    Note(11, 0),
    Note(11, 1),
    Note(12, 2),
    Note(13, 1),
    Note(14, 3),
    Note(15, 0),
    Note(16, 1),
    Note(17, 2),
    Note(18, 3),
    Note(19, 2),
    Note(20, 3),
    Note(21, 1),
    Note(22, 2),
    Note(23, 1),
    Note(24, 3),
    Note(25, 0),
    Note(26, 1),
    Note(27, 2),
    Note(28, 3),
    Note(29, 2),
    Note(30, 3),
    Note(31, 1),
    Note(32, 2),
    Note(33, 1),
    Note(34, 3),
    Note(35, 0),
    Note(36, 1),
    Note(37, 2),
    Note(38, 3),
    Note(39, 2),
    Note(40, 3),
    Note(41, -1),
    Note(42, -1),
    Note(43, -1),
    Note(44, -1),
  ];
}
