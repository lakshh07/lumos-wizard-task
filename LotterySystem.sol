// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract LotterySystem{

    address public manager;
    uint256 public minimumPlayers;
    uint256 public ticketPrice;
    uint256 public minimumTicketSupply;
    uint256 public ticketSaleEndTime;
    uint256 public winnerAnnouncementTime;
    uint256 public minimumBalance;
    uint256 public bank;
    bool public isRunning;
    address public winner;

    address[] public players;

    mapping(address => bool) public hasPurchasedTicket;

    event NewPlayer(address indexed player, uint256 balance);
    event Winner(address indexed winner, uint256 bank);

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    constructor(
        uint256 _ticketPrice,
        uint256 _minimumPlayers,
        uint256 _ticketSaleDuration,
        uint256 _winnerAnnouncementDuration,
        uint256 _minimumBalance,
        uint256 _minimumTicketSupply 
    ) {
        require(_minimumPlayers > 0, "Minimum players must be greater than zero");
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        require(_minimumBalance >= _ticketPrice, "Minimum balance must be greater than or equal to ticket price");
        require(_minimumTicketSupply >= _minimumPlayers, "Minimum ticket supply must be greater than or equal to minimum players");

        manager = msg.sender;
        ticketPrice = _ticketPrice;
        minimumPlayers = _minimumPlayers;
        ticketSaleEndTime = block.timestamp + _ticketSaleDuration;
        winnerAnnouncementTime = ticketSaleEndTime + _winnerAnnouncementDuration;
        minimumBalance = _minimumBalance;
        minimumTicketSupply = _minimumTicketSupply;
        isRunning = true;
    }

    function butTicket() external payable{
        require(isRunning, "Lotter is not currently running");
        require(block.timestamp <= ticketSaleEndTime, "Ticket sales have ended");
        require(msg.value >= ticketPrice, "Not enough ether to purchase ticket");
        require(!hasPurchasedTicket[msg.sender], "You have already purchased ticket");

        players.push(msg.sender);
        hasPurchasedTicket[msg.sender] = true;
        bank += msg.value;

        emit NewPlayer(msg.sender, address(this).balance);
    }

    function pickWinner() external restricted {
        require(isRunning, "Lottery is not currently running");
        require(block.timestamp >= winnerAnnouncementTime, "Winner has not been announced yet");
        require(players.length >= minimumPlayers, "Not enough players to pick winner");
        require(address(this).balance >= minimumBalance, "Not enough ether to pick a winner");
        require(winner == address(0), "Winner has already been picked");

        uint256 winnerIndex = generateRandomIndex();

        winner = players[winnerIndex];
        payable(winner).transfer(address(this).balance);

        isRunning = false;

        emit Winner(winner, address(this).balance);
    }

    function generateRandomIndex() private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
        return seed % players.length;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function withdraw(uint256 amount) public restricted {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(manager).transfer(amount);
    }
}