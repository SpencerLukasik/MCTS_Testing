import 'dart:html';

import 'ValueFunctions.dart';
import 'classes.dart';
import 'Main.dart';
import 'BITW_Stuff/WinningComboCheck.dart';
import 'BasicFunctions.dart';
import 'dart:io';

void GameLoop(List board, List values, List playerValues, List combinations,
    List playerCombinations, CoordinatePair prevCoordinates, bool curPlayer) {
  while (true) {
    if (curPlayer) {
      drawBoard(board);
      print("X: ");
      prevCoordinates.y = int.parse(stdin.readLineSync());
      print("Y: ");
      prevCoordinates.x = int.parse(stdin.readLineSync());

      make_move(board, combinations, playerCombinations, values, playerValues,
          curPlayer, prevCoordinates);
      if (checkWin(board, playerCombinations, curPlayer)) break;
      curPlayer = !curPlayer;
    } else {
      prevCoordinates = AI_Move(board, combinations, values, playerCombinations,
          playerValues, curPlayer);
      make_move(board, combinations, playerCombinations, values, playerValues,
          curPlayer, prevCoordinates);
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

CoordinatePair AI_Move(
    List board,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  CoordinatePair aiGuessDimensions = CoordinatePair(0, 0);

  Value curPotential = new Value(0, 0, 0);
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);

  //updateValues(board, combinations, values, curPlayer);
  //Potential of Aggressive moves
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      //Check to make sure spot is not taken
      if (values[j][i].thirdPriority > -1 &&
          playerValues[j][i].thirdPriority > -1 &&
          Value(
                  (values[j][i].firstPriority +
                      playerValues[j][i].firstPriority),
                  (values[j][i].secondPriority +
                      playerValues[j][i].secondPriority),
                  (values[j][i].thirdPriority +
                      playerValues[j][i].thirdPriority)) >
              curPotential) {
        curPotential.firstPriority =
            values[j][i].firstPriority + playerValues[j][i].firstPriority;
        curPotential.secondPriority =
            values[j][i].secondPriority + playerValues[j][i].secondPriority;
        curPotential.thirdPriority =
            values[j][i].thirdPriority + playerValues[j][i].thirdPriority;
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }

  return aiGuessDimensions;
}

List<CoordinatePair> AI_Possible_Moves(
    List board,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, curPlayer);
  List<CoordinatePair> possibleMoves = [];

  int highestFirstAggressive = 0;
  int highestSecondAggressive = 0;
  int highestFirstDefensive = 0;
  int highestSecondDefensive = 0;

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      //Make sure the move is not taken
      if (values[j][i].thirdPriority > -1) {
        //Get the highest first and second priority aggressive moves
        if (values[j][i].firstPriority > highestFirstAggressive) {
          highestFirstAggressive = values[j][i].firstPriority;
          if (values[j][i].secondPriority > highestSecondAggressive)
            highestSecondAggressive = values[j][i].secondPriority;
        }
      }
      if (playerValues[j][i].thirdPriority > -1) {
        if (playerValues[j][i].firstPriority > highestFirstDefensive) {
          highestFirstDefensive = playerValues[j][i].firstPriority;
          if (playerValues[j][i].secondPriority > highestSecondDefensive)
            highestSecondDefensive = playerValues[j][i].secondPriority;
        }
      }
    }
  //Compare the highest values calculated
  //If the AI has a greater aggressive potential, make the most aggressive move
  if (highestFirstAggressive == (n - 1))
    addToList(
        possibleMoves, values, highestFirstAggressive, highestSecondAggressive);
  else if (highestFirstDefensive == (n - 1))
    addToList(possibleMoves, playerValues, highestFirstDefensive,
        highestSecondDefensive);
  else if (highestFirstAggressive == (n - 2))
    addToList(
        possibleMoves, values, highestFirstAggressive, highestSecondAggressive);
  else if (highestFirstDefensive == (n - 2))
    addToList(possibleMoves, playerValues, highestFirstDefensive,
        highestSecondDefensive);
  else {
    print("Value move!");
    int highestFirstTotal = 0;
    int highestSecondTotal = 0;
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (values[j][i].thirdPriority > -1) {
          if (values[j][i].firstPriority + playerValues[j][i].firstPriorty >
              highestFirstTotal) {
            highestFirstTotal =
                values[j][i].firstPriority + playerValues[j][i].firstPriority;
            if (values[j][i].secondPriority +
                    playerValues[j][i].secondPriority >
                highestSecondTotal)
              highestSecondTotal = values[j][i].secondPriority +
                  playerValues[j][i].secondPriority;
          }
        }
      }
    for (int i = 0; i < width; i++)
      for (int j = 0; j < width; j++) {
        if (values[j][i].thirdPriorty > -1) {
          if (values[j][i].firstPriority + playerValues[j][i].firstPriority ==
                  highestFirstTotal &&
              values[j][i].secondPriority + playerValues[j][i].secondPriority >=
                  (highestSecondTotal - 2))
            possibleMoves.add(CoordinatePair(j, i));
        }
      }
  }

  return possibleMoves;
}

void addToList(List<CoordinatePair> possibleMoves, List values,
    int highestFirst, int highestSecond) {
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].thirdPriorty > -1) {
        if (values[j][i].firstPriority == highestFirst &&
            values[j][i].secondPriority >= (highestSecond - 2))
          possibleMoves.add(CoordinatePair(j, i));
      }
    }
}
