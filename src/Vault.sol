// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Vault is ERC721Holder {
    address public bricksCore;

    constructor(address bricksCoreAddress) {
        bricksCore = bricksCoreAddress;
    }

    modifier onlyBricksCore() {
        require(msg.sender == bricksCore, "Only BricksCore can call this function");
        _;
    }

    function transferOriginal(address contractAddress, uint256 tokenId, address receiver) external onlyBricksCore {
        require(IERC721(contractAddress).ownerOf(tokenId) == address(this), "cannot recover the token");
        IERC721(contractAddress).transferFrom(address(this), receiver, tokenId);
    }
}
