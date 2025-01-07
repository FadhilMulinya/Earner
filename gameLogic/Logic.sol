// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract EarnerGameLogic{
    enum gameState{active,ended}

    struct gameStruct{
        address payable player1;
        address payable player2;
        uint256 amount;
        gameState state;
        address payable winner;
        uint256 gameId;
    }
    address payable  treasury;

    constructor(address payable _treasury){
        require(_treasury != address(0), "Invalid treasury address");
        treasury = _treasury;
    }

    event startedGame(address indexed player1, address indexed player2,uint256 gameId, uint256 amount, address winner);
    event joinedGame(address indexed player2, uint256 gameId);
    event stoppedGame(address indexed  player, uint256 gameID );
    event withdrawFunds(address winner, uint256 amount);

    mapping(uint256 => gameStruct) private game;

    uint256 gamesCount;

    function startRandomGame(uint256 _amount, uint256 _gameId) public returns (uint256){
        require(_amount > 0 && _gameId > 0, "Amount should be greater than Zero");
        require(game[_gameId].gameId == 0, "The game Id already exists");
        game[_gameId] = gameStruct({
            player1 : payable (msg.sender),
            player2 : payable (address(0)),
            amount : _amount,
            gameId : _gameId,
            state: gameState.active,
            winner: payable(address(0))
        });
        gamesCount++;
        emit startedGame(msg.sender,address(0),_gameId,_amount, address(0));
        return _gameId;
    }

    function startInvitedGame(uint256 _amount, address _opponent, uint256 _gameId) public returns (uint256){
        require(_amount > 0 && _gameId > 0, "Amount should be greater than Zero");
        require(game[_gameId].gameId == 0, "The game Id already exists");
        game[_gameId] = gameStruct({
            player1 : payable (msg.sender),
            player2 : payable (_opponent),
            amount : _amount,
            gameId : _gameId,
            state: gameState.active,
            winner: payable(address(0))
        });
        gamesCount++;
        emit startedGame(msg.sender,_opponent,_gameId,_amount, address(0));
        return _gameId;
    }


    function joinRandomnGame(uint256 _gameId) public payable  returns(string memory) {
        require(_gameId > 0,"Game Id cant be Zero");
        require(msg.value == game[_gameId].amount , "Incorrect Amount Sent");
        require(game[_gameId].gameId == _gameId, "Invalid Game Id");
        require(game[_gameId].player2 == address(0), "Already Joined Game");
        require(game[_gameId].state == gameState.active, "Game is not Active");

        game[_gameId].player2 = payable(msg.sender);

        emit joinedGame(msg.sender, _gameId);

        return "Player Joined Successfully";
    }
    function joinInvitedGame(uint256 _gameId) public payable  returns(string memory) {
        require(_gameId > 0,"Game Id cant be Zero");
        require(msg.value == game[_gameId].amount , "Incorrect Amount Sent");
        require(game[_gameId].gameId == _gameId, "Invalid Game Id");
        require(game[_gameId].player2 == msg.sender, "You are not invited in this game");
        require(game[_gameId].state == gameState.active, "Game is not Active");

        emit joinedGame(msg.sender, _gameId);
        return "Success";
    }
    function stopGame(uint256 _gameId) public payable returns (string memory){
        require(game[_gameId].gameId == _gameId, "Invalid game Id");
        require(game[_gameId].player1 == msg.sender || game[_gameId].player2 == msg.sender, "You are not a player in this game");
        require(game[_gameId].state == gameState.active, "Game is already stopped");

        uint256 pool = game[_gameId].amount;
        uint256 fees = (5 *pool)/ 100;

        require(treasury != address(0), "Invalid treasury address");
        treasury.transfer(fees);
        
        game[_gameId].state = gameState.ended;

         uint256 poolAfterFees = pool - fees;
        uint256 refundAmountPlayer1 = poolAfterFees / 2;
        uint256 refundAmountPlayer2 = poolAfterFees - refundAmountPlayer1;
        game[_gameId].player1.transfer(refundAmountPlayer1);
        game[_gameId].player2.transfer(refundAmountPlayer2);

        emit stoppedGame(msg.sender, _gameId);
        return "Game stopped successfully, funds refunded to both players";
    }

    function getWinner(uint256 _gameId)public view returns(address){
        return game[_gameId].winner;
    }

    function withdraw(uint256 _gameId) public returns (string memory){
        require (game[_gameId].winner == msg.sender, "You are not the winner");
        require(game[_gameId].state == gameState.ended, "The game is still active");

        uint256 pool = game[_gameId].amount;

        uint256 fees = ( 5 * pool) / 100;

        
        uint256 winnerAmount = pool - fees ;

        require(treasury != address(0), "Invalid treasury address");
        treasury.transfer(fees);


            game[_gameId].winner.transfer(winnerAmount);
        


        emit withdrawFunds(game[_gameId].winner, winnerAmount);

        return "Successfully withdrew amount";
    }

}
