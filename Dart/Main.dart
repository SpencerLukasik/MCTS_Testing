import 'classes.dart';
import 'ClassicGame.dart';
import 'Functions.dart';
import 'dart:io';
import 'MCTS.dart';
import 'dart:math';

//Change these values to alter the game
const int width = 19;
const int n = 5;
const int numberOfSimulations = 1000;
const bool playingAgainstMCTS = true;
List<CoordinatePair> possibleMoves = [];

void main() {
  //Current player; true is human
  bool curPlayer = true;
  var board = List.generate(width, (i) => List(width), growable: false);

  CoordinatePair prevCoordinates = new CoordinatePair(-1, -1);
  var values = List.generate(width, (i) => List(width), growable: false);
  var playerValues = List.generate(width, (i) => List(width), growable: false);
  List<List<CoordinatePair>> combinations = [];
  List<List<CoordinatePair>> playerCombinations = [];

  //Set up the board and baseline values
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      board[i][j] = 0;
    }
  populate(combinations, values);
  populate(playerCombinations, playerValues);

  while (true) {
    if (curPlayer) {
      drawBoard(board);
      print("X: ");
      prevCoordinates.y = int.parse(stdin.readLineSync());
      print("Y: ");
      prevCoordinates.x = int.parse(stdin.readLineSync());

      makeMove(board, combinations, playerCombinations, values, playerValues,
          curPlayer, prevCoordinates);
      if (checkWin(board, playerCombinations, curPlayer)) break;
      curPlayer = !curPlayer;
    } else {
      if (playingAgainstMCTS)
        prevCoordinates = MCTS_Move(board, combinations, values,
            playerCombinations, playerValues, curPlayer);
      else {
        possibleMoves = getBestMovesInAnArrayFast(board, values, playerValues,
            combinations, playerCombinations, curPlayer);
        prevCoordinates = possibleMoves[Random().nextInt(possibleMoves.length)];
      }
      makeMove(board, combinations, playerCombinations, values, playerValues,
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
