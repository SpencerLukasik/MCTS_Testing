import 'classes.dart';
import 'MCTS.dart';
import 'WinningComboCheck.dart';
import 'basicFunctions.dart';
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

void updateValues(List board, List<List<CoordinatePair>> combinations,
    List values, bool curPlayer) {
//Creates the combination values, or the greatest number of positions that have been taken within a valid combination
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      values[i][j].firstPriority = 0;
      values[i][j].secondPriority = 0;
    }

  //Aggressive moves
  //Populate First Priority.  Get the highest value combos and set that entire menomial's first
  //priority value to that high value.
  int temp = 0;
  int highest = 0;
  for (int i = 0; i < combinations.length; i++) {
    for (int j = 0; j < combinations[i].length; j++) {
      //If AI is black
      if (board[combinations[i][j].x][combinations[i][j].y] == 1) {
        temp += 1;
      } else if (board[combinations[i][j].x][combinations[i][j].y] == 2) {
        temp += 1;
      }
    }
    for (int j = 0; j < combinations[i].length; j++) {
      if (values[combinations[i][j].x][combinations[i][j].y].firstPriority <
          temp)
        values[combinations[i][j].x][combinations[i][j].y].firstPriority = temp;
    }
    if (temp > highest) highest = temp;
    temp = 0;
  }

  //Populate Second Priority.  Check if a single combo has a value in it that contains a combination
  //of the highest first priority.  For every node in that combo, increment it's second potential by 1.
  for (int i = 0; i < combinations.length; i++) {
    for (int j = 0; j < combinations[i].length; j++) {
      if (board[combinations[i][j].x][combinations[i][j].y] == 1 &&
          values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
              highest)
        for (int k = 0; k < combinations[i].length; k++)
          values[combinations[i][k].x][combinations[i][k].y].secondPriority +=
              1;
      else if (board[combinations[i][j].x][combinations[i][j].y] == 2 &&
          values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
              highest)
        for (int k = 0; k < combinations[i].length; k++)
          values[combinations[i][k].x][combinations[i][k].y].secondPriority +=
              1;
    }
  }
}

void removePotential(List<List<CoordinatePair>> combinations, List values,
    CoordinatePair newCoordinate) {
  for (int i = 0; i < combinations.length; i++) {
    //Find all combinations that have the coordinate and remove them from the possible winning configurations
    if (combinations[i].contains(newCoordinate)) {
      //Deduct potential points from coordinates connected to the removed coordinate
      for (int j = 0; j < combinations[i].length; j++)
        if (values[combinations[i][j].x][combinations[i][j].y].thirdPriority >
            -1)
          values[combinations[i][j].x][combinations[i][j].y].thirdPriority -= 1;
      combinations.removeAt(i);
      i = i - 1;
    }
  }
}

void populate(List<List<CoordinatePair>> combinations, List potential) {
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) potential[j][i] = new Value(1, 0, 0);

  int curIndex = 0;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      //Check Horizontal wins
      if (j + (n - 1) < width) {
        combinations.add(new List(n));

        for (int k = 0; k < n; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i));
          potential[j + k][i].thirdPriority += 1;
        }

        curIndex += 1;
      }

      //Check Vertical wins
      if (i + (n - 1) < width) {
        combinations.add(new List(n));

        for (int k = 0; k < n; k++) {
          combinations[curIndex][k] = (CoordinatePair(j, i + k));
          potential[j][i + k].thirdPriority += 1;
        }

        curIndex += 1;
      }
      //Check Up-Right wins
      if (j + (n - 1) < width && i - (n - 1) >= 0) {
        combinations.add(new List(n));

        for (int k = 0; k < n; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i - k));
          potential[j + k][i - k].thirdPriority += 1;
        }

        curIndex += 1;
      }
      //Check Down-Right wins
      if (j + (n - 1) < width && i + (n - 1) < width) {
        combinations.add(new List(n));

        for (int k = 0; k < n; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i + k));
          potential[j + k][i + k].thirdPriority += 1;
        }

        curIndex += 1;
      }
    }
  }
}

void drawPotential(List values) {
  String s = "";

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      s += "(";
      s += values[i][j].firstPriority.toString() +
          "," +
          values[i][j].secondPriority.toString() +
          "," +
          values[i][j].thirdPriority.toString();
      s += ") ";
    }
    print(s);
    s = "";
  }
}

void drawCombinations(List<List<CoordinatePair>> combinations) {
  String s = "";
  for (int i = 0; i < combinations.length; i++) {
    s += "[";
    for (int j = 0; j < combinations[i].length; j++) {
      s += "(";
      s += combinations[i][j].x.toString() +
          "," +
          combinations[i][j].y.toString();
      s += ") ";
    }
    print(s + "]");
    s = "";
  }
}
