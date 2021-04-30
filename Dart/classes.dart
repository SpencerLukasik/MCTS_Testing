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
