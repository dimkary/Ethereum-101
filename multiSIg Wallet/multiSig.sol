pragma solidity 0.7.5;

contract multiSig {
    // CONTRACT DATA STRUCTURES DEFINITION
    event depositDone(uint amount, address indexed depositedFrom);
    event withdrawFail(uint amount, uint contractBalance);
    struct TransferObject {
        address destinationAddress;
        uint amount;
        uint approvals;   
    }
    
    // MODIFIERS
        modifier balanceCheck(uint _amount){
            require(_amount < CONTRACT_BALANCE[CONTRACT_ADDRESS], "Insufficient funds");
            _;
        }
        
        modifier checkOwners {
            require(OWNERS[msg.sender] == true, "Owners only are allowed");
            _;
        }
        
    // STORAGE VALUES

    address payable CONTRACT_ADDRESS;
    mapping(address => bool) private OWNERS;
    address [] private OWNERS_LIST;
    uint private REQUIRED_APPROVALS;
    mapping(address => uint) private CONTRACT_BALANCE;
    TransferObject [] PERDING_TRANSFERS;
    
    // CREATE FUNCTION TO KEEP UNIQUE VALUES IN OWNERS
    constructor(address[] memory _owners, uint _approvals){
        require(_owners.length >= _approvals, "The number of required approvals is more than the number of owners");
        require(_owners.length >= 0, "At leas one owner is required");
        require(_approvals >= 0, "At least one approver is required");
        
        for (uint i=0; i<_owners.length; i++) {
            OWNERS[_owners[i]] = true;
        }
        OWNERS[msg.sender] = true;
        
        OWNERS_LIST = _owners;
        OWNERS_LIST.push(msg.sender);
        REQUIRED_APPROVALS = _approvals;
        CONTRACT_ADDRESS = payable(address(this)) ;
        CONTRACT_BALANCE[CONTRACT_ADDRESS] = 0;
        

        
    }

    function withdraw (uint amount, address payable to) private balanceCheck(amount){
        CONTRACT_BALANCE[CONTRACT_ADDRESS] -= amount;
        to.transfer(amount);
    }
    
    function getOwners() public view returns(address[] memory){
        return OWNERS_LIST;
    }
    
    function getApprovals() public view returns(uint){
        return REQUIRED_APPROVALS;
    }
    
    function getContractBalance() public view  returns(uint){
        return CONTRACT_BALANCE[CONTRACT_ADDRESS];
    }
    
    function deposit() public payable returns(uint){
        CONTRACT_BALANCE[CONTRACT_ADDRESS] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return CONTRACT_BALANCE[CONTRACT_ADDRESS];
    }
    
    function createTransferRequest (address payable _destinationAddress, uint amamamount) public checkOwners balanceCheck(amamamount) payable{

        if (REQUIRED_APPROVALS == 1){
            withdraw(amamamount, _destinationAddress);
        }
        
        else{
            TransferObject memory newTransfer = TransferObject(_destinationAddress, amamamount, 1);
            PERDING_TRANSFERS.push(newTransfer);
        }
    }
    
}
