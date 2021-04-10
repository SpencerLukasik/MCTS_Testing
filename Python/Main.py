import Classes as c
import Globals as g
import BasicFunctions as func
import MCTS
import ValueFunctions as vfunc

#Variables for maintaining boardstate
curPlayer = True
board = [[0 for i in range(g.width)] for j in range(g.width)]
values = [[0 for i in range(g.width)] for j in range(g.width)]
playerValues = [[0 for i in range(g.width)] for j in range(g.width)]
combinations = []
playerCombinations = []
prevCoordinates = c.CoordinatePair(-1, -1)


def GameLoop(board, values, playerValues, combinations, playerCombinations, prevCoordinates, curPlayer):
    while (True):
        #If it's the human's turn
        if (curPlayer):
            func.drawBoard(board)
            prevCoordinates.y = int(input("X: "), 10)
            prevCoordinates.x = int(input("Y: "), 10)

            func.make_move(board, combinations, playerCombinations, values, playerValues, curPlayer, prevCoordinates)
            if (func.checkWin(board, playerCombinations, curPlayer)):
                break
            curPlayer = not curPlayer
        #If it's the AI's turn
        else:
            #MCTS move
            if (g.playAgainstMCTS):
                prevCoordinates = MCTS.MCTS_Move(board, combinations, values, playerCombinations, playerValues, curPlayer)
            #Value-based move
            else:
                prevCoordinates = AI_Move(board, combinations, values, playerCombinations, playerValues, curPlayer)

            func.make_move(board, combinations, playerCombinations, values, playerValues, curPlayer, prevCoordinates)
            if (func.checkWin(board, combinations, curPlayer)):
                break
            curPlayer = not curPlayer

    func.drawBoard(board)
    if (curPlayer):
        print("Congratulations to the Human!")
    else:
        print("Congratulations to the AI!")


def AI_Move(board, combinations, values, playerCombinations, playerValues, curPlayer):
    
    aiGuessDimensions = c.CoordinatePair(0, 0)
    curPotential = c.Value(0, 0, 0)

    vfunc.updateValues(board, combinations, values, curPlayer)
    vfunc.updateValues(board, playerCombinations, playerValues, curPlayer)

    #Potential of Aggressive moves
    for i in range(g.width):
        for j in range(g.width):
      #Check to make sure spot is not taken
            if (values[j][i].thirdPriority > -1 and playerValues[j][i].thirdPriority > -1 and (values[i][j]+playerValues[i][j]) > curPotential):
                curPotential.firstPriority = values[j][i].firstPriority + playerValues[j][i].firstPriority
                curPotential.secondPriority = values[j][i].secondPriority + playerValues[j][i].secondPriority
                curPotential.thirdPriority = values[j][i].thirdPriority + playerValues[j][i].thirdPriority
                aiGuessDimensions = c.CoordinatePair(j, i)

    return aiGuessDimensions


vfunc.populate(combinations, values)
vfunc.populate(playerCombinations, playerValues)
GameLoop(board, values, playerValues, combinations, playerCombinations, prevCoordinates, curPlayer)