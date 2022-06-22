
 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract IntermediateTictactow {

//stores the board positions. 1 corresponds to the first square in the 3 by 3 board,
//2 corresponds to the seconds square in the 3 by 3 board etc.
uint8[9] public boardPositions;
//ADD A STRCUT TO PACK boardPositions and bool for isPositionOccupied
//Ensures first player is playerOne 
uint8 public makeMoveCounter = 0;

    

address immutable public playerOne;
address immutable public playerTwo;

enum AllowedPlays{Empty, X, O}

//Stores number of plays per player to ensure turns
//NBBB: FIND A WAY TO UPDATE THIS MAPPING AFTER EVERY PLAY
mapping(address => uint8) public _numberOfPlays;
//stores the number if the position for if the move has been made or not(i.e 1 equals move made, 0 equals move is valid)
//Remove this mapping and add a bool in a struct
mapping(uint8 => uint8) public _isPositionOccupied;

//stores the possible win combos


constructor(address _playerOne, address _playerTwo) payable {
    playerOne = _playerOne;
    playerTwo = _playerTwo;
    
}


fallback(bytes calldata _data)external returns(bytes memory ) {
    require(checkTurn(msg.sender) == true, "Not your turn");
    onlyPlayer(msg.sender);
    onlyPlayerOneStarts();
    (uint8 _move) = abi.decode(_data, (uint8));
    onlyEmptyPosition(_move);
    makeMoveCounter++;

    //update the position to occupied 
    _isPositionOccupied[_move] = 1;

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
function onlyPlayer(address _caller) internal view {
   require(_caller == playerOne || _caller == playerTwo, "Not Player");
}

function onlyPlayerOneStarts() internal view {
    if(makeMoveCounter == 0){
         require(msg.sender == playerOne, "Not Player One");
    }
}

function onlyEmptyPosition(uint8 _move) internal view {
    require(_isPositionOccupied[_move] == 0, "Move not Valid");
}

function checkTurn(address _nextMovePlayer) internal view returns(bool) {
    if (playerOne == _nextMovePlayer && _numberOfPlays[_nextMovePlayer] == _numberOfPlays[playerTwo]) {
         return true;
       } else if (playerTwo == _nextMovePlayer && _numberOfPlays[_nextMovePlayer] < _numberOfPlays[playerOne]) {
         return true;
       } 
       else{return false;}

}

function checkWinner()internal view returns(uint8) {
//if a winner is found, then self destruct and print Game Over
     uint8[9] memory _boardPositions = boardPositions; //gas saving

    if(_boardPositions[0] == _boardPositions[1] && _boardPositions[0] == _boardPositions[2]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[3] == _boardPositions[4] && _boardPositions[3] == _boardPositions[5]) {
        return _boardPositions[3];
      } 
    if(_boardPositions[6] == _boardPositions[7] && _boardPositions[6] == _boardPositions[8]) {
        return _boardPositions[6];
      } 
    if(_boardPositions[0] == _boardPositions[3] && _boardPositions[0] == _boardPositions[6]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[1] == _boardPositions[4] && _boardPositions[1] == _boardPositions[7]) {
        return _boardPositions[1];
      } 
    if(_boardPositions[2] == _boardPositions[5] && _boardPositions[2] == _boardPositions[8]) {
        return _boardPositions[2];
      } 
    if(_boardPositions[0] == _boardPositions[4] && _boardPositions[0] == _boardPositions[8]) {
        return _boardPositions[0];
      } 
    if(_boardPositions[2] == _boardPositions[4] && _boardPositions[2] == _boardPositions[6]) {
        return _boardPositions[2];
      } 
    
}


}