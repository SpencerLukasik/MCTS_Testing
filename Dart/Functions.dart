import 'classes.dart';
import 'dart:io';
import 'Main.dart';

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

void makeMove(
    List board,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    List values,
    List playerValues,
    bool curPlayer,
    CoordinatePair move) {
  if (curPlayer) {
    board[move.x][move.y] = 1;
    values[move.x][move.y].thirdPriority = -1;
    playerValues[move.x][move.y].thirdPriority = -1;
    removePotential(combinations, values, move);
  } else {
    board[move.x][move.y] = 2;
    values[move.x][move.y].thirdPriority = -1;
    playerValues[move.x][move.y].thirdPriority = -1;
    removePotential(playerCombinations, playerValues, move);
  }
}

bool fullBoard(board) {
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) if (board[i][j].state == 0) return false;
  return true;
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
      if (curPlayer) {
        if (board[combinations[i][j].x][combinations[i][j].y] == 1) temp += 1;
      } else if (board[combinations[i][j].x][combinations[i][j].y] == 2)
        temp += 1;
    }
    for (int j = 0; j < combinations[i].length; j++) {
      if (values[combinations[i][j].x][combinations[i][j].y].firstPriority <
          temp)
        values[combinations[i][j].x][combinations[i][j].y].firstPriority = temp;
    }
    if (temp > highest) highest = temp;
    temp = 0;
  }
  if (highest == 0) return;

  //Populate Second Priority.  Check if a single combo has a value in it that contains a combination
  //of the highest first priority.  For every node in that combo, increment it's second potential by 1.
  temp = highest;
  for (int i = 0; i < combinations.length; i++) {
    for (int j = 0; j < combinations[i].length; j++) {
      if (curPlayer) {
        if (board[combinations[i][j].x][combinations[i][j].y] == 1 &&
            values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
                highest) temp -= 1;
      } else if (board[combinations[i][j].x][combinations[i][j].y] == 2 &&
          values[combinations[i][j].x][combinations[i][j].y].firstPriority ==
              highest) temp -= 1;
    }
    if (temp == 0)
      for (int j = 0; j < combinations[i].length; j++)
        values[combinations[i][j].x][combinations[i][j].y].secondPriority += 1;
    temp = highest;
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
      if (j + (5 - 1) < width) {
        combinations.add(new List(5));

        for (int k = 0; k < 5; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i));
          potential[j + k][i].thirdPriority += 1;
        }

        curIndex += 1;
      }

      //Check Vertical wins
      if (i + (5 - 1) < width) {
        combinations.add(new List(5));

        for (int k = 0; k < 5; k++) {
          combinations[curIndex][k] = (CoordinatePair(j, i + k));
          potential[j][i + k].thirdPriority += 1;
        }

        curIndex += 1;
      }
      //Check Up-Right wins
      if (j + (5 - 1) < width && i - (5 - 1) >= 0) {
        combinations.add(new List(5));

        for (int k = 0; k < 5; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i - k));
          potential[j + k][i - k].thirdPriority += 1;
        }

        curIndex += 1;
      }
      //Check Down-Right wins
      if (j + (5 - 1) < width && i + (5 - 1) < width) {
        combinations.add(new List(5));

        for (int k = 0; k < 5; k++) {
          combinations[curIndex][k] = (CoordinatePair(j + k, i + k));
          potential[j + k][i + k].thirdPriority += 1;
        }

        curIndex += 1;
      }
    }
  }
}

void copy2DList(List origin, List copy) {
  for (int i = 0; i < origin.length; i++)
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = origin[i][j];
    }
}

void copyCombination(
    List<List<CoordinatePair>> origin, List<List<CoordinatePair>> copy) {
  copy.clear();
  for (int i = 0; i < origin.length; i++) {
    copy.add(new List(origin[i].length));
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = origin[i][j];
    }
  }
}

void copy2DValue(List origin, List copy) {
  for (int i = 0; i < origin.length; i++)
    for (int j = 0; j < origin[i].length; j++) {
      copy[i][j] = Value(origin[i][j].firstPriority,
          origin[i][j].secondPriority, origin[i][j].thirdPriority);
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

void drawBoard(List board) {
  stdout.write("   ");
  for (int i = 0; i < width; i++) {
    stdout.write(" ");
    if (i < 10) stdout.write(" ");
    stdout.write(i.toString() + " ");
  }
  print("");

  stdout.write("   ");
  for (int i = 0; i < width; i++) stdout.write("----");
  print("");

  for (int i = 0; i < width; i++) {
    stdout.write(i.toString() + " ");
    if (i < 10) stdout.write(" ");
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
