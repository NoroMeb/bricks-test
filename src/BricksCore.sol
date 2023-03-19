// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Fractions.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BricksCore {
    event TokenFractioned(address fractionsAddress, uint256 totalSupply);

    address public vault;

    constructor(address vaultAddress) {
        vault = vaultAddress;
    }

    function fraction(
        address contractAddress,
        uint256 tokenId,
        uint256 fractionsNumber,
        string memory name,
        string memory symbol
    ) external returns (address) {
        require(IERC721(contractAddress).getApproved(tokenId) == address(this), "token transfer not approved !");
        IERC721(contractAddress).safeTransferFrom(msg.sender, vault, tokenId);

        Fractions fractions = new Fractions(name, symbol, fractionsNumber);

        emit TokenFractioned(address(fractions), fractionsNumber);

        return address(fractions);
    }
}
