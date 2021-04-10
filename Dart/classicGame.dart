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
  if (amIThreateningOrAmIBeingThreatened(board, combinations,
      playerCombinations, values, playerValues, curPlayer, aiGuessDimensions)) {
    print("Blood in the water!");
    return aiGuessDimensions;
  }

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
