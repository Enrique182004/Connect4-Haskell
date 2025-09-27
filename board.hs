module Board (
    Board,
    Player,
    mkBoard,
    mkPlayer,
    mkOpponent,
    dropInSlot,
    isSlotOpen,
    numSlot,
    isFull,
    isWonBy,
    boardToStr
) where

-- Type definitions
type Board = [[Player]] -- Board represented as a list of columns
type Player = Int       -- Players represented as integers

-- Create an empty m x n board
-- m = number of columns, n = number of rows
mkBoard :: Int -> Int -> Board
mkBoard m n = replicate m (replicate n 0)  -- 0 represents empty space

-- First player
mkPlayer :: Player
mkPlayer = 1

-- Second player (opponent)
mkOpponent :: Player
mkOpponent = 2

-- Get the number of slots (columns) in the board
numSlot :: Board -> Int
numSlot = length

-- Check if a slot (column) is open
isSlotOpen :: Board -> Int -> Bool
isSlotOpen bd i
    | i < 1 || i > length bd = False  -- Invalid column
    | otherwise = 0 `elem` (bd !! (i-1))  -- Check if column has an empty space

-- Check if the board is full
isFull :: Board -> Bool
isFull bd = not (any (elem 0) bd)

-- Drop a disc in the specified slot
dropInSlot :: Board -> Int -> Player -> Board
dropInSlot bd i p
    | i < 1 || i > length bd = bd  -- Invalid column, return unchanged board
    | otherwise = take (i-1) bd ++ [updatedCol] ++ drop i bd
    where
        col = bd !! (i-1)
        updatedCol = dropInColumn col p
        
-- Helper function to drop a disc in a column
dropInColumn :: [Player] -> Player -> [Player]
dropInColumn col p = 
    let emptyIndices = [i | (i, v) <- zip [0..] col, v == 0]
    in if null emptyIndices
       then col  -- Column is full, no change
       else let firstEmptyIndex = minimum emptyIndices  -- Use minimum instead of maximum
            in take firstEmptyIndex col ++ [p] ++ drop (firstEmptyIndex + 1) col

-- Check if the game is won by a player
isWonBy :: Board -> Player -> Bool
isWonBy bd p = 
    horizontalWin bd p || 
    verticalWin bd p || 
    diagonalWin1 bd p || 
    diagonalWin2 bd p

-- Check for horizontal win (with wrap-around)
horizontalWin :: Board -> Player -> Bool
horizontalWin bd p =
    let numCols = length bd
        numRows = case bd of
                [] -> 0
                (firstCol:_) -> length firstCol
        -- Get row r from the board (with wraparound for checking)
        getRow r = concat $ replicate 2 [col !! r | col <- bd, length col > r]
    in any (\r -> hasConsecutive p 4 (getRow r)) [0..numRows-1]

-- Check for vertical win (with wrap-around)
verticalWin :: Board -> Player -> Bool
verticalWin bd p =
    let numCols = length bd
        numRows = case bd of
                [] -> 0
                (firstCol:_) -> length firstCol
        -- Get column c from the board (with wraparound for checking)
        getCol c = concat $ replicate 2 (bd !! (c `mod` numCols))
    in any (\c -> hasConsecutive p 4 (getCol c)) [0..numCols-1]

-- Check for diagonal win (top-left to bottom-right)
diagonalWin1 :: Board -> Player -> Bool
diagonalWin1 bd p =
    let numCols = length bd
        numRows = case bd of
                [] -> 0
                (firstCol:_) -> length firstCol
        -- For each starting position, check for diagonal
        startPositions = [(r, c) | r <- [0..numRows-1], c <- [0..numCols-1]]
    in any (checkDiagonal1 bd p numCols numRows) startPositions

-- Check diagonal from a given starting position (top-left to bottom-right)
checkDiagonal1 :: Board -> Player -> Int -> Int -> (Int, Int) -> Bool
checkDiagonal1 bd p numCols numRows (startRow, startCol) =
    let diagonal = [getCell bd ((startRow + i) `mod` numRows) ((startCol + i) `mod` numCols) | i <- [0..3]]
    in all (== p) diagonal

-- Check for diagonal win (top-right to bottom-left)
diagonalWin2 :: Board -> Player -> Bool
diagonalWin2 bd p =
    let numCols = length bd
        numRows = case bd of
                [] -> 0
                (firstCol:_) -> length firstCol
        -- For each starting position, check for diagonal
        startPositions = [(r, c) | r <- [0..numRows-1], c <- [0..numCols-1]]
    in any (checkDiagonal2 bd p numCols numRows) startPositions

-- Check diagonal from a given starting position (top-right to bottom-left)
checkDiagonal2 :: Board -> Player -> Int -> Int -> (Int, Int) -> Bool
checkDiagonal2 bd p numCols numRows (startRow, startCol) =
    let diagonal = [getCell bd ((startRow + i) `mod` numRows) ((startCol - i + numCols) `mod` numCols) | i <- [0..3]]
    in all (== p) diagonal

-- Helper function to get a cell value with proper wraparound
getCell :: Board -> Int -> Int -> Player
getCell bd row col = 
    let numCols = length bd
        safeCol = col `mod` numCols
        column = bd !! safeCol
        numRows = length column
        safeRow = row `mod` numRows
    in column !! safeRow

-- Check if a list has n consecutive occurrences of a value
hasConsecutive :: Eq a => a -> Int -> [a] -> Bool
hasConsecutive _ 0 _ = True
hasConsecutive _ _ [] = False
hasConsecutive val n lst@(x:xs)
    | length lst < n = False
    | all (== val) (take n lst) = True
    | otherwise = hasConsecutive val n xs

-- Convert board to string for display
boardToStr :: (Player -> Char) -> Board -> String
boardToStr playerToChar bd =
    let numCols = length bd
        numRows = case bd of
                [] -> 0
                (firstCol:_) -> length firstCol
        rows = [[getCell bd r c | c <- [0..numCols-1]] | r <- [numRows-1,numRows-2..0]]
    in unlines [unwords [playerToChar (row !! c) : "" | c <- [0..numCols-1]] | row <- rows]