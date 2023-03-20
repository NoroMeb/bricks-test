// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BricksCore.sol";
import "../src/Fractions.sol";
import "../src/Vault.sol";
import "./mocks/MockERC721.sol";
import "../src/transparent_proxy/TransparentUpgradeableProxy.sol";
import "../src/transparent_proxy/ProxyAdmin.sol";

contract BricksCoreTest is Test {
    BricksCore public bricksCore;
    Vault public vault;
    MockERC721 public mockERC721;
    ProxyAdmin public proxyAdmin;
    TransparentUpgradeableProxy public transparentUpgradeableProxy;

    uint256 public constant TOTAL_FRACTIONS_NUMBER = 8;
    address public bob = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    string public name = "F-MockERC721#0";
    string public symbol = "FM#0";

    function setUp() public {
        vault = new Vault();
        bricksCore = new BricksCore();
        proxyAdmin = new ProxyAdmin();
        transparentUpgradeableProxy =
        new TransparentUpgradeableProxy(address(bricksCore), address(proxyAdmin), abi.encodeWithSignature("intialize(address)", address(vault)));
        bricksCore = BricksCore(address(transparentUpgradeableProxy));
        mockERC721 = new MockERC721();
    }

    function approveAndFraction() internal returns (address) {
        mockERC721.approve(address(bricksCore), 0);
        address fractions = bricksCore.fraction(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol);
        return fractions;
    }

    function testFractionTransferTokenToVault() public {
        approveAndFraction();
        assertEq(mockERC721.ownerOf(0), address(vault));
    }

    function testFractionCreatesFractionsContract() public {
        address fractions = approveAndFraction();

        assertEq(Fractions(fractions).name(), name);
        assertEq(Fractions(fractions).symbol(), symbol);
        assertEq(Fractions(fractions).totalSupply(), TOTAL_FRACTIONS_NUMBER);
        assertEq(Fractions(fractions).balanceOf(msg.sender), TOTAL_FRACTIONS_NUMBER);
    }

    function testCannotFractionNotApprovedToken() public {
        vm.expectRevert("token transfer not approved !");
        bricksCore.fraction(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol);
    }
}
