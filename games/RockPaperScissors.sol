// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "../libraries/addressToString.sol";
import "../libraries/lowerCase.sol";
import "../gameLogic/Logic.sol";


contract RPS is EarnerGameLogic {

    using addressToString for string;
    using lowerCase for string;

    enum userChoice { Rock, Paper, Scissors }

    mapping(uint256 => mapping(address => uint256)) private playerChoices; // Stores player choices by game ID

    constructor(address payable _treasury) EarnerGameLogic(_treasury) {}

    // Start a new random game (overrides the EarnerGameLogic startRandomGame)
    function startRandomGame(string memory _choice, uint256 _amount, uint256 _gameId) public returns (uint256) {
        uint256 gameId = EarnerGameLogic.startRandomGame(_amount, _gameId);
        _setPlayerChoice(gameId, _choice);
        return gameId;
    }

    // Join an existing random game
    function joinRandomnGame(string memory _choice, uint256 _gameId) public payable returns (string memory) {
        string memory result = EarnerGameLogic.joinRandomnGame(_gameId);
        _setPlayerChoice(_gameId, _choice);
        return result;
    }

    // Set the player's choice
    function _setPlayerChoice(uint256 _gameId, string memory _choice) internal {
        _choice = _choice.toLowerCase();
        require(
            keccak256(bytes(_choice)) == keccak256(bytes("rock")) ||
            keccak256(bytes(_choice)) == keccak256(bytes("paper")) ||
            keccak256(bytes(_choice)) == keccak256(bytes("scissors")),
            "Please choose: rock, paper, or scissors"
        );

        uint256 choiceValue;
        if (keccak256(bytes(_choice)) == keccak256(bytes("rock"))) {
            choiceValue = uint256(userChoice.Rock);
        } else if (keccak256(bytes(_choice)) == keccak256(bytes("paper"))) {
            choiceValue = uint256(userChoice.Paper);
        } else {
            choiceValue = uint256(userChoice.Scissors);
        }

        playerChoices[_gameId][msg.sender] = choiceValue;
    }

    // Determine the winner and update the game state
    function determineWinner(uint256 _gameId) public returns (string memory) {
        require(game[_gameId].state == gameState.active, "Game is not active");
        require(game[_gameId].player1 != address(0) && game[_gameId].player2 != address(0), "Both players must join");

        uint256 player1Choice = playerChoices[_gameId][game[_gameId].player1];
        uint256 player2Choice = playerChoices[_gameId][game[_gameId].player2];

        // If choices are the same, it's a draw
        if (player1Choice == player2Choice) {
            game[_gameId].state = gameState.ended;
            emit stoppedGame(msg.sender, _gameId);
            return "It's a draw! No winner.";
        }

        address payable winner;
        if (
            (player1Choice == uint256(userChoice.Rock) && player2Choice == uint256(userChoice.Scissors)) ||
            (player1Choice == uint256(userChoice.Paper) && player2Choice == uint256(userChoice.Rock)) ||
            (player1Choice == uint256(userChoice.Scissors) && player2Choice == uint256(userChoice.Paper))
        ) {
            winner = game[_gameId].player1;
        } else {
            winner = game[_gameId].player2;
        }

        game[_gameId].winner = winner;
        game[_gameId].state = gameState.ended;

        emit stoppedGame(msg.sender, _gameId);
        return string(abi.encodePacked("The winner is ", externalFunctions._addressToString(winner)));
    }

}
