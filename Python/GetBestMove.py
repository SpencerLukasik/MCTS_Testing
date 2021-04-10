#Takes in a 2D array of integers and outputs a Coordinate Pair (x, y) that it believes is the best move to make

import Globals as g
import Classes as c
import ValueFunctions as vfunc

#Compares the values of all agressive and defensive moves, and returns the highest summation of both strategies.
#This is much better for getting the best general move, but it can get confused in complex boardstates, as it does
#not consider how close the opponent is to making a winning move; it considers the highest value per square, which
#often times is the best blocking or aggressive move, but may not always be so
def getBestMove(board):
    combinations = []
    playerCombinations = []
    values = [[0 for i in range(g.width)] for j in range(g.width)]
    playerValues = [[0 for i in range(g.width)] for j in range(g.width)]    
    aiGuessDimensions = c.CoordinatePair(0, 0)
    vfunc.populate(combinations, values)
    vfunc.populate(playerCombinations, playerValues)
    RePopulate(board, values, playerValues, combinations, playerCombinations)
    vfunc.updateValues(board, combinations, values, True)
    vfunc.updateValues(board, playerCombinations, playerValues, True)

    curPotential = c.Value(0, 0, 0)
    for i in range(g.width):
        for j in range(g.width):
      #Takes the Aggregate Potential of both player's possible moves
            if (values[j][i].thirdPriority > -1 and playerValues[j][i].thirdPriority > -1 and (values[i][j]+playerValues[j][i]) > curPotential):
                curPotential.firstPriority = values[j][i].firstPriority + playerValues[j][i].firstPriority
                curPotential.secondPriority = values[j][i].secondPriority + playerValues[j][i].secondPriority
                curPotential.thirdPriority = values[j][i].thirdPriority + playerValues[j][i].thirdPriority
                aiGuessDimensions = c.CoordinatePair(j, i)

    return aiGuessDimensions

#First gets the highest potential of the most aggressive move, the highest potential of a defensive move,
#and compares the two.  This approach is better when considering the alternative strategies for white
#and black, but it may make worse general moves when there is no need to be overly defensive.
#Generally leads to longer games
def getBestAggressiveOrDefensiveMove(board):
    combinations = []
    playerCombinations = []
    values = [[0 for i in range(g.width)] for j in range(g.width)]
    playerValues = [[0 for i in range(g.width)] for j in range(g.width)]    
    aiGuessDimensions = c.CoordinatePair(0, 0)
    vfunc.populate(combinations, values)
    vfunc.populate(playerCombinations, playerValues)
    RePopulate(board, values, playerValues, combinations, playerCombinations)
    vfunc.updateValues(board, combinations, values, True)
    vfunc.updateValues(board, playerCombinations, playerValues, True)

    #Potential of Aggressive moves
    curPotential = c.Value(0, 0, 0)

    for i in range(g.width):
        for j in range(g.width):
        #Check to make sure spot is not taken
            if (values[j][i].thirdPriority > -1 and values[j][i] > curPotential):
                #If first priority is higher, OR if first priority is the same AND second
                #priority is higher, OR if first AND second priorities are the same but THIRD
                #priority is higher, make this the preferred move
                curPotential = values[j][i]
                aiGuessDimensions = c.CoordinatePair(j, i)

    #Defensive moves
    playerCurPotential = c.Value(0, 0, 0)

    #updateValues(board, playerCombinations, playerValues, curPlayer);
    for i in range(g.width):
        for j in range(g.width):
            if (playerValues[j][i].thirdPriority > -1 and playerValues[j][i] > playerCurPotential):
                playerCurPotential = playerValues[j][i]
                if (playerCurPotential > curPotential):
                    aiGuessDimensions = c.CoordinatePair(j, i)

    return aiGuessDimensions


def RePopulate(board, values, playerValues, combinations, playerCombinations):
    for i in range(len(board)):
        for j in range(len(board[i])):
            if (board[i][j]==1):
                vfunc.removePotential(combinations, values, c.CoordinatePair(i, j))
                values[i][j].thirdPriority = -1
                playerValues[i][j].thirdPriority = -1
            elif (board[i][j]==2):
                vfunc.removePotential(playerCombinations, playerValues, c.CoordinatePair(i, j))
                values[i][j].thirdPriority = -1
                playerValues[i][j].thirdPriority = -1
