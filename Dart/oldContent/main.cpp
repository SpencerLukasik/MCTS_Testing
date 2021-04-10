#include<iostream>
#include<memory>
#include<vector>
#include<algorithm>
#include<ctime>
using namespace std;

void buildBoard(const int&, const int&, int**&);
bool getValidCordinates(int**&, pair<int, int>&, const int&, const int&);
bool checkWin(int**&, int&, const int&, const int&, const int&);

int main()
{
    const int width = 7;
    const int height = 7;
    //Number of squares in a row needed to get a victory
    const int n = 4;


    //signifies current player, chosen at random
    int curPlayer = 1;

    pair<int, int> guessDimensions;
    bool winner = false;

    int** board = new int* [height];
    for (int i = 0; i < height; i++)
    {
        board[i] = new int[width];
        for (int j = 0; j < width; j++)
            board[i][j] = 0;
    }

    //Game loop
    while (true)
    { 
            buildBoard(width, height, board);

            //verify guess
            while (!getValidCordinates(board, guessDimensions, width, height))
                std::cout << "Sorry!  That spot is already taken!  Try again" << endl;

            //Add the player's piece
            board[guessDimensions.first][guessDimensions.second] = curPlayer;
            //Update potential wins for the computer

        if (checkWin(board, curPlayer, width, height, n))
            break;
        else
            curPlayer = curPlayer * -1;
    }

    buildBoard(width, height, board);
    cout << "Congratulations!  Player " << curPlayer << " won the game!" << endl;

    for (int i = 0; i < width; i++)
        delete[] board[i];
    delete[] board;

    return 0;
}

void buildBoard(const int& width, const int& height, int**& board)
{
    //Top of board
    cout << "   ";
    for (int i = 0; i < width; i++)
        cout << "  " << i << " ";
    cout << endl;

    cout << "   ";
    for (int i = 0; i < width; i++)
        cout << "----";
    cout << endl;

    for (int i = 0; i < height; i++)
    {
        cout << i << "  ";
        for (int j = 0; j < width; j++)
        {
            if (board[i][j] == 1)
                cout << "| o ";
            else if (board[i][j] == -1)
                cout << "| x ";
            else
                cout << "|   ";
        }
        cout << "|" << endl;

        //Bottom of each line
        cout << "   ";
        for (int j = 0; j < width; j++)
            cout << "----";
        cout << endl;
    }
}

//Ensure the input does not go out of bounds
bool getValidCordinates(int**& board, pair<int, int>& guessDimensions, const int& width, const int& height)
{
    cout << "Height: ";
    cin >> guessDimensions.first;
    while (guessDimensions.first >= height || guessDimensions.first < 0)
    {
        cout << "That was outside the board!  The height goes from 0 to " << height-1 << endl << "Height: ";
        cin >> guessDimensions.first;
    }
    cout << "Width: ";
    cin >> guessDimensions.second;
    while (guessDimensions.second >= width || guessDimensions.second < 0)
    {
        cout << "That was outside the board!  The width goes from 0 to " << width-1 << endl << "Width: ";;
        cin >> guessDimensions.second;
    }

    if (board[guessDimensions.first][guessDimensions.second] != 0)
        return false;
    return true;
}

bool checkWin(int**& board, int& curPlayer, const int& width, const int& height, const int& n)
{
    int curTotal = 0;
    for (int i = 0; i < width; i++)
        for (int j = 0; j < height; j++)
        {
            //If we find a spot that is taken,
            if (board[i][j] == curPlayer)
            {
                curTotal++;
                //Check to see if there is a combination to the right,
                if (j + n <= width)
                    for (int k = 1; k < n; k++)
                    {
                        if (board[i][j+k] == curPlayer)
                            curTotal++;
                        else {
                                curTotal = 1;
                                break;
                        }
                        if (curTotal == n)
                            return true;
                    }

                    //Down,
                if (i + n <= height)
                    for (int k = 1; k < n; k++)
                    {
                        if (board[i+k][j] == curPlayer)
                            curTotal++;
                        else {
                                curTotal = 1;
                                break;
                        }
                        if (curTotal == n)
                            return true;
                    }

                    //Down-Right,
                if (j + n <= width && i + n <= height)
                    for (int k = 1; k < n; k++)
                    {
                        if (board[i+k][j+k] == curPlayer)
                            curTotal++;
                        else {
                                curTotal = 1;
                                break;
                        }
                        if (curTotal == n)
                            return true;
                    }

                    //Up-Right
                if (i - (n-1) >= 0 && j + n <= width)
                    for (int k = 1; k < n; k++)
                    {
                        if (board[i-k][j+k] == curPlayer)
                            curTotal++;
                        else {
                                curTotal = 0;
                                break;
                        }
                        if (curTotal == n)
                            return true;
                    }
            }
        }
        return false;
}
