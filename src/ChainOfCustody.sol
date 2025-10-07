//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @title Evidence Contract for Chain of Custody
 * @author Kartik Kumbhar
 *
 * Evidence ID and Contract Address define a unique piece of evidence.
 * 1. Evidence ID is passed through EvidenceLedger contract.
 * 2. Contract Address is the address of this contract.
 * 
 * @notice
 */

contract Evidence {
    //////////////////
    // Errors      ///
    //////////////////
    error UnauthorizedDeployment(address caller);
    error CreatorIsNotInitialOwner(address creator, address initialOwner);
    error CallerIsNotCurrentOwner(address owner, address caller);

    ////////////////////////
    // State Variables   ///
    ////////////////////////
    address private immutable i_originalEvidenceLedgerAddress;
    address private immutable i_creator;
    bytes32 private immutable i_evidenceID;
    address private owner;
    address[] private chainOfCustody;
    string private description;
    bool private isActive = true;

    //////////////
    // Events  ///
    //////////////
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event EvindenceDiscontinued(bytes32 indexed evidenceID);

    //////////////////
    // Modifiers   ///
    //////////////////
    modifier onlyCreator() {
        require(msg.sender == chainOfCustody[0], "Only Creator can call this function");
        _;
    }

    modifier onlyCurrentOwner(address caller) {
        if (caller != owner) revert CallerIsNotCurrentOwner(owner, caller);
        _;
    }

    modifier onlyIfActive() {
        require(isActive, "Evidence is no longer accessible");
        _;
    }

    //////////////////
    // Functions   ///
    //////////////////

    // Constructor

    constructor(address _evidenceLedgerAddress, bytes32 _evidenceID, address _creator, address _initialOwner, string memory _description) {
        if(msg.sender != _evidenceLedgerAddress) revert UnauthorizedDeployment(msg.sender);
        if (_initialOwner != _creator) revert CreatorIsNotInitialOwner(_creator, msg.sender);
        if (_creator == address(0)) revert("Invalid Creator: cannot be zero address");
        if (_evidenceID == 0x0) revert("Invalid evidence ID: ID cannot be empty");
        if (bytes(_description).length == 0) revert("Invalid description: description cannot be empty");

        i_originalEvidenceLedgerAddress = _evidenceLedgerAddress;
        i_creator = _creator;
        owner = i_creator;
        chainOfCustody.push(i_creator);
        i_evidenceID = _evidenceID;
        description = _description;
    }

    // External Functions
    function transferOwnership(address newOwner) external onlyIfActive() {
        address previousOwner = owner;
        _transferOwnership(previousOwner, newOwner);
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function DiscontinueEvidence() external onlyIfActive() {
        _discontinueEvidence();
        emit EvindenceDiscontinued(i_evidenceID);
    }

    // Private & Internal Functions View function
    function _transferOwnership(address _from, address _to) private onlyCurrentOwner(_from) {
        owner = _to;
        chainOfCustody.push(_to);
    }

    function _discontinueEvidence() private onlyCreator() {
        isActive = false;
    }

    // Public & External Functions View Functions 
    function getEvidenceID() external view returns (bytes32) {
        return i_evidenceID;
    }

    function getEvidenceCreator() external view returns (address) {
        return i_creator;
    }
    
    function getEvidenceDescription() external view returns (string memory) {
        return description;
    }

    function getCurrentOwner() external view returns (address) {
        return owner;
    }

    function getChainOfCustody() external view returns (address[] memory) {
        return chainOfCustody;
    }

    function getEvidenceState() external view returns (bool) {
        return isActive;
    }

}
