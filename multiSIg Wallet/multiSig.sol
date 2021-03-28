pragma solidity 0.7.5;

contract multiSig {
    // CONTRACT DATA STRUCTURES DEFINITION
    event depositDone(uint amount, address indexed depositedFrom);
    struct TransferObject {
        address destinationAddress;
        uint amount;
        uint approvals;   
    }
    
    // MODIFIERS
        modifier balanceCheck(uint _amount) {
            require(_amount > CONTRACT_BALANCE[address(this)], "Insufficient funds");
            _;
        }
        
    // STORAGE VALUES
    address[] private OWNERS;
    uint private REQUIRED_APPROVALS;
    mapping(address => uint) private CONTRACT_BALANCE;
    TransferObject [] PERDING_TRANSFERS;
    
    // CREATE FUNCTION TO KEEP UNIQUE VALUES IN OWNERS
    constructor(address[] memory _owners, uint _approvals){
        require(_owners.length >= _approvals, "The number of required approvals is more than the number of owners");
        require(_owners.length >= 0, "At leas one owner is required");
        require(_approvals >= 0, "At least one approver is required");
        
        OWNERS= _owners;
        OWNERS.push(msg.sender);
        
        REQUIRED_APPROVALS = _approvals;
        CONTRACT_BALANCE[address(this)] = 0;
        
    }

    function withdraw(uint amount, address payable to) private balanceCheck(amount){
        CONTRACT_BALANCE[address(this)] -= amount;
        to.transfer(amount);
    }
    
    function getOwners() public view returns(address[] memory){
        return OWNERS;
    }
    
    function getApprovals() public view returns(uint){
        return REQUIRED_APPROVALS;
    }
    
    function getContractBalance() public view  returns(uint){
        return CONTRACT_BALANCE[address(this)];
    }
    
    function deposit() public payable returns(uint){
        CONTRACT_BALANCE[address(this)] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return CONTRACT_BALANCE[address(this)];
    }
    
    function createTransferRequest(address payable _destinationAddress, uint amamamount) public balanceCheck(amamamount){
        
        if (REQUIRED_APPROVALS == 1){
            withdraw(amamamount, _destinationAddress);
        }
        
        else{
            TransferObject memory newTransfer = TransferObject(_destinationAddress, amamamount, 1);
            PERDING_TRANSFERS.push(newTransfer);
        }
    }
    
}
