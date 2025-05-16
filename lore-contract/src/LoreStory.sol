// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title LoreStory
 * @dev A collaborative storytelling contract where users pay with LOR (native token)
 */
contract LoreStory is Ownable2Step {
    struct Line {
        address author;
        string text;
        uint256 timestamp;
    }

    Line[] public story;
    uint256 public submissionFee;
    uint256 public constant MAX_LINE_LENGTH = 280;
    uint256 public cooldownPeriod = 30 minutes;

    mapping(address => uint256) public lastSubmission;
    mapping(address => bool) public bannedUsers;

    event LineAdded(address indexed author, uint256 index, uint256 timestamp);
    event UserBanned(address indexed user, bool isBanned);
    event FeeUpdated(uint256 newFee);
    event CooldownUpdated(uint256 newCooldown);
    event FundsWithdrawn(address indexed to, uint256 amount);

    constructor(uint256 _initialFee) Ownable(msg.sender) {
        submissionFee = _initialFee;
    }

    /**
     * @notice Submit a new line to the story by paying LOR
     */
    function submitLine(string calldata _text) external payable {
        require(!bannedUsers[msg.sender], "Banned user");
        require(msg.value >= submissionFee, "Insufficient LOR");
        require(bytes(_text).length <= MAX_LINE_LENGTH, "Line too long");
        require(
            block.timestamp > lastSubmission[msg.sender] + cooldownPeriod,
            "Cooldown not passed"
        );

        story.push(Line(msg.sender, _text, block.timestamp));
        lastSubmission[msg.sender] = block.timestamp;

        emit LineAdded(msg.sender, story.length - 1, block.timestamp);
    }

    /**
     * @notice Returns the number of lines in the story
     */
    function getLineCount() external view returns (uint256) {
        return story.length;
    }

    /**
     * @notice Get a specific line
     */
    function getLine(uint256 index) external view returns (Line memory) {
        require(index < story.length, "Index out of bounds");
        return story[index];
    }

    /**
     * @notice Update the submission fee (owner only)
     */
    function setSubmissionFee(uint256 newFee) external onlyOwner {
        submissionFee = newFee;
        emit FeeUpdated(newFee);
    }

    /**
     * @notice Update the cooldown period (owner only)
     */
    function setCooldownPeriod(uint256 newPeriod) external onlyOwner {
        cooldownPeriod = newPeriod;
        emit CooldownUpdated(newPeriod);
    }

    /**
     * @notice Ban or unban a user (owner only)
     */
    function banUser(address user, bool banned) external onlyOwner {
        bannedUsers[user] = banned;
        emit UserBanned(user, banned);
    }

    /**
     * @notice Withdraw LOR collected from fees (owner only)
     */
    function withdraw(address payable to) external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Withdraw failed");
        emit FundsWithdrawn(to, amount);
    }
}
