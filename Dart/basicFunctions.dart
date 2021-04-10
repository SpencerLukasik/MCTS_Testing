import 'dart:io';
import 'classes.dart';
import 'Main.dart';
import 'ValueFunctions.dart';

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

void make_move(
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
    for (int j = 0; j < width; j++) if (board[i][j] == 0) return false;
  return true;
}
