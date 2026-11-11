// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelanceEscrow {
    enum State {
        Created,
        Funded,
        WorkSubmitted,
        Completed,
        Disputed
    }

    address public employer;
    address payable public freelancer;
    string public projectName;
    uint256 public amount;
    State public currentState;
    string public workHash;

    constructor(
        address payable _freelancer,
        string memory _projectName,
        uint256 _amount
    ) {
        employer = msg.sender;
        freelancer = _freelancer;
        projectName = _projectName;
        amount = _amount;
        currentState = State.Created;
    }

    function depositPayment() public payable {
        require(msg.sender == employer, "Only employer can deposit");
        require(currentState == State.Created, "Already funded");
        require(msg.value == amount, "Must deposit exact amount");

        currentState = State.Funded;
    }

    function submitWork(string memory _workHash) public {
        require(msg.sender == freelancer, "Only freelancer can submit");
        require(currentState == State.Funded, "Funds not deposited yet");

        workHash = _workHash;
        currentState = State.WorkSubmitted;
    }

    function approveAndRelease() public {
        require(msg.sender == employer, "Only employer can approve");
        require(currentState == State.WorkSubmitted, "Work not submitted yet");

        currentState = State.Completed;
        (bool success, ) = freelancer.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}