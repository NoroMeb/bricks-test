// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BricksCore.sol";
import "../src/Fractions.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    event TokenFractioned(address fractionsAddress, uint256 totalSupply);
    event TokenAssembled(address contractAddress, uint256 tokenId);

    function setUp() public {
        bricksCore = new BricksCore();
        proxyAdmin = new ProxyAdmin();
        transparentUpgradeableProxy =
        new TransparentUpgradeableProxy(address(bricksCore), address(proxyAdmin), abi.encodeWithSignature("intialize()"));
        bricksCore = BricksCore(address(transparentUpgradeableProxy));
        mockERC721 = new MockERC721();
    }

    function approveAndFraction() internal returns (address) {
        mockERC721.approve(address(bricksCore), 0);
        address fractions =
            bricksCore.fraction(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol, address(this));
        return fractions;
    }

    function approveAndFractionAndBurn() internal returns (address) {
        mockERC721.approve(address(bricksCore), 0);
        address fractions =
            bricksCore.fractionAndBurn(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol, address(this));
        return fractions;
    }

    function assemble(address fractions) internal {
        IERC20(fractions).approve(address(bricksCore), IERC20(fractions).balanceOf(address(this)));
        bricksCore.assemble(fractions, address(this));
    }

    function testFractionTransferTokenToVault() public {
        approveAndFraction();
        assertEq(mockERC721.ownerOf(0), address(bricksCore.vaultAddress()));
    }

    function testFractionCreatesFractionsContract() public {
        address fractions = approveAndFraction();

        assertEq(Fractions(fractions).name(), name);
        assertEq(Fractions(fractions).symbol(), symbol);
        assertEq(Fractions(fractions).totalSupply(), TOTAL_FRACTIONS_NUMBER);
        assertEq(Fractions(fractions).balanceOf(address(this)), TOTAL_FRACTIONS_NUMBER);
    }

    function testFractionMapFractionsAddressToOriginalNFT() public {
        address fractions = approveAndFraction();

        (address contractAddress, uint256 tokenId) = bricksCore.getStoredOriginal(fractions);

        assertEq(contractAddress, address(mockERC721));
        assertEq(tokenId, 0);
    }

    function testCannotFractionNotApprovedToken() public {
        vm.expectRevert("token transfer not approved !");
        bricksCore.fraction(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol, address(this));
    }

    function testFractionAndBurnTransferTokenToBurnignAddress() public {
        approveAndFractionAndBurn();
        assertEq(mockERC721.ownerOf(0), address(bricksCore.burningAddress()));
    }

    function testFractionAndBurnCreatesFractionsContract() public {
        address fractions = approveAndFractionAndBurn();

        assertEq(Fractions(fractions).name(), name);
        assertEq(Fractions(fractions).symbol(), symbol);
        assertEq(Fractions(fractions).totalSupply(), TOTAL_FRACTIONS_NUMBER);
        assertEq(Fractions(fractions).balanceOf(address(this)), TOTAL_FRACTIONS_NUMBER);
    }

    function testCannotFractionAndBurnNotApprovedToken() public {
        vm.expectRevert("token transfer not approved !");
        bricksCore.fractionAndBurn(address(mockERC721), 0, TOTAL_FRACTIONS_NUMBER, name, symbol, address(this));
    }

    function testAssembleBurnFractions() public {
        address fractions = approveAndFraction();
        assemble(fractions);
        assertEq(IERC20(fractions).totalSupply(), 0);
    }

    function testAssembleSendOriginalNFTToReceiver() public {
        address fractions = approveAndFraction();
        assemble(fractions);
        assertEq(mockERC721.ownerOf(0), address(this));
    }

    function testCannotAssembleNotApprovedToken() public {
        address fractions = approveAndFraction();
        vm.expectRevert("You need to gather all fractions to get the NFT");

        bricksCore.assemble(fractions, address(this));
    }
}
