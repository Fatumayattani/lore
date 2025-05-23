// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LoreStory {
    address public owner;
    uint256 public lineFee; // Fee in AVAX to add a story line
    string[] public storyLines;

    event LineAdded(address indexed author, string line, uint256 index);

    constructor(uint256 _lineFeeInWei) {
        owner = msg.sender;
        lineFee = _lineFeeInWei;
    }

    function addLine(string memory _line) external payable {
        require(msg.value >= lineFee, "Insufficient fee to add a line");

        storyLines.push(_line);
        emit LineAdded(msg.sender, _line, storyLines.length - 1);
    }

    function getLine(uint256 index) external view returns (string memory) {
        require(index < storyLines.length, "Invalid index");
        return storyLines[index];
    }

    function totalLines() external view returns (uint256) {
        return storyLines.length;
    }

    // Owner can withdraw collected AVAX
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Allow the owner to update fee
    function setLineFee(uint256 _newFee) external {
        require(msg.sender == owner, "Only owner can set fee");
        lineFee = _newFee;
    }

    // Fallback in case AVAX is sent directly
    receive() external payable {}
}
