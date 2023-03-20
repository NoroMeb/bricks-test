// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract FractionsGovernor {
    event MintProposalCreated(uint256 amount, bool executed, bool canceled, address proposer);

    struct MintProposal {
        uint256 amount;
        bool executed;
        bool canceled;
    }

    mapping(uint256 => MintProposal) private _proposals;

    function propose(address tokenAddress, uint256 mintAmount) external {}
}
