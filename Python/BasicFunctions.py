import Globals as g
import ValueFunctions as vfunc

def checkWin(board, combinations, curPlayer):
    winDetected = False
    for i in range(len(combinations)):
        winDetected = True
        for j in range(len(combinations[i])):
            if (curPlayer):
                if (board[combinations[i][j].x][combinations[i][j].y] != 1):
                    winDetected = False
                    break
            else:
                if (board[combinations[i][j].x][combinations[i][j].y] != 2):
                    winDetected = False
                    break

        if (winDetected):
            return True
    return False

def resetGame(board):
    for i in range(g.width):
        for j in range(g.width):
            board[i][j] = 0

def drawBoard(board):
    print("   ", end='')
    for i in range(g.width):
        print(" ", end='')
        if (i < 10):
            print(" ", end='')
        print(f"{i} ", end='')
    
    print("")
    print("   ", end='')
    for i in range(g.width):
        print("----", end='')
    print("")

    for i in range(g.width):
        print(f"{i} ", end='')
        if (i < 10):
            print(" ", end='')
        for j in range(g.width):
            if (board[i][j] == 1):
                print("| o ", end='')
            elif (board[i][j] == 2):
                print("| x ", end='')
            else:
                print("|   ", end='')
    
        print("|", end='')
        print("")

        #Bottom of each line
        print("   ", end='')
        for j in range(g.width):
            print("----", end='')
        print("")

def make_move(board, combinations, playerCombinations, values, playerValues, curPlayer, move):
    if (curPlayer):
        board[move.x][move.y] = 1
        values[move.x][move.y].thirdPriority = -1
        playerValues[move.x][move.y].thirdPriority = -1
        vfunc.removePotential(combinations, values, move)
    else:
        board[move.x][move.y] = 2
        values[move.x][move.y].thirdPriority = -1
        playerValues[move.x][move.y].thirdPriority = -1
        vfunc.removePotential(playerCombinations, playerValues, move)


def fullBoard(board):
    for i in range(g.width):
        for j in range(g.width):
            if (board[i][j] == 0):
                return False
    return True
