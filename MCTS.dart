import 'dart:io';
import 'classes.dart';
import 'classicGame.dart';
import 'basicFunctions.dart';
import 'dart:math';

const int width = 9;
const int n = 5;

void main() {
  const bool learning = false;
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
    var blackPaths = File('blackPaths.txt');
    var whitePaths = File('whitePaths.txt');
    MCTS_Move(board, combinations, playerCombinations, values, playerValues,
        curPlayer);
  } else {
    GameLoop(board, values, playerValues, combinations, playerCombinations,
        prevCoordinates, curPlayer);
  }
}

void MCTS_Move(List board, List combinations, List playerCombinations,
    List values, List playerValues, bool curPlayer) {
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
  Boolean simCurPlayer = new Boolean(curPlayer);
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
  while (true) {
    //print("Simulation #" + i.toString() + "!");
    //Copy simulated values
    copy2DList(board, simBoard);
    copy2DList(values, simValues);
    copy2DList(playerValues, simPlayerValues);
    copyCombination(combinations, simCombinations);
    copyCombination(playerCombinations, simPlayerCombinations);

    simUntaken = List.from(untaken);
    simCurPlayer.value = curPlayer;
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
}

int simulateGame(
    var simBoard,
    List combinations,
    List playerCombinations,
    List values,
    List playerValues,
    CoordinatePair randoMove,
    List untaken,
    Boolean curPlayer) {
  //Remember who was first to move; if it is the Human to move, we want the
  //results to come back with the sign flipped
  int buffer = 1;
  if (curPlayer.value) buffer *= -1;
  //While there is space on the board,
  while (untaken.length > 0) {
    //If the current player is the human,
    if (curPlayer.value) {
      //Set the board space to 1
      simBoard[randoMove.x][randoMove.y] = 1;
      //Remove combinations to keep up with the WinCheck
      removePotential(combinations, values, randoMove);
      values[randoMove.x][randoMove.y].thirdPriority = -1;
      playerValues[randoMove.x][randoMove.y].thirdPriority = -1;
      //If there is a win with this player, return -1
      if (checkWin(simBoard, playerCombinations, curPlayer.value)) {
        print("White Victory!");
        return (-1 * buffer);
      }
    } else {
      simBoard[randoMove.x][randoMove.y] = 2;
      //Do the same if it is the AI's turn to move
      removePotential(playerCombinations, playerValues, randoMove);
      values[randoMove.x][randoMove.y].thirdPriority = -1;
      playerValues[randoMove.x][randoMove.y].thirdPriority = -1;
      //Return 1 for a positive outcome
      if (checkWin(simBoard, combinations, curPlayer.value)) {
        print("Black Victory!");
        return (1 * buffer);
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
    curPlayer.value = !curPlayer.value;
  }
  //Return 0 if it's a catgame
  print("It's a tie!");
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
    Boolean simCurPlayer) {
  //If there is a child node that has not yet been visited at all,
  if (head.children.length < untaken.length) {
    //**EXPAND
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
  if (untaken.length == 0) return head;
  Node temp = getHighestUCT(head.children);
  //Remove the node recieved from the list of untaken nodes
  for (int i = 0; i < untaken.length; i++)
    if (untaken[i] == temp.coordinates) {
      untaken.removeAt(i);
      break;
    }
  //Update board state
  if (simCurPlayer.value) {
    simBoard[temp.coordinates.x][temp.coordinates.y] = 1;
    //Check if there is already a win on this new board state
    if (checkWin(simBoard, simPlayerCombinations, simCurPlayer.value))
      return temp;
    removePotential(simCombinations, simValues, temp.coordinates);
    simValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
    simPlayerValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
  } else {
    simBoard[temp.coordinates.x][temp.coordinates.y] = 2;
    //Do the same if it is the AI's turn to move
    if (checkWin(simBoard, simCombinations, simCurPlayer.value)) return temp;
    removePotential(simPlayerCombinations, simPlayerValues, temp.coordinates);
    simValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
    simPlayerValues[temp.coordinates.x][temp.coordinates.y].thirdPriority = -1;
  }
  //Recursively call this function with the updated values
  simCurPlayer.value = !simCurPlayer.value;
  return SelectAndExpand(temp, untaken, simBoard, simValues, simPlayerValues,
      simCombinations, simPlayerCombinations, simCurPlayer);
}

void upPropegate(Node start, int simResult) {
  start.visited += 1;
  start.score += simResult;

  //Repeat if we are not at the head
  if (start != start.parent) upPropegate(start.parent, simResult * -1);
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
