# Connect4-Haskell

A complete Connect 4 game implementation in Haskell featuring both human vs human and human vs computer gameplay modes. This project demonstrates functional programming principles, immutable data structures, pure functions, and AI strategy implementation.

## Features

### Game Modes
- **Human vs Human**: Two-player local gameplay
- **Human vs Computer**: Single-player with AI opponent
- **Interactive Console Interface**: Clean command-line user interaction
- **Input Validation**: Robust error handling and user guidance

### Core Functionality
- **Pure Functional Implementation**: Immutable game state and pure functions
- **Pattern Matching**: Extensive use of Haskell's pattern matching for game logic
- **Type Safety**: Strong static typing preventing runtime errors
- **Recursive Algorithms**: Elegant recursive solutions for game mechanics
- **Higher-Order Functions**: Map, filter, fold operations for data manipulation
- **AI Strategy**: Computer opponent with winning move detection and blocking logic

### Game Features
- **Classic Connect 4**: 7x6 grid with gravity-based token dropping
- **Comprehensive Win Detection**: Horizontal, vertical, and diagonal win checking with wrap-around support
- **Full Board Detection**: Automatic draw detection when board is full
- **Smart AI**: Computer opponent that tries to win and blocks player wins
- **Visual Board Display**: Clear text-based board representation

## Technologies Used

### Language & Compiler
- **Haskell**: Pure functional programming language
- **GHC**: Glasgow Haskell Compiler for compilation
- **Modular Design**: Separated Board logic and Main game loop

### Programming Paradigms
- **Functional Programming**: Pure functions and immutable data
- **Algebraic Data Types**: Custom types for game representation
- **Pattern Matching**: Exhaustive case analysis
- **Recursion**: Primary control flow mechanism
- **Module System**: Clean separation of concerns

## Project Structure

```
connect4-haskell/
├── Main.hs               # Main program entry point and game logic
├── Board.hs              # Board data structure and game mechanics
├── Main.hi               # Compiled interface file (excluded from git)
├── Main.o                # Compiled object file (excluded from git)
├── Board.hi              # Compiled interface file (excluded from git)
├── Board.o               # Compiled object file (excluded from git)
├── connect_four          # Compiled executable (excluded from git)
└── README.md             # Project documentation
```

## Getting Started

### Prerequisites
- **GHC (Glasgow Haskell Compiler) 8.10.0 or higher**
- **Cabal** (optional, for build management)

### Installation

#### Install Haskell Platform
```bash
# macOS with Homebrew
brew install haskell-platform

# Ubuntu/Debian
sudo apt-get install haskell-platform

# Windows
# Download from https://www.haskell.org/platform/

# Or use GHCup (Recommended)
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

### Compilation and Execution

1. **Clone the repository:**
```bash
git clone https://github.com/Enrique182004/Connect4-Haskell.git
cd Connect4-Haskell
```

2. **Compile the project:**
```bash
# Compile with GHC
ghc --make Main.hs -o connect_four

# Run the game
./connect_four
```

3. **Alternative compilation:**
```bash
# Compile individual modules
ghc -c Board.hs
ghc -c Main.hs
ghc Board.o Main.o -o connect_four
```

## Usage

### Starting the Game
```bash
./connect_four
```

### Game Selection
```
Welcome to Connect Four!
Choose game mode:
1. Human vs Human
2. Human vs Computer

Enter your choice: 2
Player 1: O    Player 2: X
```

### Gameplay Example
```
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .

Player 1 (O), choose a column (1-7): 4

. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . O . . .

Computer is thinking...
Computer chooses column 3

. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . X O . . .
```

## Code Architecture

### Data Types
```haskell
-- Core data structures
type Board = [[Player]]  -- Board as list of columns
type Player = Int        -- Players as integers (0=empty, 1=player1, 2=player2)

-- Key constants
mkPlayer :: Player       -- Player 1 (O)
mkOpponent :: Player     -- Player 2 (X)
```

### Core Functions

#### Board Management
```haskell
mkBoard :: Int -> Int -> Board           -- Create empty m×n board
dropInSlot :: Board -> Int -> Player -> Board  -- Drop piece in column
isSlotOpen :: Board -> Int -> Bool       -- Check if column available
isFull :: Board -> Bool                  -- Check if board full
boardToStr :: (Player -> Char) -> Board -> String  -- Display board
```

#### Game Logic
```haskell
isWonBy :: Board -> Player -> Bool       -- Check if player won
horizontalWin :: Board -> Player -> Bool -- Check horizontal wins
verticalWin :: Board -> Player -> Bool   -- Check vertical wins
diagonalWin1 :: Board -> Player -> Bool  -- Check diagonal wins (\)
diagonalWin2 :: Board -> Player -> Bool  -- Check diagonal wins (/)
```

#### AI Strategy
```haskell
getComputerMove :: Board -> Player -> Int      -- Get AI move
findWinningMove :: Board -> Player -> Maybe Int -- Find winning move
findFirstOpenSlot :: Board -> Int -> Int       -- Find available column
```

### Key Haskell Features Demonstrated

#### Pattern Matching
```haskell
playerToChar :: Player -> Char
playerToChar 0 = '.'  -- Empty space
playerToChar 1 = 'O'  -- Player 1
playerToChar 2 = 'X'  -- Player 2
playerToChar _ = '?'  -- Invalid player
```

#### Higher-Order Functions
```haskell
-- Check if board is full using any and elem
isFull :: Board -> Bool
isFull bd = not (any (elem 0) bd)

-- Check for consecutive elements
hasConsecutive :: Eq a => a -> Int -> [a] -> Bool
hasConsecutive val n lst = all (== val) (take n lst)
```

#### Recursion and List Processing
```haskell
-- Drop piece in column (gravity simulation)
dropInColumn :: [Player] -> Player -> [Player]
dropInColumn col p = 
    let emptyIndices = [i | (i, v) <- zip [0..] col, v == 0]
    in if null emptyIndices
       then col  -- Column full
       else let firstEmptyIndex = minimum emptyIndices
            in take firstEmptyIndex col ++ [p] ++ drop (firstEmptyIndex + 1) col
```

## AI Strategy Implementation

The computer opponent implements a strategic decision tree:

1. **Offensive Play**: Look for immediate winning moves
2. **Defensive Play**: Block opponent's winning moves  
3. **Strategic Play**: Prefer center column when available
4. **Fallback**: Choose first available column

```haskell
getComputerMove :: Board -> Player -> Int
getComputerMove bd p =
    case findWinningMove bd p of
        Just col -> col  -- Win if possible
        Nothing -> 
            let opponent = if p == mkPlayer then mkOpponent else mkPlayer
            in case findWinningMove bd opponent of
                Just col -> col  -- Block opponent win
                Nothing -> 
                    let center = (numSlot bd + 1) `div` 2
                    in if isSlotOpen bd center
                       then center  -- Prefer center
                       else findFirstOpenSlot bd 1  -- First available
```

## Functional Programming Concepts

### Immutability
- All game state changes create new board instances
- No mutable variables or state modifications
- Functional approach to game state management

### Pure Functions
- Deterministic output for identical input
- No side effects in game logic functions
- Easier testing and mathematical reasoning

### Type Safety
- Compile-time prevention of runtime errors
- Exhaustive pattern matching ensures all cases handled
- Strong static typing eliminates common bugs

### Modular Design
- Separation of Board logic from Main game flow
- Clean interfaces between modules
- Reusable components for different game variants

## Development

### Building from Source
```bash
# Clean previous builds
rm -f *.hi *.o connect_four

# Rebuild everything
ghc --make Main.hs -o connect_four
```

### Interactive Development
```bash
# Load in GHCi for testing
ghci Main.hs

# Test individual functions
*Main> let board = mkBoard 7 6
*Main> dropInSlot board 3 mkPlayer
*Main> isWonBy (dropInSlot board 3 mkPlayer) mkPlayer
```

## Educational Value

This implementation demonstrates several important functional programming concepts:

### Advanced Haskell Features
- **Module System**: Clean separation of Board and Main modules
- **Type Aliases**: Clear, readable type definitions
- **List Comprehensions**: Elegant data processing
- **Maybe Types**: Safe handling of optional values
- **Recursive Data Processing**: Functional approach to algorithms

### Game Programming Patterns
- **Immutable Game State**: Functional state management
- **Strategy Pattern**: AI decision making
- **Input Validation**: Robust user interaction
- **Game Loop**: Functional approach to turn-based games

## Future Enhancements

- **Advanced AI**: Minimax algorithm with alpha-beta pruning
- **Difficulty Levels**: Multiple AI strategies
- **Game History**: Move recording and playback
- **Network Play**: Multi-computer gameplay
- **GUI Interface**: Graphical user interface
- **Tournament Mode**: Multiple game sessions

## License

This project was developed by Enrique Calleros. All rights reserved.
