import 'classes.dart';
import 'dart:math';
import 'Functions.dart';
import 'classicGame.dart';
import 'Main.dart';
import 'dart:io';


CoordinatePair MCTS_Move(List buttonList, List combinations, List values,
    List playerCombinations, List playerValues, bool curPlayer) {
  //Define the starting node.  Set it's parent to itself so that we can verify
  //later on whether or not the node we are currently on is the head
  var board = List.generate(19, (i) => List(19), growable: false);
  for (int i = 0; i < 19; i++)
    for (int j = 0; j < 19; j++) board[i][j] = buttonList[i][j].state;
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, !curPlayer);

  Node head = new Node(CoordinatePair(-1, -1), 5, 0, 0);
  head.parent = head;
  Node start;
  //List of variables we will use for the simulation
  var simBoard = List.generate(19, (i) => List(19), growable: false);
  var simValues = List.generate(19, (i) => List(19), growable: false);
  var simPlayerValues = List.generate(19, (i) => List(19), growable: false);
  var simUntaken;
  Boolean simCurPlayer = new Boolean(curPlayer);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];

  //Run simulations according to the number of simulations required
  for (int i = 0; i < 500; i++) {
    //Copy simulated values
    copy2DList(board, simBoard);
    copy2DValue(values, simValues);
    copy2DValue(playerValues, simPlayerValues);
    copyCombination(combinations, simCombinations);
    copyCombination(playerCombinations, simPlayerCombinations);
    simCurPlayer.value = curPlayer;

    simUntaken = getBestMovesInAnArrayFast(simBoard, simValues, simPlayerValues,
        simCombinations, simPlayerCombinations, simCurPlayer.value);
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
  int highest = 0;

  for (int i = 0; i < head.children.length; i++) {
    if (head.children[i].visited > head.children[highest].visited) highest = i;
  }
  return head.children[highest].coordinates;
}

int simulateGame(
    var simBoard,
    List combinations,
    List playerCombinations,
    List values,
    List playerValues,
    CoordinatePair randoMove,
    List simUntaken,
    Boolean curPlayer) {
  //drawPotential(values);
  //drawPotential(playerValues);
  //Remember who was first to move; if it is the Human to move, we want the
  //results to come back with the sign flipped
  int buffer = 1;
  if (curPlayer.value) buffer *= -1;
  //While there is space on the board,
  while (simUntaken.length > 0) {
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
    curPlayer.value = !curPlayer.value;
    if (curPlayer.value)
      simUntaken = getBestMovesInAnArrayFast(simBoard, playerValues, values,
          playerCombinations, combinations, curPlayer.value);
    else
      simUntaken = getBestMovesInAnArrayFast(simBoard, values, playerValues,
          combinations, playerCombinations, curPlayer.value);

    //Get another random untaken space
    if (simUntaken.length > 0)
      randoMove = simUntaken[Random().nextInt(simUntaken.length)];
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
  for (int i = 0; i < nodes.length; i++) {
    if (nodes[i].uct > curUCT) {
      curUCT = nodes[i].uct;
      index = i;
    }
  }
  return nodes[index];
}
