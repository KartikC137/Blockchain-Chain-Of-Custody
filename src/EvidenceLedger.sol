// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Evidence} from "./ChainOfCustody.sol";

contract EvidenceLedger {
    //////////////////
    // Errors      ///
    //////////////////

    ////////////////////////
    // State Variables   ///
    ////////////////////////

    Evidence private evidence;

    mapping(bytes32 evidenceID => Evidence evidence) private s_evidenceIDToEvidence;
    mapping(address creator => bytes32[] evidenceIDs) private s_creatorToEvidenceIDs;

    //////////////
    // Events  ///
    //////////////
    event EvidenceCreated(address indexed creator, bytes32 indexed evidenceID, string description);

    //////////////////
    // Modifiers   ///
    //////////////////

    //////////////////
    // Functions   ///
    //////////////////

    // External Functions

    function createEvidence(bytes32 evidenceID, string memory description) external {
        evidence = new Evidence(address(this), evidenceID, msg.sender, msg.sender, description);
        s_evidenceIDToEvidence[evidenceID] = evidence;
        s_creatorToEvidenceIDs[msg.sender].push(evidenceID);

        emit EvidenceCreated(msg.sender, evidenceID, description);
    }

    // Public and External View Functions
    function getEvidenceLedgerStatus() external pure returns (bool evidenceLedgerCreated) {
        evidenceLedgerCreated = true;
    }

    function getEvidenceContractAddress(bytes32 evidenceID) external view returns (address evidenceContractAddress) {
        evidenceContractAddress = address(s_evidenceIDToEvidence[evidenceID]);
    }

    function getEvidencesCreatedByCreator(address creator) external view returns (bytes32[] memory evidenceIDs) {
        evidenceIDs = s_creatorToEvidenceIDs[creator];
    }
}
