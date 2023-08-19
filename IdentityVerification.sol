pragma solidity ^0.8.0;

contract IdentityVerification {
    mapping(address => bool) public isVerified;
    mapping(address => string) public verifiedData;
    mapping(address => uint256) public verificationTimestamp;
    
    uint256 public verificationFee = 0.01 ether;
    address public owner;

    event IdentityVerified(address indexed user, string data);
    event VerificationFeeUpdated(uint256 newFee);

    modifier onlyVerified() {
        require(isVerified[msg.sender], "User is not verified");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    
    function setVerificationFee(uint256 fee) external onlyOwner {
        verificationFee = fee;
        emit VerificationFeeUpdated(fee);
    }
    
    function verifyIdentity(string memory data) external payable {
        require(msg.value >= verificationFee, "Insufficient fee");
        isVerified[msg.sender] = true;
        verifiedData[msg.sender] = data;
        verificationTimestamp[msg.sender] = block.timestamp;
        emit IdentityVerified(msg.sender, data);
    }

    function getUserData(address user) external view onlyVerified returns (string memory) {
        return verifiedData[user];
    }
    
    function withdrawFees() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    function updateIdentity(string memory newData) external onlyVerified {
        verifiedData[msg.sender] = newData;
    }
    
    function updateVerificationFee(uint256 newFee) external onlyOwner {
        verificationFee = newFee;
    }
    
    function revokeVerification() external onlyOwner {
        isVerified[msg.sender] = false;
        delete verifiedData[msg.sender];
        verificationTimestamp[msg.sender] = 0;
    }
}
