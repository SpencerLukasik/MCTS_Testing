import 'Functions.dart';
import 'classes.dart';
import 'Main.dart';

const int FIRST_VARIANCE = 0;
const int SECOND_VARIANCE = 0;

CoordinatePair AI_Move(
    List buttonList,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  Value curPotential = new Value(0, 0, 0);
  var board = List.generate(width, (i) => List(width), growable: false);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) board[i][j] = buttonList[i][j].state;
  updateValues(board, combinations, values, false);
  updateValues(board, playerCombinations, playerValues, true);
  //print("AI:");
  //drawPotential(values);
  //print("Player:");
  //drawPotential(playerValues);

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority == 4)
        return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority >
          -1) if (playerValues[j][i].firstPriority == 4)
        return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority ==
              3 &&
          values[j][i].secondPriority >= 2) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority > -1) if (playerValues[j][i]
                  .firstPriority ==
              3 &&
          playerValues[j][i].secondPriority >= 2) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority ==
              2 &&
          values[j][i].secondPriority >= 6) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority > -1) if (playerValues[j][i]
                  .firstPriority ==
              2 &&
          playerValues[j][i].secondPriority >= 6) return CoordinatePair(j, i);

  CoordinatePair aiGuessDimensions = CoordinatePair(0, 0);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].thirdPriority >
          -1) if (values[j][i] + playerValues[j][i] > curPotential) {
        curPotential = values[j][i] + playerValues[j][i];
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  return aiGuessDimensions;
}

CoordinatePair AI_Comparative_Move(
    List buttonList,
    List<List<CoordinatePair>> combinations,
    List values,
    List<List<CoordinatePair>> playerCombinations,
    List playerValues,
    bool curPlayer) {
  var board = List.generate(width, (i) => List(width), growable: false);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) board[i][j] = buttonList[i][j].state;
  updateValues(board, combinations, values, false);
  updateValues(board, playerCombinations, playerValues, true);
  //print("AI:");
  //drawPotential(values);
  //print("Player:");
  //drawPotential(playerValues);

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority == 4)
        return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority >
          -1) if (playerValues[j][i].firstPriority == 4)
        return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority ==
              3 &&
          values[j][i].secondPriority >= 2) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority > -1) if (playerValues[j][i]
                  .firstPriority ==
              3 &&
          playerValues[j][i].secondPriority >= 2) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (values[j][i].thirdPriority > -1) if (values[j][i].firstPriority ==
              2 &&
          values[j][i].secondPriority >= 6) return CoordinatePair(j, i);
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      if (playerValues[j][i].thirdPriority > -1) if (playerValues[j][i]
                  .firstPriority ==
              2 &&
          playerValues[j][i].secondPriority >= 6) return CoordinatePair(j, i);

  CoordinatePair aiGuessDimensions = CoordinatePair(0, 0);
  Value curPotential = new Value(0, 0, 0);

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].thirdPriority > -1) if (values[j][i] > curPotential) {
        curPotential = values[j][i];
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }

  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++) {
      if (values[j][i].thirdPriority > -1) if (playerValues[j][i] >
          curPotential) {
        curPotential = playerValues[j][i];
        aiGuessDimensions = CoordinatePair(j, i);
      }
    }
  return aiGuessDimensions;
}

List<CoordinatePair> getBestMovesInAnArrayFast(
    List board,
    List values,
    List playerValues,
    List<List<CoordinatePair>> combinations,
    List<List<CoordinatePair>> playerCombinations,
    bool curPlayer) {
  updateValues(board, combinations, values, curPlayer);
  updateValues(board, playerCombinations, playerValues, !curPlayer);
  //print("AI:");
  //drawPotential(values);
  //print("Player:");
  //drawPotential(playerValues);

  List<CoordinatePair> possibleMoves = [];

  int highestFirstAggressive = 0;
  int highestSecondAggressive = 0;
  int highestFirstDefensive = 0;
  int highestSecondDefensive = 0;

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      //Make sure the move is not taken
      if (values[j][i].thirdPriority > -1) {
        //Get the highest first priority
        if (values[j][i].firstPriority > highestFirstAggressive)
          highestFirstAggressive = values[j][i].firstPriority;

        if (playerValues[j][i].firstPriority > highestFirstDefensive)
          highestFirstDefensive = playerValues[j][i].firstPriority;
      }
    }
  }

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      //Make sure the move is not taken
      if (values[j][i].thirdPriority > -1) {
        //Get the highest second priority based on the first
        if (values[j][i].firstPriority == highestFirstAggressive &&
            values[j][i].secondPriority > highestSecondAggressive)
          highestSecondAggressive = values[j][i].secondPriority;

        if (playerValues[j][i].firstPriority == highestFirstDefensive &&
            playerValues[j][i].secondPriority > highestSecondDefensive)
          highestSecondDefensive = playerValues[j][i].secondPriority;
      }
    }
  }

  //Compare the highest values calculated
  //If we have 4 in a row,
  if (highestFirstAggressive == (4))
    addToList(
        possibleMoves, values, highestFirstAggressive, highestSecondAggressive);
  //If our opponent has 4 in a row,
  else if (highestFirstDefensive == (4))
    addToList(possibleMoves, playerValues, highestFirstDefensive,
        highestSecondDefensive);
  //If we have an open 3,
  else if (highestFirstAggressive == (3) && highestSecondAggressive >= (2))
    addToList(
        possibleMoves, values, highestFirstAggressive, highestSecondAggressive);
  //If our opponent has an open 3,
  else if (highestFirstDefensive == (3) && highestSecondDefensive >= (2))
    addToList(possibleMoves, playerValues, highestFirstDefensive,
        highestSecondDefensive);
  //If we have two open twos that connect,
  else if (highestFirstAggressive == (2) && highestSecondAggressive >= (6))
    addToList(
        possibleMoves, values, highestFirstAggressive, highestSecondAggressive);
  //If our opponent has two open twos that connect,
  else if (highestFirstDefensive == (2) && highestSecondDefensive >= (6))
    addToList(possibleMoves, playerValues, highestFirstDefensive,
        highestSecondDefensive);
  else {
    int highestFirstTotal = 0;
    int highestSecondTotal = 0;
    //First total
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < width; j++) {
        if (values[j][i].thirdPriority > -1) {
          if (values[j][i].firstPriority + playerValues[j][i].firstPriority >
              highestFirstTotal)
            highestFirstTotal =
                values[j][i].firstPriority + playerValues[j][i].firstPriority;
        }
      }
    }
    //Second total
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < width; j++) {
        if (values[j][i].thirdPriority > -1) {
          if (values[j][i].firstPriority + playerValues[j][i].firstPriority ==
                  highestFirstTotal &&
              values[j][i].secondPriority + playerValues[j][i].secondPriority >
                  highestSecondTotal)
            highestSecondTotal =
                values[j][i].secondPriority + playerValues[j][i].secondPriority;
        }
      }
    }
    //Append
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < width; j++) {
        if (values[j][i].thirdPriority > -1) {
          if (values[j][i].firstPriority + playerValues[j][i].firstPriority >=
                  (highestFirstTotal - FIRST_VARIANCE) &&
              values[j][i].secondPriority + playerValues[j][i].secondPriority >=
                  (highestSecondTotal - SECOND_VARIANCE))
            possibleMoves.add(new CoordinatePair(j, i));
        }
      }
    }
  }

  return possibleMoves;
}

void addToList(List<CoordinatePair> possibleMoves, List values,
    int highestFirst, int highestSecond) {
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      if (values[j][i].thirdPriority > -1) {
        if (values[j][i].firstPriority == highestFirst &&
            values[j][i].secondPriority >= (highestSecond))
          possibleMoves.add(new CoordinatePair(j, i));
      }
    }
  }
}
