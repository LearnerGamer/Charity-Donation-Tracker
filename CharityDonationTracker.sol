// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CharityDonationTracker
 * @dev A charity donation platform that tracks donations and allows withdrawal by verified charity
 * @author Vedant Vijay Harane
 * @notice Registration Number: 24BCC7028
 */
contract CharityDonationTracker {
    // Student Information
    string public constant STUDENT_NAME = "Vedant Vijay Harane";
    string public constant REGISTRATION_NUMBER = "24BCC7028";
    
    // Contract state variables
    address public charityAddress;
    address public owner;
    uint256 public totalDonations;
    uint256 public deploymentBlock;
    
    // Mapping to track individual donations
    mapping(address => uint256) public donations;
    
    // Array to keep track of all donors
    address[] public donors;
    mapping(address => bool) private isDonor;
    
    // Events
    event DonationReceived(address indexed donor, uint256 amount, uint256 blockNumber);
    event FundsWithdrawn(address indexed charity, uint256 amount, uint256 blockNumber);
    event CharityAddressUpdated(address indexed oldCharity, address indexed newCharity);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyCharity() {
        require(msg.sender == charityAddress, "Only charity can withdraw funds");
        _;
    }
    
    /**
     * @dev Constructor sets the charity address and records deployment block
     * @param _charityAddress The address that can withdraw donations
     */
    constructor(address _charityAddress) {
        require(_charityAddress != address(0), "Invalid charity address");
        owner = msg.sender;
        charityAddress = _charityAddress;
        deploymentBlock = block.number;
    }
    
    /**
     * @dev Receive function to accept ETH donations
     */
    receive() external payable {
        donate();
    }
    
    /**
     * @dev Fallback function to accept ETH donations
     */
    fallback() external payable {
        donate();
    }
    
    /**
     * @dev Function to donate ETH to the charity
     */
    function donate() public payable {
        require(msg.value > 0, "Donation must be greater than 0");
        
        // Update donor's total donation
        donations[msg.sender] += msg.value;
        
        // Add to donors array if first time donor
        if (!isDonor[msg.sender]) {
            donors.push(msg.sender);
            isDonor[msg.sender] = true;
        }
        
        // Update total donations
        totalDonations += msg.value;
        
        // Emit event
        emit DonationReceived(msg.sender, msg.value, block.number);
    }
    
    /**
     * @dev Withdraw all funds to charity address
     */
    function withdrawAll() external onlyCharity {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        emit FundsWithdrawn(charityAddress, balance, block.number);
        
        (bool success, ) = charityAddress.call{value: balance}("");
        require(success, "Transfer failed");
    }
    
    /**
     * @dev Withdraw specific amount to charity address
     * @param amount Amount to withdraw in wei
     */
    function withdraw(uint256 amount) external onlyCharity {
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient balance");
        
        emit FundsWithdrawn(charityAddress, amount, block.number);
        
        (bool success, ) = charityAddress.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    /**
     * @dev Update charity address (only owner)
     * @param _newCharityAddress New charity address
     */
    function updateCharityAddress(address _newCharityAddress) external onlyOwner {
        require(_newCharityAddress != address(0), "Invalid charity address");
        address oldCharity = charityAddress;
        charityAddress = _newCharityAddress;
        emit CharityAddressUpdated(oldCharity, _newCharityAddress);
    }
    
    /**
     * @dev Get contract balance
     * @return Current balance in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Get donation amount for specific address
     * @param donor Address of the donor
     * @return Donation amount in wei
     */
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }
    
    /**
     * @dev Get total number of donors
     * @return Number of unique donors
     */
    function getTotalDonors() external view returns (uint256) {
        return donors.length;
    }
    
    /**
     * @dev Get all donors
     * @return Array of donor addresses
     */
    function getAllDonors() external view returns (address[] memory) {
        return donors;
    }
    
    /**
     * @dev Get current block number
     * @return Current block number
     */
    function getCurrentBlock() external view returns (uint256) {
        return block.number;
    }
    
    /**
     * @dev Get student information
     * @return name Student name
     * @return regNo Registration number
     */
    function getStudentInfo() external pure returns (string memory name, string memory regNo) {
        return (STUDENT_NAME, REGISTRATION_NUMBER);
    }
}