import 'classes.dart';
import 'classicGame.dart';
import 'MCTS.dart';
import 'basicFunctions.dart';

bool winExists(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);

  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[i][j] > Value((n - 2), 0, 0) &&
          values[i][j].thirdPriority > -1) {
        //Copy the current values and send them to the win checker
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        if (BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(i, j))) {
          aiGuessDimensions.x = i;
          aiGuessDimensions.y = j;

          return true;
        }
      }
    }

  return false;
}

bool BloodInTheWater(
    List simBoard,
    List<List<CoordinatePair>> simCombinations,
    List simValues,
    List<List<CoordinatePair>> simPlayerCombinations,
    List simPlayerValues,
    bool curPlayer,
    CoordinatePair curMove) {
  //Make the move suggested

  make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
      simPlayerValues, curPlayer, curMove);
  updateValues(simBoard, simCombinations, simValues, curPlayer);
  updateValues(simBoard, simPlayerCombinations, simPlayerValues, curPlayer);
  //Check if either player has won
  //Return true if there was a winning combination
  //Return false if the opponent won this round
  if (curPlayer)
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (simPlayerValues[j][i].firstPriority >= n) return false;
      }
  else {
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (simValues[j][i].firstPriority >= n) return true;
      }
  }
  //Swap players
  curPlayer = !curPlayer;
  if (curPlayer) {
    print("It is currently o's move.");
    drawPotential(simPlayerValues);
  } else {
    print("It is currently x's move");
    drawPotential(simValues);
  }
  drawBoard(simBoard);

  //Now it is our opponent's turn to find a move.
  if (curPlayer) {
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        //If the human can win in one move, make that move
        if (simPlayerValues[j][i].firstPriority == (n - 1))
          return false;
        //If the AI can win in one move, try to block them
        else if (simValues[j][i].firstPriority >= (n - 1) &&
            simValues[j][i].thirdPriority >
                -1) if (BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return true;
        //If the Human can make a pair of n-2, try it
        else if (simPlayerValues[j][i].firstPriority >= (n - 2) &&
            simPlayerValues[j][i].thirdPriority >
                -1) if (!BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return false;
        //If the AI can make a pair of n-2, try to block
        else if (simValues[j][i].firstPriority >= (n - 2) &&
            simValues[j][i].thirdPriority >
                (n - 2)) if (BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i))) return true;
      }
  }

  if (!curPlayer) {
    //See if we have another forcing move
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        //If we are 1 away from winning, return true
        if (simValues[j][i].firstPriority >= (n - 1))
          return true;
        //If our opponent is one away from winning, block them
        else if (simPlayerValues[j][i].firstPriority >=
            (n -
                1)) if (!BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return false;

        //If we are 2 away from winning, attempt to make these moves
        else if (simValues[j][i].firstPriority == (n - 2) &&
            simValues[j][i].thirdPriority >
                -1) if (BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return true;
        else if (simPlayerValues[j][i].firstPriority == (n - 2) &&
            simPlayerValues[j][i].thirdPriority >
                -1) if (!BloodInTheWater(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i))) return false;
      }
  }

  //We haven't won AND the line we took fizzled
  print("Fizzled");
  return false;
}

ool amIThreateningOrAmIBeingThreatened(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions) {
  if (canIWin(board, combinations, playerCombinations, values, playerValues,
      curPlayer, aiGuessDimensions, false)) return true;
    return doINeedToActNow(board, combinations, playerCombinations, values, playerValues,
      curPlayer, aiGuessDimensions);
}

bool canIWin(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;
  //win detected
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= n) return true;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= n) return false;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        return true;
      }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  print("Can our opponent win in one move?");
  //If our opponent can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        if (canMyOpponentWin(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            CoordinatePair(j, i),
            true)) {
          detector = false;
        }
        if (detector) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        } else
          detector = true;
      }
  print("Can we win in two moves?");

  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority >= (n - 2) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        if (!canMyOpponentWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, aiGuessDimensions, true)) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        }
      }
    }
  print("Can our opponent win in two moves?");

  //If our opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        if (canMyOpponentWin(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            CoordinatePair(j, i),
            false)) {
          detector = false;
        }
        if (detector) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        } else
          detector = true;
      }
    }
  return def;
}

bool canMyOpponentWin(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;

  //win detected
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= n) return true;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= n) return false;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) return true;
    }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];

  //If our opponent can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        print("checking if the human can win at ");
        if (canIWin(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, !curPlayer, CoordinatePair(j, i), true)) {
          detector = false;
        }
        if (detector)
          return true;
        else
          detector = true;
      }

  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        if (!canIWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, aiGuessDimensions, true)) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        }
      }
    }
  //If our opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority >= (n - 2) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, !curPlayer, CoordinatePair(j, i));
        if (canIWin(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, !curPlayer, CoordinatePair(j, i), false)) {
          detector = false;
        }
        if (detector) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        } else
          detector = true;
      }
    }
  return def;
}

bool CanWeWinFromThisSpot(
    List simBoard,
    List<List<CoordinatePair>> simCombinations,
    List<List<CoordinatePair>> simPlayerCombinations,
    List simValues,
    List simPlayerValues,
    bool curPlayer,
    CoordinatePair curMove) {
  //Make the move suggested

  make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
      simPlayerValues, curPlayer, curMove);
  updateValues(simBoard, simCombinations, simValues, curPlayer);
  updateValues(simBoard, simPlayerCombinations, simPlayerValues, curPlayer);
  //Check if either player has won
  //Return true if there was a winning combination
  //Return false if the opponent won this round
  if (curPlayer)
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (simPlayerValues[j][i].firstPriority >= n) return false;
      }
  else {
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (simValues[j][i].firstPriority >= n) return true;
      }
  }
  //Swap players
  curPlayer = !curPlayer;
  if (curPlayer) {
    print("It is currently o's move.");
    drawPotential(simPlayerValues);
  } else {
    print("It is currently x's move");
    drawPotential(simValues);
  }
  drawBoard(simBoard);

  //Now it is our opponent's turn to find a move.
  if (curPlayer) {
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        //If the human can win in one move, make that move
        if (simPlayerValues[j][i].firstPriority == (n - 1))
          return false;
        //If the AI can win in one move, try to block them
        else if (simValues[j][i].firstPriority >= (n - 1) &&
            simValues[j][i].thirdPriority >
                -1) if (CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return true;
        //If the Human can make a pair of n-2, try it
        else if (simPlayerValues[j][i].firstPriority >= (n - 2) &&
            simPlayerValues[j][i].thirdPriority >
                -1) if (!CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return false;
        //If the AI can make a pair of n-2, try to block
        else if (simValues[j][i].firstPriority >= (n - 2) &&
            simValues[j][i].thirdPriority >
                (n - 2)) if (CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i))) return true;
      }
  }

  if (!curPlayer) {
    //See if we have another forcing move
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        //If we are 1 away from winning, return true
        if (simValues[j][i].firstPriority >= (n - 1))
          return true;
        //If our opponent is one away from winning, block them
        else if (simPlayerValues[j][i].firstPriority >=
            (n -
                1)) if (!CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return false;

        //If we are 2 away from winning, attempt to make these moves
        else if (simValues[j][i].firstPriority == (n - 2) &&
            simValues[j][i].thirdPriority >
                -1) if (CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i)))
          return true;
        else if (simPlayerValues[j][i].firstPriority == (n - 2) &&
            simPlayerValues[j][i].thirdPriority >
                -1) if (!CanWeWinFromThisSpot(
            simBoard,
            simCombinations,
            simValues,
            simPlayerCombinations,
            simPlayerValues,
            curPlayer,
            CoordinatePair(j, i))) return false;
      }
  }

  //We haven't won AND the line we took fizzled
  print("Fizzled");
  return false;
}

bool CanOurOpponentsWin(
    List simBoard,
    List<List<CoordinatePair>> simCombinations,
    List simValues,
    List<List<CoordinatePair>> simPlayerCombinations,
    List simPlayerValues,
    bool curPlayer,
    CoordinatePair curMove) {
  //Fizzled
  print("Opponents Fizzled");
  return false;
}


import 'classes.dart';
import 'classicGame.dart';
import 'MCTS.dart';
import 'basicFunctions.dart';

bool amIThreateningOrAmIBeingThreatened(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i] > Value(2, 0, 0)) {
        if (amIThreatening(board, combinations, playerCombinations, values,
            playerValues, curPlayer, CoordinatePair(j, i), false)) {
          aiGuessDimensions.x = j;
          aiGuessDimensions.y = i;
          return true;
        }
      }
    }
  return false;
}

bool amIThreatening(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        drawBoard(board);
        print("I am threatening!");
        return true;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) {
        drawBoard(board);
        print("I am BEING threatening!");
        return true;
      }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];

  print("Can we win in two moves?");
  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority >= (n - 2) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        if (!opponentBestMove(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            CoordinatePair(j, i),
            true)) {
          return true;
        }
      }
    }
  return def;
}

bool opponentBestMove(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) return false;
    }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  //If our opponent can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        if (amIThreatening(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            CoordinatePair(j, i),
            false)) return false;
      }

  return def;
}

bool amIThreatening(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        drawBoard(board);
        print("I am threatening! Setting to " +
            i.toString() +
            ", " +
            j.toString());
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        return true;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) {
        drawBoard(board);
        print("I am BEING threatening! Setting to " +
            i.toString() +
            ", " +
            j.toString());
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        return false;
      }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  bool setter = false;
  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority >= (n - 2) &&
          values[j][i].thirdPriority > -1) {
        setter = true;
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        print("Drawing from Can we Win in 2?");
        drawBoard(board);
        if (opponentBestMove(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, aiGuessDimensions, true)) {
          print("Opponent could block a win in 2 moves");
          detector = false;
        }
      }
    }
  if (detector && setter) return true;
  detector = true;
  setter = false;
  //If our opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        if (opponentBestMove(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, aiGuessDimensions, false)) {
          print("Opponent had a line that led to them winning in 2 moves");
          return true;
        }
      }
    }
  return def;
}

bool opponentBestMove(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair aiGuessDimensions,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = true;
  //If the opponent can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) return true;
    }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  //If we can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        print("Drawing from Can we Win in 1?  Opponent");
        drawBoard(board);
        if (!amIThreatening(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            aiGuessDimensions,
            true)) return false;
      }
  //If the opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        aiGuessDimensions.x = j;
        aiGuessDimensions.y = i;
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, aiGuessDimensions);
        if (amIThreatening(
            simBoard,
            simCombinations,
            simPlayerCombinations,
            simValues,
            simPlayerValues,
            !curPlayer,
            aiGuessDimensions,
            false)) return false;
      }

  return def;
}