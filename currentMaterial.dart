import 'classes.dart';
import 'newMain.dart';
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
      board[prevCoordinates.x][prevCoordinates.y] = 1;
      values[prevCoordinates.x][prevCoordinates.y].thirdPriority = -1;
      playerValues[prevCoordinates.x][prevCoordinates.y].thirdPriority = -1;
      removePotential(combinations, values, prevCoordinates);
      if (checkWin(board, playerCombinations, curPlayer)) break;
      curPlayer = !curPlayer;
    } else {
      prevCoordinates = AI_Move(board, combinations, values, playerCombinations,
          playerValues, curPlayer);
      board[prevCoordinates.x][prevCoordinates.y] = 2;
      values[prevCoordinates.x][prevCoordinates.y].thirdPriority = -1;
      playerValues[prevCoordinates.x][prevCoordinates.y].thirdPriority = -1;

      removePotential(playerCombinations, playerValues, prevCoordinates);
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
      if (board[combinations[i][j].x][combinations[i][j].y] == 2) {
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
      if (curPlayer) {
        if (board[combinations[i][j].x][combinations[i][j].y] == 1 &&
            values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
                highest)
          for (int k = 0; k < combinations[i].length; k++)
            values[combinations[i][k].x][combinations[i][k].y].secondPriority +=
                1;
      } else if (board[combinations[i][j].x][combinations[i][j].y] == 2 &&
          values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
              highest)
        for (int k = 0; k < combinations[i].length; k++)
          values[combinations[i][k].x][combinations[i][k].y].secondPriority +=
              1;
    }
  }

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
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      playerValues[i][j].firstPriority = 0;
      playerValues[i][j].secondPriority = 0;
    }

  temp = 0;
  highest = 0;
  //First Priority
  for (int i = 0; i < playerCombinations.length; i++) {
    for (int j = 0; j < playerCombinations[i].length; j++) {
      if (curPlayer) {
        if (board[playerCombinations[i][j].x][playerCombinations[i][j].y] == 2)
          temp += 1;
      } else if (board[playerCombinations[i][j].x]
              [playerCombinations[i][j].y] ==
          1) temp += 1;
    }
    for (int j = 0; j < playerCombinations[i].length; j++) {
      if (playerValues[playerCombinations[i][j].x][playerCombinations[i][j].y]
              .firstPriority <
          temp)
        playerValues[playerCombinations[i][j].x][playerCombinations[i][j].y]
            .firstPriority = temp;
    }
    if (temp > highest) highest = temp;
    temp = 0;
  }

  //Second priority
  for (int i = 0; i < playerCombinations.length; i++) {
    for (int j = 0; j < playerCombinations[i].length; j++) {
      if (curPlayer) {
        if (board[playerCombinations[i][j].x][playerCombinations[i][j].y] ==
                2 &&
            playerValues[playerCombinations[i][j].x][playerCombinations[i][j].y]
                    .firstPriority ==
                highest)
          for (int k = 0; k < playerCombinations[i].length; k++)
            playerValues[playerCombinations[i][k].x][playerCombinations[i][k].y]
                .secondPriority += 1;
      } else if (board[playerCombinations[i][j].x]
                  [playerCombinations[i][j].y] ==
              1 &&
          playerValues[playerCombinations[i][j].x][playerCombinations[i][j].y]
                  .firstPriority ==
              highest) {
        for (int k = 0; k < playerCombinations[i].length; k++)
          playerValues[playerCombinations[i][k].x][playerCombinations[i][k].y]
              .secondPriority += 1;
      }
    }
  }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (playerValues[j][i].thirdPriority > -1 &&
          playerValues[j][i] > playerCurPotential) {
        playerCurPotential = playerValues[j][i];
        if (playerCurPotential > curPotential)
          aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  //drawPotential(values);
  //drawPotential(playerValues);
  //print("Greatest Player value: " +
  //    playerCurPotential.firstPriority.toString() +
  //    ", " +
  //    playerCurPotential.secondPriority.toString() +
  //    ", " +
  //    playerCurPotential.thirdPriority.toString() +
  //    ", final move:  " +
  //    aiGuessDimensions.x.toString() +
  //    ", " +
  //    aiGuessDimensions.y.toString());
  return aiGuessDimensions;
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

void drawPotential(List values) {
  String s = "";

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      s += "(";
      s += values[j][i].firstPriority.toString() +
          "," +
          values[j][i].secondPriority.toString() +
          "," +
          values[j][i].thirdPriority.toString();
      s += ") ";
    }
    print(s);
    s = "";
  }
}
