// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    event Stake(address indexed staker, uint256 amount);

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool public openForWithdraw = false;

    mapping(address => uint256) public balances;

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        require(block.timestamp > deadline, "Deadline has not passed");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public payable {
        require(openForWithdraw, "Withdraw not open");
        require(balances[msg.sender] > 0, "No ether staked");
        payable(msg.sender).transfer(balances[msg.sender]);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
}
