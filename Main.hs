module Main where

import Board
import System.IO
import Data.List (find)

-- Main function to play the game
main :: IO ()
main = do
    putStrLn "Welcome to Connect Four!"
    putStrLn "Choose game mode:"
    putStrLn "1. Human vs Human"
    putStrLn "2. Human vs Computer"
    
    mode <- getGameMode
    putStrLn "Player 1: O    Player 2: X"
    let board = mkBoard 7 6  -- Create a 7x6 board (7 columns, 6 rows)
    
    case mode of
        1 -> playGame board mkPlayer False  -- Human vs Human
        2 -> playGame board mkPlayer True   -- Human vs Computer

-- Get game mode from user
getGameMode :: IO Int
getGameMode = do
    line <- getLine
    let parsed = reads line :: [(Int, String)]
    if null parsed
        then do
            putStrLn "Invalid input! Please enter 1 or 2."
            getGameMode
        else do
            let (mode, _) = head parsed
            if mode /= 1 && mode /= 2
                then do
                    putStrLn "Please enter 1 for Human vs Human or 2 for Human vs Computer."
                    getGameMode
                else return mode

-- Convert player to character representation
playerToChar :: Player -> Char
playerToChar 0 = '.'  -- Empty space
playerToChar 1 = 'O'  -- Player 1
playerToChar 2 = 'X'  -- Player 2
playerToChar _ = '?'  -- Invalid player (should not occur)

-- Read a slot number from the player
readSlot :: Board -> Player -> IO Int
readSlot bd p = do
    let playerChar = if p == mkPlayer then 'O' else 'X'
    putStrLn $ "Player " ++ show p ++ " (" ++ [playerChar] ++ "), choose a column (1-" ++ show (numSlot bd) ++ "):"
    line <- getLine
    let parsed = reads line :: [(Int, String)]
    if null parsed
        then do
            putStrLn "Invalid input! Please enter a number."
            readSlot bd p
        else do
            let (col, _) = head parsed
            if col < 1 || col > numSlot bd
                then do
                    putStrLn $ "Column must be between 1 and " ++ show (numSlot bd) ++ "."
                    readSlot bd p
                else if not (isSlotOpen bd col)
                    then do
                        putStrLn "That column is full. Choose another one."
                        readSlot bd p
                    else return col

-- Get a computer move
getComputerMove :: Board -> Player -> Int
getComputerMove bd p =
    -- Try to find a winning move
    case findWinningMove bd p of
        Just col -> col
        Nothing -> 
            -- Try to block opponent's winning move
            let opponent = if p == mkPlayer then mkOpponent else mkPlayer
            in case findWinningMove bd opponent of
                Just col -> col
                Nothing -> 
                    -- Otherwise, try the center or first available column
                    let center = (numSlot bd + 1) `div` 2
                    in if isSlotOpen bd center
                       then center
                       else findFirstOpenSlot bd 1

-- Find a move that would lead to a win
findWinningMove :: Board -> Player -> Maybe Int
findWinningMove bd p =
    find (\i -> isSlotOpen bd i && isWonBy (dropInSlot bd i p) p) [1..numSlot bd]

-- Find the first open slot starting from a given column
findFirstOpenSlot :: Board -> Int -> Int
findFirstOpenSlot bd i
    | i > numSlot bd = 1  -- Wrap around if we've checked all columns
    | isSlotOpen bd i = i
    | otherwise = findFirstOpenSlot bd (i+1)

-- Play the game
playGame :: Board -> Player -> Bool -> IO ()
playGame bd p vsComputer = do
    -- Clear screen and show the current board
    putStrLn "\n"
    putStrLn $ boardToStr playerToChar bd
    putStrLn ""
    
    -- Check if the game is over
    if isFull bd
        then putStrLn "Game over! The board is full. It's a draw!"
        else do
            -- Get the player's move (human or computer)
            col <- if vsComputer && p == mkOpponent
                     then do
                        putStrLn "Computer is thinking..."
                        let computerCol = getComputerMove bd p
                        putStrLn $ "Computer chooses column " ++ show computerCol
                        return computerCol
                     else readSlot bd p
            
            -- Update the board
            let newBoard = dropInSlot bd col p
            
            -- Check if the player won
            if isWonBy newBoard p
                then do
                    putStrLn $ boardToStr playerToChar newBoard
                    if vsComputer && p == mkOpponent
                        then putStrLn "Computer wins!"
                        else putStrLn $ "Player " ++ show p ++ " wins!"
                else do
                    -- Switch to the other player
                    let nextPlayer = if p == mkPlayer then mkOpponent else mkPlayer
                    playGame newBoard nextPlayer vsComputer