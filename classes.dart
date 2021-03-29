class CoordinatePair {
  int x;
  int y;
  CoordinatePair(this.x, this.y);

  bool operator ==(other) => (other.x == x && other.y == y);
}

class Value {
  int firstPriority;
  int secondPriority;
  int thirdPriority;

  Value(this.firstPriority, this.secondPriority, this.thirdPriority);

  bool operator ==(other) => (other.firstPriority == firstPriority &&
      other.secondPriority == secondPriority &&
      other.thirdPriority == thirdPriority);
  bool operator >(other) => (firstPriority > other.firstPriority ||
      (other.firstPriority == firstPriority &&
          secondPriority > other.secondPriority) ||
      (other.firstPriority == firstPriority &&
          other.secondPriority == secondPriority &&
          thirdPriority > other.thirdPriority));
}

class Node {
  CoordinatePair coordinates;
  int visited;
  int score;
  double uct;
  Node parent;
  List<Node> children = [];
  Node(this.coordinates, this.visited, this.score, this.uct);
  bool operator ==(other) => (other.coordinates.x == coordinates.x &&
      other.coordinates.y == coordinates.y);
}

class Boolean {
  bool value;
  Boolean(this.value);
}

class SQLNode {
  String sequence;
  int value;
  int depth;
}

void copy2DList(List origin, List copy) {
  for (int i = 0; i < origin.length; i++)
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = origin[i][j];
    }
}

void copyCombination(
    List<List<CoordinatePair>> origin, List<List<CoordinatePair>> copy) {
  copy.clear();
  for (int i = 0; i < origin.length; i++) {
    copy.add(new List(origin[i].length));
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = origin[i][j];
    }
  }
}

void copyValue(List origin, List copy) {
  for (int i = 0; i < origin.length; i++)
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = Value(origin[i][j].firstPriority,
          origin[i][j].secondPriority, origin[i][j].thirdPriority);
    }
}
