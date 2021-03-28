pragma solidity 0.7.5;
pragma abicoder v2;

contract multiSig {
    // CONTRACT DATA STRUCTURES DEFINITION
    event depositDone(uint amount, address indexed depositedFrom);
    event withdrawFail(uint amount, uint contractBalance);
    struct TransferObject {
        address payable destinationAddress;
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
        
        // makes sure that each transaction cannot be approved more than once from each owner
        modifier uniqueApproval(int index){
                address cur_owner = msg.sender;
                for  (uint i=0; i<OWNER_MAPPING[cur_owner].length; i++){
                    require(OWNER_MAPPING[cur_owner][i] != index, "Double verification error");
                }
            
            _;
        }
    // STORAGE VALUES

    address payable CONTRACT_ADDRESS;
    mapping(address => bool) private OWNERS;
    mapping(address => int []) public OWNER_MAPPING; //keeps track of which trandactions have been approved for each owner
    address [] private OWNERS_LIST; // having a list of the onwer for direct reference
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
            OWNER_MAPPING[_owners[i]] = [-10]; //dummy negative value
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
    
    function createTransferRequest (address payable _destinationAddress, uint amamamount) public 
    checkOwners 
    balanceCheck(amamamount)
    payable{
        if (REQUIRED_APPROVALS == 1){
            withdraw(amamamount, _destinationAddress);
        }
        
        else{
            TransferObject memory newTransfer = TransferObject(_destinationAddress, amamamount, 1);
            PERDING_TRANSFERS.push(newTransfer);
            int latestIndex = int(PERDING_TRANSFERS.length)-1;
            OWNER_MAPPING[msg.sender].push(latestIndex);
        }
    }
    
    function getAllPendingTransfers() public view returns(TransferObject[] memory){
        return PERDING_TRANSFERS;   
    }
    
    function approveTransfer(uint _transferIndex) public checkOwners uniqueApproval(int(_transferIndex)){
        require(PERDING_TRANSFERS[_transferIndex].approvals < REQUIRED_APPROVALS, "Transaction already approved");
        PERDING_TRANSFERS[_transferIndex].approvals+=1;
        OWNER_MAPPING[msg.sender].push(int(_transferIndex));
        
        if (PERDING_TRANSFERS[_transferIndex].approvals == REQUIRED_APPROVALS){
            withdraw(PERDING_TRANSFERS[_transferIndex].amount, PERDING_TRANSFERS[_transferIndex].destinationAddress);
        }
    }
}
