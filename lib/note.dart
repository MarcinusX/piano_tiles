class Note {
  final int orderNumber;
  final int line;
  NoteState state = NoteState.ready;

  Note(this.orderNumber, this.line);
}

enum NoteState { ready, tapped, missed }
