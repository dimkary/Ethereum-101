pragma solidity 0.7.5;

contract multiSig {
    
    address[] private OWNERS;
    uint private REQUIRED_APPROVALS;
    
    constructor(address[] memory _owners, uint _approvals){
        require(_owners.length >= _approvals, "The number of required approvals is more than the number of owners");
        require(_owners.length >= 0, "At leas one owner is required");
        require(_approvals >= 0, "At least one approver is required");
        
        OWNERS= _owners;
        OWNERS.push(msg.sender);
        
        REQUIRED_APPROVALS = _approvals;    
    }
    
    
}