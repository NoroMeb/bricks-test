// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Fractions.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./IVault.sol";

contract BricksCore is Initializable {
    event TokenFractioned(address fractionsAddress, uint256 totalSupply);
    event TokenAssembled(address contractAddress, uint256 tokenId);

    address public vault;

    struct OriginalNFT {
        address contractAddress;
        uint256 tokenId;
    }

    mapping(address => OriginalNFT) public storedOriginal;

    /**
     * @dev     . Initializer function, can be called once when TransparentUpgradeableProxy is deployed
     * @param   vaultAddress  . the Address of the Vault contract where Original NFTs are stored .
     */
    function intialize(address vaultAddress) external initializer {
        vault = vaultAddress;
    }

    /**
     * @notice  . fraction function, call to store your NFT in a
     *             Vault, deploy an ERC20 contract and mint a specified number
     *             of tokens to the NFT owner . (NFT must be approved to the contract)
     * @param   contractAddress  . the address of the original NFT contract (ERC-721)
     * @param   tokenId  . the ID of the Token
     * @param   fractionsNumber  . the Number of ERC-20 to be minted
     * @param   name  . the name of the ERC20
     * @param   symbol  . the symbol of the ERC20
     * @return  address . the address of the ERC20
     */
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

        OriginalNFT memory originalNFT = OriginalNFT(contractAddress, tokenId);
        storedOriginal[address(fractions)] = originalNFT;

        emit TokenFractioned(address(fractions), fractionsNumber);

        return address(fractions);
    }

    function assemble(address fractionsContractAddress) external {
        require(
            IERC20(fractionsContractAddress).allowance(msg.sender, address(this))
                == IERC20(fractionsContractAddress).totalSupply(),
            "You need to gather all fractions to get the NFT"
        );

        OriginalNFT memory originalNFT = storedOriginal[fractionsContractAddress];

        IVault(vault).transferOriginal(originalNFT.contractAddress, originalNFT.tokenId, msg.sender);

        emit TokenAssembled(originalNFT.contractAddress, originalNFT.tokenId);
    }
}
