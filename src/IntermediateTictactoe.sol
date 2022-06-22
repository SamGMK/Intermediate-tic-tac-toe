
 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract IntermediateTictactoe {


//stores the board positions. index 0 corresponds to the first square in the 3 by 3 board etc
uint8[9] public boardPositions;

//stores the possible states of the board except empty
enum AllowedPlays{EMPTY, X, O}

//addresses of the two player
address immutable public playerOne;
address immutable public playerTwo;

//Stores number of plays per player to ensure turns
mapping(address => uint8) public _numberOfPlays;

//stores a bool for if the board position is occupied or not(i.e 1 equals move made, 0 equals move is valid)
//mapping(uint8 => uint8) public _isPositionOccupied;

//Ensures first player is playerOne 
uint8 public makeMoveCounter = 0;

constructor(address _playerOne, address _playerTwo) payable {
    playerOne = _playerOne;
    playerTwo = _playerTwo;

    //sets all the boardPositions to empty at compile time. 
    //this also saves on gas as it is cheaper to write to an existing storage slot
    //than a new one
    AllowedPlays empty = AllowedPlays.EMPTY;
    uint8 emptyInt = uint8(empty);
    boardPositions = [emptyInt,emptyInt,emptyInt,emptyInt,emptyInt,emptyInt,emptyInt,emptyInt,emptyInt];
    
    
    
}

/// @notice called when a player wants to make a move
/// @dev Fallback function is used instead of a regular function to save on gas.
///This is because the Fallback function doesn't require a function signature to call.
/// @param _data The move the player has made i.e index for the boardPosition
/// @return returns bool to show if the move was successful or not
fallback(bytes calldata _data)external returns(bytes memory ) {
  //perform all the required checks before state changes
    require(checkTurn(msg.sender) == true, "Not your turn");
    onlyPlayer(msg.sender);
    onlyPlayerOneStarts();
    (uint8 _move) = abi.decode(_data, (uint8));
    onlyEmptyPosition(_move);
    makeMoveCounter++;

    //assigning its value depending on user
    //If playerOne then assign X. If playerTwo then assing O.
    if(msg.sender == playerOne) {
        boardPositions[_move] = uint8(AllowedPlays.X);
        _numberOfPlays[playerOne]++;

        if(checkWinner() == uint8(AllowedPlays.X)) {
            selfdestruct(payable(playerOne));
            }

    } else{
        boardPositions[_move] = uint8(AllowedPlays.O);
        _numberOfPlays[playerTwo]++;
        if(checkWinner() == uint8(AllowedPlays.O)) {
            selfdestruct(payable(playerTwo));
            }

    }

    
}



/// @notice Checks if any player has made three similar moves that result in a win
/// @dev checks if the first position in a winning combination is empty, then checks
/// if that position matches the other two in the winning combination. eg 0,1,2 check if 0 is empty,
/// if not then match it with 1 and 2. If all three are similar then return state of position 0.
/// @return The sign(state) of the winning combination i.e X or O.
function checkWinner()internal view returns(uint8) {
//if a winner is found, then self destruct and print Game Over
     uint8[9] memory _boardPositions = boardPositions; //gas saving

    if(_boardPositions[0] != uint8(AllowedPlays.EMPTY) && _boardPositions[0] == _boardPositions[1] && _boardPositions[0] == _boardPositions[2]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[3] != uint8(AllowedPlays.EMPTY) && _boardPositions[3] == _boardPositions[4] && _boardPositions[3] == _boardPositions[5]) {
        return _boardPositions[3];
      } 
    if(_boardPositions[6] != uint8(AllowedPlays.EMPTY) && _boardPositions[6] == _boardPositions[7] && _boardPositions[6] == _boardPositions[8]) {
        return _boardPositions[6];
      } 
    if(_boardPositions[0] != uint8(AllowedPlays.EMPTY) && _boardPositions[0] == _boardPositions[3] && _boardPositions[0] == _boardPositions[6]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[1] != uint8(AllowedPlays.EMPTY) && _boardPositions[1] == _boardPositions[4] && _boardPositions[1] == _boardPositions[7]) {
        return _boardPositions[1];
      } 
    if(_boardPositions[2] != uint8(AllowedPlays.EMPTY) && _boardPositions[2] == _boardPositions[5] && _boardPositions[2] == _boardPositions[8]) {
        return _boardPositions[2];
      } 
    if(_boardPositions[0] != uint8(AllowedPlays.EMPTY) && _boardPositions[0] == _boardPositions[4] && _boardPositions[0] == _boardPositions[8]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[2] != uint8(AllowedPlays.EMPTY) && _boardPositions[2] == _boardPositions[4] && _boardPositions[2] == _boardPositions[6]) {
        return _boardPositions[2];
      } 
    
}

//@Notice All the below functions could have been modifiers instead functions were used. This is because 
//when using modifiers, the code of the modifiers is inserted at the start of the function at compile time, 
//which can massively ballon code size.

/// @notice Checks if the _caller is a registered player
/// @dev function was used instead of a modifier to save on gas
/// @param _caller is the address that wants to make the move
function onlyPlayer(address _caller) internal view {
   require(_caller == playerOne || _caller == playerTwo, "Not Player");
}


/// @notice Ensures that the first player to make move is player One
/// @dev This is to help the check turn functionality
function onlyPlayerOneStarts() internal view {
    if(makeMoveCounter == 0){
         require(msg.sender == playerOne, "Not Player One");
    }
}


/// @notice Ensures only an empty position can be played
/// @param _move is the index of the board positions
function onlyEmptyPosition(uint8 _move) internal view {
    require(boardPositions[_move] == uint8(AllowedPlays.EMPTY), "Move not Valid");
}


/// @notice Checks if it is a players turn to play
/// @dev if player one plays(1 move) then he can only play is player two has also played(1 move)
/// @param _nextMovePlayer a parameter just like in doxygen (must be followed by parameter name)
/// @return true if it is the player's turn else false.
function checkTurn(address _nextMovePlayer) internal view returns(bool) {
    if (playerOne == _nextMovePlayer && _numberOfPlays[_nextMovePlayer] == _numberOfPlays[playerTwo]) {
         return true;
       } else if (playerTwo == _nextMovePlayer && _numberOfPlays[_nextMovePlayer] < _numberOfPlays[playerOne]) {
         return true;
       } 
       else{return false;}

}



}