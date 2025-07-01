// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../src/ISolarArrayComponentsNftFactory.sol";

/**
 * @title MockSolarArrayComponentsNftFactory
 * @dev Mock implementation of the ISolarArrayComponentsNftFactory interface for testing purposes.
 */
contract MockSolarArrayComponentsNftFactory is ISolarArrayComponentsNftFactory {
    uint256 private _currentCollectionId = 1;
    uint256 private _currentTokenId = 1;
    address private _owner = msg.sender;

    mapping(uint256 => bool) public mintedTokensMapping;
    mapping(uint256 => address) private componentOwners;
    mapping(uint256 => string) private collectionURIs;

    event Minted(address indexed to, uint256 collectionId, uint256 tokenId, uint256 amount);
    event CollectionCreated(address indexed to, string baseURI, uint256 collectionId);
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    function mintedTokens(uint256 tokenId) external view override returns (bool) {
        return mintedTokensMapping[tokenId];
    }

    function mint(
        address to,
        uint256 collectionId,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external override returns (uint256) {
        require(collectionId != 0, "Invalid collection ID");
        mintedTokensMapping[tokenId] = true;
        componentOwners[tokenId] = to;
        emit Minted(to, collectionId, tokenId, amount);
        return tokenId;
    }

    function createCollection(address to, string calldata baseURI) external override returns (uint256) {
        require(to != address(0), "Cannot create collection for zero address");
        uint256 newCollectionId = _currentCollectionId++;
        collectionURIs[newCollectionId] = baseURI;
        emit CollectionCreated(to, baseURI, newCollectionId);
        return newCollectionId;
    }

    function generateTokenId(
        string calldata component,
        string calldata manufacturer,
        string calldata model
    ) external pure override returns (uint256) {
        // Simple hash-based tokenId generation for testing
        return uint256(keccak256(abi.encodePacked(component, manufacturer, model)));
    }

    function balanceOf(address to, uint256 tokenId) external view override returns (uint32) {
        // Mock balance logic
        if (componentOwners[tokenId] == to) {
            return 1;
        }
        return 0;
    }

    function safeTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external override {
        require(componentOwners[tokenId] == owner, "Only owner can transfer");
        // componentOwners[tokenId] = to;
        // Emit TransferSingle event as per ERC1155 standards
        emit TransferSingle(msg.sender, owner, to, tokenId, amount);
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    function getComponentOwner(uint256 tokenId) external view override returns (address) {
        return componentOwners[tokenId];
    }

    function getCollectionURI(uint256 collectionId) external view override returns (string memory baseURI, address collectionOwner) {
        baseURI = collectionURIs[collectionId];
        collectionOwner = _owner;
    }
}
