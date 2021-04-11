import 'classes.dart';
import 'ClassicGame.dart';
import 'ValueFunctions.dart';
import 'MCTS.dart';

//Change these values to alter the game
const int width = 3;
const int n = 3;
const int numberOfSimulations = 1000;
const bool playAgainstMCTS = false;

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

  if (playAgainstMCTS) {
    MCTS_GameLoop(board, values, playerValues, combinations, playerCombinations,
        prevCoordinates, numberOfSimulations, curPlayer);
  } else {
    GameLoop(board, values, playerValues, combinations, playerCombinations,
        prevCoordinates, curPlayer);
  }
}
