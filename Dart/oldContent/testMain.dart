import '../classes.dart';
import '../ClassicGame.dart';
import '../BasicFunctions.dart';
import '../ValueFunctions.dart';
import 'dart:math';

const int width = 5;
const int n = 4;

void main() {
  const bool playAgainstMCTS = true;
  int numberOfSimulations = 2000;
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

  if (playAgainstMCTS) {
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
    bool curPlayer) {}

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
  for (int i = 1; i < numberOfSimulations + 1; i++) {
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

  //Get the highest scoring node and return it back to main
  Node temp = new Node(CoordinatePair(-1, -1), 0, 0, 0);
  for (int i = 0; i < head.children.length; i++) {
    if (head.children[i].visited > temp.visited) temp = head.children[i];
  }
  //for (int i = 0; i < head.children.length; i++) {
  //  print("Node (" +
  //      head.children[i].coordinates.y.toString() +
  //      ", " +
  //      head.children[i].coordinates.x.toString() +
  //     "), was visited " +
  //      head.children[i].visited.toString() +
  //      " times, had a UCT value of " +
  //      head.children[i].uct.toString() +
  //      " and a score of " +
  //      head.children[i].score.toString());
  //}
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

CoordinatePair AI_Move(
    List board,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  CoordinatePair aiGuessDimensions = CoordinatePair(0, 0);

  Value curPotential = new Value(0, 0, 0);
  Value playerCurPotential = new Value(0, 0, 0);

  //if (winExists(board, combinations, playerCombinations, values, playerValues,
  //    curPlayer, aiGuessDimensions)) {
  //  print("Blood in the water!");
  //  return aiGuessDimensions;
  //}

  //updateValues(board, combinations, values, curPlayer);
  //Potential of Aggressive moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      //Check to make sure spot is not taken
      if (values[j][i].thirdPriority > -1 && values[j][i] > curPotential) {
        //If first priority is higher, OR if first priority is the same AND second
        //priority is higher, OR if first AND second priorities are the same but THIRD
        //priority is higher, make this the preferred move
        curPotential = values[j][i];
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  //print("Greatest AI value: " +
  //    curPotential.firstPriority.toString() +
  //    ", " +
  //    curPotential.secondPriority.toString() +
  //    ", " +
  //    curPotential.thirdPriority.toString() +
  //    " at " +
  //    aiGuessDimensions.x.toString() +
  //    ", " +
  //    aiGuessDimensions.y.toString());

  //Defensive moves
  //updateValues(board, playerCombinations, playerValues, curPlayer);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].thirdPriority > -1 &&
          playerValues[j][i] > playerCurPotential) {
        playerCurPotential = playerValues[j][i];
        if (playerCurPotential > curPotential)
          aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  //print("Aggressive:");
  //drawPotential(values);
  //print("Defensive:");
  //drawPotential(playerValues);
  //print("Greatest Player value: " +
  //    playerCurPotential.firstPriority.toString() +
  //    ", " +
  //    playerCurPotential.secondPriority.toString() +
  //    ", " +
  //    playerCurPotential.thirdPriority.toString() +
  //    ", final move:  " +
  //    aiGuessDimensions.y.toString() +
  //    ", " +
  //    aiGuessDimensions.x.toString());
  return aiGuessDimensions;
}

CoordinatePair AI_Move2(
    List board,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  CoordinatePair aiGuessDimensions = CoordinatePair(0, 0);

  Value curPotential = new Value(0, 0, 0);
  Value playerCurPotential = new Value(0, 0, 0);

  //if (winExists(board, combinations, playerCombinations, values, playerValues,
  //    curPlayer, aiGuessDimensions)) {
  //  print("Blood in the water!");
  //  return aiGuessDimensions;
  //}

  //updateValues(board, combinations, values, curPlayer);
  //Potential of Aggressive moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      //Check to make sure spot is not taken
      if (values[j][i].thirdPriority > -1 && values[j][i] > curPotential) {
        //If first priority is higher, OR if first priority is the same AND second
        //priority is higher, OR if first AND second priorities are the same but THIRD
        //priority is higher, make this the preferred move
        curPotential = values[j][i];
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  //print("Greatest AI value: " +
  //    curPotential.firstPriority.toString() +
  //    ", " +
  //    curPotential.secondPriority.toString() +
  //    ", " +
  //    curPotential.thirdPriority.toString() +
  //    " at " +
  //    aiGuessDimensions.x.toString() +
  //    ", " +
  //    aiGuessDimensions.y.toString());

  //Defensive moves
  //updateValues(board, playerCombinations, playerValues, curPlayer);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].thirdPriority > -1 &&
          playerValues[j][i] > playerCurPotential) {
        playerCurPotential = playerValues[j][i];
        if (playerCurPotential > curPotential)
          aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  //print("Aggressive:");
  //drawPotential(values);
  //print("Defensive:");
  //drawPotential(playerValues);
  //print("Greatest Player value: " +
  //    playerCurPotential.firstPriority.toString() +
  //    ", " +
  //    playerCurPotential.secondPriority.toString() +
  //    ", " +
  //    playerCurPotential.thirdPriority.toString() +
  //    ", final move:  " +
  //    aiGuessDimensions.y.toString() +
  //    ", " +
  //    aiGuessDimensions.x.toString());
  return aiGuessDimensions;
}
