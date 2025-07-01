// ISolarArrayComponentsNftFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ISolarArrayComponentsNftFactory
 * @dev Interface for Solar Array Components NFT Factory.
 */
interface ISolarArrayComponentsNftFactory {
    function mintedTokens(uint256 tokenId) external view returns (bool);
    function mint(
        address to,
        uint256 collectionId,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);
    function createCollection(address to, string calldata baseURI) external returns (uint256);
    function generateTokenId(string calldata component, string calldata manufacturer, string calldata model) external view returns (uint256);
    function balanceOf(address to, uint256 tokenId) external view returns (uint32);
    function safeTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external;
    function getOwner() external view returns (address);
    function getComponentOwner(uint256 tokenId) external view returns (address);
    function getCollectionURI(uint256 collectionId) external view returns (string memory baseURI, address collectionOwner);
}
