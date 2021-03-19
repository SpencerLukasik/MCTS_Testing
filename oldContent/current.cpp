#include<iostream>
#include<memory>
#include<vector>
#include<algorithm>
#include<ctime>
using namespace std;

void buildBoard(const int&, const int&, int**&);
bool getValidCordinates(int**&, pair<int, int>&, const int&, const int&);
bool checkWin(int**&, int&, const int&, const int&, const int&);
void populate(vector<vector<pair<int, int>>>&, int**&, const int&, const int&, const int&);
void removePotential(int**&, vector<vector<pair<int, int>>>&, pair<int, int>&);
void AI_Move(int**&, int**&, vector<vector<pair<int, int>>>&, const int&, const int&, int&);

int main()
{
    const int width = 9;
    const int height = 9;
    //Number of squares in a row needed to get a victory
    const int n = 3;


    //signifies current player, chosen at random
    int curPlayer;
    srand(time(0));
    if (rand() % 2 == 0)
        curPlayer = 1;
    else
        curPlayer = -1;

    pair<int, int> guessDimensions;
    bool winner = false;

    int** board = new int* [height];
    int** potential = new int* [height];
    for (int i = 0; i < height; i++)
    {
        board[i] = new int[width];
        potential[i] = new int[width];
        for (int j = 0; j < width; j++)
        {
            board[i][j] = 0;
            potential[i][j] = 0;
        }
    }

    //Get all possible winning combinations
    vector<vector<pair<int, int>>> combinations;
    populate(combinations, potential, width, height, n);


    //Game loop
    while (true)
    { 
      if (curPlayer == 1)
      {
            system("CLS");
            buildBoard(width, height, board);

            //verify guess
            while (!getValidCordinates(board, guessDimensions, width, height))
                cout << "Sorry!  That spot is already taken!  Try again" << endl;

            //Add the player's piece
            board[guessDimensions.first][guessDimensions.second] = curPlayer;
            potential[guessDimensions.first][guessDimensions.second] = -1;
            //Update potential wins for the computer
            removePotential(potential, combinations, guessDimensions);
       }
       else
            AI_Move(board, potential, combinations, width, height, curPlayer);

        if (checkWin(board, curPlayer, width, height, n))
            break;
        else
            curPlayer = curPlayer * -1;
    }
    system("CLS");
    buildBoard(width, height, board);
    if (curPlayer > 0)
        cout << "Congratulations!  The human won the game!" << endl;
    else
        cout << "Oof!  Computer wins this round!" << endl;

    for (int i = 0; i < width; i++)
        delete[] board[i];
    delete[] board;

    return 0;
}

//Multiplies the potential value of each square, or the number of possible combinations a square fills, with the 
//greatest number of active squares any single combination has.
//Does not take the other player into account, and as such defensive strategy is all but non-existant.
//This could be remedied with a similar value obtained above for the human player and crossing this with the move that
//contains the highest offensive potential.  This would only look one move into the future, however.
void AI_Move(int**& board, int**& potential, vector<vector<pair<int, int>>>& combinations, const int& width, const int& height, int& curPlayer)
{
    //Creates the combination values, or the greatest number of positions that have been taken within a valid combination
    int** combinationValue = new int*[height];
    for (int i = 0; i < height; i++)
    {
        combinationValue[i] = new int[width];
        for (int j = 0; j < width; j++)
            combinationValue[i][j] = 1;
    }
    int temp = 1;
    for (int i = 0; i < combinations.size(); i++)
    {
        for (int j = 0; j < combinations[i].size(); j++)
            if (board[combinations[i][j].first][combinations[i][j].second] == -1)
                temp++;
        for (int j = 0; j < combinations[i].size(); j++)
            if (combinationValue[combinations[i][j].first][combinations[i][j].second] < temp)
                combinationValue[combinations[i][j].first][combinations[i][j].second] = temp;
        temp = 1;
    }

    pair<int, int> AI_guessDimensions = make_pair(0, 0);
    int curPotential = -1;

    for (int i = 0; i < height; i++)
        for (int j = 0; j < width; j++)
        {
            if (potential[i][j] * combinationValue[i][j] > curPotential)
            {
                curPotential = potential[i][j] * combinationValue[i][j];
                AI_guessDimensions = make_pair(i, j);
            }
        }

    for (int i = 0; i < width; i++)
        delete[] combinationValue[i];
    delete[] combinationValue;
    board[AI_guessDimensions.first][AI_guessDimensions.second] = curPlayer;
    potential[AI_guessDimensions.first][AI_guessDimensions.second] = -1;
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

void populate(vector<vector<pair<int, int>>>& combinations, int**& potential, const int& width, const int& height, const int& n)
{
    vector<pair<int, int>> temp;
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            //Check Horizontal wins
            if (j + (n - 1) < width)
            {
                for (int k = 0; k < n; k++)
                {
                    temp.push_back(make_pair(i, j + k));
                    potential[i][j + k] += 1;
                }

                combinations.push_back(temp);
                temp.clear();
            }

            //Check Vertical wins
            if (i + (n - 1) < height)
            {
                for (int k = 0; k < n; k++)
                {
                    temp.push_back(make_pair(i + k, j));
                    potential[i + k][j] += 1;
                }
                combinations.push_back(temp);
                temp.clear();
            }
            //Check Up-Right wins
            if (j + (n - 1) < width && i - (n - 1) >= 0)
            {
                for (int k = 0; k < n; k++)
                {
                    temp.push_back(make_pair(i - k, j + k));
                    potential[i - k][j + k] += 1;
                }
                combinations.push_back(temp);
                temp.clear();
            }
            //Check Down-Right wins
            if (j + (n - 1) < width && i + (n - 1) < height)
            {
                for (int k = 0; k < n; k++)
                {
                    temp.push_back(make_pair(i + k, j + k));
                    potential[i + k][j + k] += 1;
                }
                combinations.push_back(temp);
                temp.clear();
            }
        }
    }
}

//Remove potential wins based on the new cordinate
void removePotential(int**& potential, vector<vector<pair<int, int>>>& combinations, pair<int, int>& newCordinate)
{
    for (int i = 0; i < combinations.size(); i++)
    { 
        //Find all combinations that have the cordinate and remove them from the possible winning configurations
        if (find(combinations[i].begin(), combinations[i].end(), newCordinate) != combinations[i].end())
        {
           //Deduct potential points from cordinates connected to the removed cordinate
            for (int j = 0; j < combinations[i].size(); j++)
                if (potential[combinations[i][j].first][combinations[i][j].second] > -1)
                    potential[combinations[i][j].first][combinations[i][j].second] -= 1;
            combinations.erase(combinations.begin() + i);
            i = i - 1;
        }
    }
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