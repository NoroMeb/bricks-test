// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IVault {
    function transferOriginal(address contractAddress, uint256 tokenId, address receiver) external;
}
