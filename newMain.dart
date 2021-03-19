import 'dart:io';
import 'classes.dart';
import 'currentMaterial.dart';
import 'dart:math';

const int width = 3;
const int n = 3;

void main() {
  const bool learning = true;
  int numberOfSimulations = 1000;
  bool curPlayer = true;
  var board = List.generate(width, (i) => List(width), growable: false);

  CoordinatePair prevCoordinates = new CoordinatePair(-1, -1);
  var values = List.generate(width, (i) => List(width), growable: false);
  var playerValues = List.generate(width, (i) => List(width), growable: false);
  List<List<CoordinatePair>> combinations = [];
  List<List<CoordinatePair>> playerCombinations = [];

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      board[i][j] = 0;
    }

  populate(combinations, values);
  populate(playerCombinations, playerValues);

  if (learning) {
    MCTS_GameLoop(board, values, playerValues, combinations, playerCombinations,
        prevCoordinates, numberOfSimulations, curPlayer);
    //populate_paths(blackPaths);
    //populate_paths(whitePaths);
  } else {
    GameLoop(board, values, playerValues, combinations, playerCombinations,
        prevCoordinates, curPlayer);
  }
}

void MCTS_GameLoop(
    List board,
    List values,
    List playerValues,
    List combinations,
    List playerCombinations,
    CoordinatePair prevCoordinates,
    int numberOfSimulations,
    bool curPlayer) {
  while (true) {
    if (curPlayer) {
      drawBoard(board);
      print("X: ");
      prevCoordinates.y = int.parse(stdin.readLineSync());
      print("Y: ");
      prevCoordinates.x = int.parse(stdin.readLineSync());
      board[prevCoordinates.x][prevCoordinates.y] = 1;
      if (checkWin(board, playerCombinations, curPlayer)) break;
      curPlayer = !curPlayer;
    } else {
      prevCoordinates = MCTS_Move(board, numberOfSimulations, combinations,
          playerCombinations, values, playerValues, curPlayer);
      board[prevCoordinates.x][prevCoordinates.y] = 2;
      if (checkWin(board, combinations, curPlayer)) break;
      curPlayer = !curPlayer;
    }
  }
  drawBoard(board);
  if (curPlayer)
    print("Congratulations to the Human!");
  else
    print("Congratulations to the AI!");
}

CoordinatePair MCTS_Move(List board, int numberOfSimulations, List combinations,
    List playerCombinations, List values, List playerValues, bool curPlayer) {
  //Define the starting node.  Set it's parent to itself so that we can verify
  //later on whether or not the node we are currently on is the head
  //(if node == node.parent) //this is the head
  Node head = new Node(CoordinatePair(-1, -1), 5, 0, 0);
  head.parent = head;
  Node start;
  //List of variables we will use for the simulation
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: false);
  var simUntaken;
  bool simCurPlayer;
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];

  //Create a list of all untaken spaces
  List untaken = new List();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      if (board[i][j] == 0) untaken.add(CoordinatePair(i, j));
    }
  }

  //Run simulations according to the number of simulations required
  for (int i = 1; i < numberOfSimulations + 1; i++) {
    print("Simulation #" + i.toString() + "!");
    //Copy simulated values
    copy2DList(board, simBoard);
    copy2DList(values, simValues);
    copy2DList(playerValues, simPlayerValues);
    copyCombination(combinations, simCombinations);
    copyCombination(playerCombinations, simPlayerCombinations);

    simUntaken = List.from(untaken);
    simCurPlayer = curPlayer;
    //Selection and Expansion of Node Tree
    start = SelectAndExpand(head, simUntaken, simBoard, simValues,
        simPlayerValues, simCombinations, simPlayerCombinations, simCurPlayer);

    //Simulate Game is Simulation
    //downPropegate after calling upPropegate
    upPropegate(
        start,
        simulateGame(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            start.coordinates,
            simUntaken,
            simCurPlayer));
    downPropegate(head);
  }

  //Get the highest scoring node and return it back to main
  Node temp = new Node(CoordinatePair(-1, -1), 0, 0, 0);
  for (int i = 0; i < head.children.length; i++) {
    if (head.children[i].visited > temp.visited) temp = head.children[i];
  }
  for (int i = 0; i < head.children.length; i++) {
    print("Node (" +
        head.children[i].coordinates.y.toString() +
        ", " +
        head.children[i].coordinates.x.toString() +
        "), was visited " +
        head.children[i].visited.toString() +
        " times, had a UCT value of " +
        head.children[i].uct.toString() +
        " and a score of " +
        head.children[i].score.toString());
    print("Children:");
    for (int k = 0; k < head.children[i].children.length; k++)
      print("Node (" +
          head.children[i].children[k].coordinates.y.toString() +
          ", " +
          head.children[i].children[k].coordinates.x.toString() +
          "), was visited " +
          head.children[i].children[k].visited.toString() +
          " times, had a UCT value of " +
          head.children[i].children[k].uct.toString() +
          " and a score of " +
          head.children[i].children[k].score.toString());
    print("");
  }
  return temp.coordinates;
}

int simulateGame(
    var simBoard,
    List combinations,
    List playerCombinations,
    List values,
    List playerValues,
    CoordinatePair randoMove,
    List untaken,
    bool curPlayer) {
  //While there is space on the board,
  while (untaken.length > 0) {
    //If the current player is the human,
    if (curPlayer) {
      //Set the board space to 1
      simBoard[randoMove.x][randoMove.y] = 1;
      //Remove combinations to keep up with the WinCheck
      removePotential(combinations, values, randoMove);
      values[randoMove.x][randoMove.y].thirdPriority = -1;
      playerValues[randoMove.x][randoMove.y].thirdPriority = -1;
      //If there is a win with this player, return -1
      if (checkWin(simBoard, playerCombinations, curPlayer)) {
        return -1;
      }
    } else {
      simBoard[randoMove.x][randoMove.y] = 2;
      //Do the same if it is the AI's turn to move
      removePotential(playerCombinations, playerValues, randoMove);
      values[randoMove.x][randoMove.y].thirdPriority = -1;
      playerValues[randoMove.x][randoMove.y].thirdPriority = -1;
      //Return 1 for a positive outcome
      if (checkWin(simBoard, combinations, curPlayer)) {
        return 1;
      }
    }
    //Remove the untaken space from the list so spaces are not repeated
    //**This could be improved if we make RandoMove an index of untaken rather
    //**than a Coordinate Pair itself, but it does look ugly
    for (int i = 0; i < untaken.length; i++)
      if (untaken[i] == randoMove) {
        untaken.removeAt(i);
        break;
      }
    //Get another random untaken space
    if (untaken.length > 0)
      randoMove = untaken[Random().nextInt(untaken.length)];
    curPlayer = !curPlayer;
  }
  //Return 0 if it's a catgame
  return 0;
}

Node SelectAndExpand(
    Node head,
    List untaken,
    List simBoard,
    List simValues,
    List simPlayerValues,
    List simCombinations,
    List simPlayerCombinations,
    bool simCurPlayer) {
  //If there is a child node that has not yet been visited at all,
  if (head.children.length < untaken.length) {
    //Make the node (a bit hacky to use heads' children length as the index for
    //Untaken, keep sight of this for further issues)
    head.children.add(new Node(untaken[head.children.length], 0, 0, 0));
    //Set the parent of the new node
    head.children[head.children.length - 1].parent = head;
    //Return the newly made node
    return head.children[head.children.length - 1];
  }

  //Otherwise, get the highest UCT node from the list.
  //Return head if there is no option
  if (head.children.length == 0) return head;
  Node temp = getHighestUCT(head.children);
  //Remove the node recieved from the list of untaken nodes
  for (int i = 0; i < untaken.length; i++)
    if (untaken[i] == temp.coordinates) {
      untaken.removeAt(i);
      break;
    }
  //Update board state
  if (simCurPlayer) {
    simBoard[temp.coordinates.x][temp.coordinates.y] = 1;
    //Check if there is already a win on this new board state
    if (checkWin(simBoard, simPlayerCombinations, simCurPlayer)) return temp;
    removePotential(simCombinations, simValues, temp.coordinates);
    simValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
    simPlayerValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
  } else {
    simBoard[temp.coordinates.x][temp.coordinates.y] = 2;
    //Do the same if it is the AI's turn to move
    if (checkWin(simBoard, simCombinations, simCurPlayer)) return temp;
    removePotential(simPlayerCombinations, simPlayerValues, temp.coordinates);
    simValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
    simPlayerValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
  }
  //Recursively call this function with the updated values
  simCurPlayer = !simCurPlayer;
  return SelectAndExpand(temp, untaken, simBoard, simValues, simPlayerValues,
      simCombinations, simPlayerCombinations, simCurPlayer);
}

void upPropegate(Node start, int simResult) {
  start.visited += 1;
  start.score += simResult;

  //Repeat if we are not at the head
  if (start != start.parent) upPropegate(start.parent, simResult);
}

void downPropegate(Node start) {
  start.uct = (start.score / start.visited) +
      (sqrt2 * sqrt(log(start.parent.visited) / start.visited));
  for (int i = 0; i < start.children.length; i++)
    downPropegate(start.children[i]);
}

Node getHighestUCT(List nodes) {
  double curUCT = -double.infinity;
  int index = 0;
  //print("This list has " + nodes.length.toString() + " nodes");
  for (int i = 0; i < nodes.length; i++) {
    //print("Node UCT: " + nodes[i].uct.toString());
    if (nodes[i].uct > curUCT) {
      curUCT = nodes[i].uct;
      index = i;
    }
  }
  return nodes[index];
}

bool checkWin(List board, List combinations, bool curPlayer) {
  bool winDetected;
  for (int i = 0; i < combinations.length; i++) {
    winDetected = true;
    for (int j = 0; j < combinations[i].length; j++) {
      if (curPlayer) {
        if (board[combinations[i][j].x][combinations[i][j].y] != 1) {
          winDetected = false;
          break;
        }
      } else {
        if (board[combinations[i][j].x][combinations[i][j].y] != 2) {
          winDetected = false;
          break;
        }
      }
    }
    if (winDetected) return true;
  }

  return false;
}

void resetGame(List board) {
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      board[i][j] = 0;
    }
}

void drawBoard(List board) {
  stdout.write("   ");
  for (int i = 0; i < width; i++) stdout.write("  " + i.toString() + " ");
  print("");

  stdout.write("   ");
  for (int i = 0; i < width; i++) stdout.write("----");
  print("");

  for (int i = 0; i < width; i++) {
    stdout.write(i.toString() + "  ");
    for (int j = 0; j < width; j++) {
      if (board[i][j] == 1)
        stdout.write("| o ");
      else if (board[i][j] == 2)
        stdout.write("| x ");
      else
        stdout.write("|   ");
    }
    stdout.write("|");
    print("");

    //Bottom of each line
    stdout.write("   ");
    for (int j = 0; j < width; j++) stdout.write("----");
    print("");
  }
}

void populate_paths(File paths) {
  String s = "";
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      s += "0 0 ";
      if (j < 10) s += "0";
      s += j.toString();
      s += "-";
      if (i < 10) s += "0";
      s += i.toString();
      s += '/\n';
      paths.writeAsStringSync(s, mode: FileMode.append);
      s = "";
    }
  }
}
