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

  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  copy2DList(board, simBoard);
  copyValue(values, simValues);
  copyValue(playerValues, simPlayerValues);
  copyCombination(combinations, simCombinations);
  copyCombination(playerCombinations, simPlayerCombinations);
//if I can win,
  if (canIWin(simBoard, simCombinations, simPlayerCombinations, simValues,
      simPlayerValues, curPlayer, false)) {
    print("I can win!");
    drawBoard(simBoard);
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        //Find the winning move
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        if (values[j][i] > Value(2, 0, 0)) {
          if (!canMyOpponentWin(
              simBoard,
              simCombinations,
              simPlayerCombinations,
              simValues,
              simPlayerValues,
              !curPlayer,
              true)) {
            aiGuessDimensions.x = j;
            aiGuessDimensions.y = i;
            return true;
          }
        }
      }
  }
  print("Couldn't win.");
  copy2DList(board, simBoard);
  copyValue(values, simValues);
  copyValue(playerValues, simPlayerValues);
  copyCombination(combinations, simCombinations);
  copyCombination(playerCombinations, simPlayerCombinations);
  if (canMyOpponentWin(simBoard, simCombinations, simPlayerCombinations,
      simValues, simPlayerValues, !curPlayer, false)) {
    print("My opponent might be able to win");
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (playerValues[j][i] > Value(2, 0, 0) &&
            playerValues[j][i].thirdPriority > -1) {
          copy2DList(board, simBoard);
          copyValue(values, simValues);
          copyValue(playerValues, simPlayerValues);
          copyCombination(combinations, simCombinations);
          copyCombination(playerCombinations, simPlayerCombinations);
          make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
              simPlayerValues, curPlayer, CoordinatePair(j, i));
          print("Sending over this board:");
          drawBoard(simBoard);
          if (!canMyOpponentWin(
              simBoard,
              simCombinations,
              simPlayerCombinations,
              simValues,
              simPlayerValues,
              !curPlayer,
              false)) {
            print("Opponent won on this board:");
            drawBoard(simBoard);
            aiGuessDimensions.x = j;
            aiGuessDimensions.y = i;
            return true;
          }
        }
      }
  }
  print("Couldn't lose.");

  return false;
}

bool canIWin(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = false;

  //win detected
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= n) {
        //print("CanIWin Won and returned true!");
        return true;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= n) {
        //print("CanIWin lost and returned false");
        return false;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= (n - 1) &&
          values[j][i].thirdPriority > -1) {
        // print("CanIWin Won and returned true!");

        return true;
      }
  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  //This has to go here.  Trust me from the future so you stop moving it.
  //If our opponent can win in 1 move
  bool setter = false;
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority == (n - 1) &&
          playerValues[j][i].thirdPriority > -1) {
        setter = true;
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print("CanIWin wants to know if the Opponent can NOT win in 1 move");
        if (!canMyOpponentWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, false)) {
          detector = true;
          i = width;
          j = width;
        }
      }
    }
  if (setter && !detector) {
    //print(
    //    "CanIWin could not find a line where the opponent did not win in 1. return false");
    return false;
  }

  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority == (n - 2) &&
          values[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print("CanIWin wants to know if the Opponent can NOT block 1 move");
        if (!canMyOpponentWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, true)) {
          //print("CanIWin found a win in 1 move! returning true");
          return true;
        }
      }
    }
  detector = false;
  setter = false;
  //If our opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority == (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        setter = true;
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print("CanIWin wants to know if the Opponent can NOT win in 2 move");
        if (!canMyOpponentWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, false)) {
          detector = true;
          i = width;
          j = width;
        }
      }
    }
  if (setter && !detector) {
    //print(
    //    "CanIWin could not find a line where the opponent did not win in 2. returning false");
    return false;
  }
  //if (def)
  //  print("CanIWin fizzled and is returning true");
  //else
  //  print("CanIWin fizzled and is returning false");
  return def;
}

bool canMyOpponentWin(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    bool def) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  bool detector = false;
  //win detected
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].firstPriority >= n) {
        //    print("CanMyOpponentWin won and returned true!");
        return true;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].firstPriority >= n) {
        //  print("CanMyOpponentWin lost and returned false!");
        return false;
      }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority >= (n - 1) &&
          playerValues[j][i].thirdPriority > -1) {
        //print("CanMyOpponentWin won and returned true!");
        return true;
      }
    }

  var simBoard = List.generate(width, (i) => List(width), growable: false);
  var simValues = List.generate(width, (i) => List(width), growable: false);
  var simPlayerValues =
      List.generate(width, (i) => List(width), growable: true);
  List<List<CoordinatePair>> simCombinations = [];
  List<List<CoordinatePair>> simPlayerCombinations = [];
  detector = false;
  bool setter = false;
  //If our opponent can win in one move
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority == (n - 1) &&
          values[j][i].thirdPriority > -1) {
        setter = true;
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print(
        //    "CanMyOpponentWin wants to know if CanIWin can NOT win in 1 move");
        if (!canIWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, false)) {
          detector = true;
          i = width;
          j = width;
        }
      }
    }
  if (setter && !detector) {
    //print(
    //    "CanMyOpponentWin did not find a line where CanIWin didn't win in 1 move, return false");
    return false;
  }

  //If we can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].firstPriority == (n - 2) &&
          playerValues[j][i].thirdPriority > -1) {
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print("CanMyOpponentWin wants to know if CanIWin can block in 2 moves");
        if (!canIWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, true)) {
          //print("CanMyOpponentWin says we can win in 2 moves! return true");
          return true;
        }
      }
    }
  detector = false;
  setter = false;
  //If our opponent can win in two moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].firstPriority == (n - 2) &&
          values[j][i].thirdPriority > -1) {
        setter = true;
        copy2DList(board, simBoard);
        copyValue(values, simValues);
        copyValue(playerValues, simPlayerValues);
        copyCombination(combinations, simCombinations);
        copyCombination(playerCombinations, simPlayerCombinations);
        make_move(simBoard, simCombinations, simPlayerCombinations, simValues,
            simPlayerValues, curPlayer, CoordinatePair(j, i));
        //print(
        //    "CanMyOpponentWin wants to know if CanIwin can NOT win in 2 moves");
        if (!canIWin(simBoard, simCombinations, simPlayerCombinations,
            simValues, simPlayerValues, !curPlayer, false)) {
          detector = true;
          i = width;
          j = width;
        }
      }
    }
  if (setter && !detector) {
    //print(
    //    "CanMyOpponentWin did not find a line where CanIWin didn't win in 2 moves. return false");
    return false;
  }
//  if (def)
//    print("CanMyOpponentWin fizzled and is returning true");
//  else
//    print("CanMyOpponentWin fizzled and is returning false");
  return def;
}
