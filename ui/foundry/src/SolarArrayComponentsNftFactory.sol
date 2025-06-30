// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {SolarArrayStructs} from "./SolarArrayStructs.sol";

/**
 * @title SolarArrayComponentsNftFactory
 * @dev Implementation of an ERC1155 contract for minting NFTs representing components of a solar array.
 * This contract allows users to create collections and mint NFTs within those collections. 
 * Each token is associated with a specific component type (e.g., module, inverter).
 */
contract SolarArrayComponentsNftFactory is ERC1155, Ownable, Pausable {

    error SolarArrayComponentsNftFactory__TokenExists();
    error SolarArrayComponentsNftFactory__MustBeCollectionOwner();
    error SolarArrayComponentsNftFactory__InvalidCollectionId();

    /**
     * @dev Struct representing a collection, containing the base URI, owner, and mapping of component IDs to token IDs.
     */
    struct Collection {
        string baseURI;
        address owner;
    }
    
    // better way?
    mapping(uint256 => string) private customUris;

    uint256 private s_currentCollectionId = 0; // Tracks the current collection ID
    mapping(uint256 => Collection) public s_collections; // Mapping from collection ID to Collection struct
    // mapping(uint256 => CollectionTokenIds) public s_collectionsTokenIds; // Mapping from collection ID to CollectionTokenIds struct
    mapping(uint256 => uint256) private s_collectionTokens; // Mapping from token ID to collectionId
    mapping(string => uint256[]) private s_componentTokens; // Mapping from token ID to Components
    mapping(uint256 => bool) public mintedTokens;

    string public constant name = "Solar Array Components NFT Factory";
    string public constant symbol = "OHM";

    address public i_owner; // Contract owner address

    event TokenCreated(uint256 tokenId, string uri);

    /**
     * @dev Initializes the contract, setting the owner and pausing the contract initially.
     */
    constructor() ERC1155("ipfs://bafybeigyyoahgflonzbpnapbv6uichggi2xn55w3fxdnbxbsswuz77b3a4/") Ownable(msg.sender) {
        i_owner = owner();
        _pause(); // Start the contract in paused state
    }

    /**
     * @dev Emitted when a new collection is created.
     * @param collectionId The ID of the newly created collection.
     * @param owner The address of the owner of the collection.
     * @param uri The base URI of the collection.
     */
    event CollectionCreated(uint256 indexed collectionId, address owner, string uri);

   /**
     * @dev Sets the contract name, description.
     * @return string The json encoded string.
     */
    function contractURI() public pure returns (string memory) {
        string memory json = '{"name": "Solar Array Components NFT Factory ","description":"Register solar array components"}';
        return string.concat("data:application/json;utf8,", json);
    }

   /**
     * @dev Creates a new collection with a base URI.
     * @param baseURI The base URI for the new collection.
     * @return uint256 The ID of the newly created collection, emits CollectionCreated event
     */
    function createCollection(address to, string memory baseURI) public whenNotPaused returns (uint256) {
        uint256 newCollectionId = s_currentCollectionId++;
        Collection  storage newCollection = s_collections[newCollectionId];
        // CollectionTokenIds storage newCollectionTokenIds = s_collectionsTokenIds[newCollectionId];
        newCollection.baseURI = baseURI;
        newCollection.owner = to;

        // _setURI(baseURI);

        emit CollectionCreated(newCollectionId, to, newCollection.baseURI);
        return newCollectionId;
    }

    /**
     * @dev Mints a new token within a collection for a unique tokenId.
     * @param collectionId The ID of the collection where the token will be minted.
     * @param tokenId The tokenId.
     * @param supply The number of tokens to mint.
     * @param data Additional data, if any.
     */
    function mint(
        address to,
        uint256 collectionId,
        uint256 tokenId,
        uint256 supply,
        string memory newTokenURI,
        bytes memory data
    ) public whenNotPaused returns (uint256) {
        Collection storage collection = s_collections[collectionId];
        // CollectionTokenIds storage collectionsTokenIds = s_collectionsTokenIds[collectionId];
        if (collection.owner == address(0)) {
            revert SolarArrayComponentsNftFactory__InvalidCollectionId();
        }
        if (collection.owner != to) {
            revert SolarArrayComponentsNftFactory__MustBeCollectionOwner();
        }
        if (mintedTokens[tokenId]) {
            revert SolarArrayComponentsNftFactory__TokenExists();
        }

        _mint(to, tokenId, supply, data);
        setCustomUri(tokenId, newTokenURI); // Optional if using token-specific URIs
        emit TokenCreated(tokenId, uri(tokenId));

        mintedTokens[tokenId] = true;
        // collectionsTokenIds.collectionTokenIds[collectionId].push(tokenId);  // is this necessary?
        s_collectionTokens[tokenId] = collectionId;

        return tokenId;
    }
    
    function setCustomUri(uint256 tokenId, string memory newUri) public  {
        customUris[tokenId] = newUri;
    }
    /**
     * @dev Mints a new token for a specific component within a collection.
     * Removes all spaces and converts component, manufacturer, and model strings to lowercase before generating the token ID.
     * @param collectionId The ID of the collection where the token will be minted.
     * @param component The name of the component.
     * @param manufacturer The name of the manufacturer.
     * @param model The model of the component.
     * @param supply The number of tokens to mint.
     * @param data Additional data, if any.
     */
    
    function generateTokenId(
        string memory component, 
        string memory manufacturer, 
        string memory model
    ) public pure returns (uint256) {
        // Remove spaces and convert to lowercase
        string memory cleanedComponent = _cleanAndLowercase(component);
        string memory cleanedManufacturer = _cleanAndLowercase(manufacturer);
        string memory cleanedModel = _cleanAndLowercase(model);

        return uint256(keccak256(bytes(string.concat(cleanedComponent, "|", cleanedManufacturer, "|", cleanedModel))));
    }

    /**
     * @dev Utility function to remove spaces and convert a string to lowercase.
     * @param str The input string.
     * @return string The cleaned and lowercased string.
     */
    function _cleanAndLowercase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        uint256 j = 0;
        
        for (uint256 i = 0; i < bStr.length; i++) {
            if (bStr[i] != 0x20) { // Skip spaces (ASCII 0x20)
                // Convert to lowercase if it's an uppercase character (ASCII 'A' to 'Z')
                if (bStr[i] >= 0x41 && bStr[i] <= 0x5A) {
                    bLower[j] = bytes1(uint8(bStr[i]) + 32); // Convert to lowercase
                } else {
                    bLower[j] = bStr[i];
                }
                j++;
            }
        }
        
        // Resize the array to the actual number of characters
        bytes memory bCleaned = new bytes(j);
        for (uint256 i = 0; i < j; i++) {
            bCleaned[i] = bLower[i];
        }
        
        return string(bCleaned);
    }

    /**
     * @dev Mints multiple tokens in a batch for a specific collection.
     * @param to The address of the recipient.
     * @param collectionId The ID of the collection where the tokens will be minted.
     * @param ids The array of token IDs to mint; assumed to be pre-calculated from manufacturer and model...
     * @param amounts The array of amounts for each token to mint.
     * @param data Additional data, if any.
     */
    function mintBatch(
        address to, 
        uint256 collectionId, 
        string[] memory component, 
        uint256[] memory ids, 
        uint256[] memory amounts, 
        bytes memory data
        )  public whenNotPaused {

        for (uint256 i = 0; i < ids.length; i++) {
            if (mintedTokens[ids[i]]) {
                revert SolarArrayComponentsNftFactory__TokenExists();
            }
        }

        Collection storage collection = s_collections[collectionId];
        if (collection.owner == address(0)) {
            revert SolarArrayComponentsNftFactory__InvalidCollectionId();
        }
        if (collection.owner != msg.sender) {
            revert SolarArrayComponentsNftFactory__MustBeCollectionOwner();
        }

        _mintBatch(to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            string memory cleanedComponent = _cleanAndLowercase(component[i]);
            mintedTokens[ids[i]] = true;
            // collection.collectionTokenIds[collectionId].push(ids[i]);
            s_componentTokens[cleanedComponent].push(ids[i]);
            s_collectionTokens[ids[i]]=collectionId;
        }
    }

    /**
     * @dev Pauses all minting functions.
     * Can only be called by the contract owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract and allows minting.
     * Can only be called by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    *******************************************************************
    ********************* GETTER FUNCTIONS ****************************
    *******************************************************************
    */

    /**
     * @dev Retrieves the base URI of a specific collection.
     * @param collectionId The ID of the collection to query.
     * @return string The base URI of the collection.
     */
    function getCollectionURI(uint256 collectionId) public view returns (string memory, address) {
        Collection storage collection = s_collections[collectionId];
        // if (collection.owner == address(0)) {
        //     revert SolarArrayComponentsNftFactory__InvalidCollectionId();
        // }
        return (collection.baseURI, collection.owner);
    }

    function getCurrentCollectionId() public view returns (uint256) {
        return (s_currentCollectionId);
    }

    /**
     * @dev Retrieves the base URI of a specific collection.
     * @return Collection[] array with the base URI of the collection.
     */
    function getAllCollectionURIs() public view returns (Collection[] memory) {

        Collection[] memory collections = new Collection[](s_currentCollectionId);

        for (uint256 i = 0; i < s_currentCollectionId; i++){
            collections[i] = s_collections[i];
        }
        return (collections);
    }

    /**
     * @dev Retrieves all token IDs associated with a specific component.
     * @param component The name of the component to query.
     * @return uint256[] An array of token IDs associated with the component.
     */
    function getComponentTokens(string memory component) public view returns (uint256[] memory) {
        uint256 totalTokens = 0;

        for (uint256 i = 0; i < s_componentTokens[component].length; i++){
            totalTokens++;
        }
        uint256[] memory tokens = new uint256[](totalTokens);

        for (uint256 i = 0; i < s_componentTokens[component].length; i++) {
            tokens[i] = s_componentTokens[component][i]; // Assuming you want to access the first component ID's token IDs
        }

        return tokens;
    }

    /**
     * @dev Retrieves the URI for *the collection* of a specific token ID.
     * @param tokenId The ID of the token to query.
     * @return string The URI of the collection.
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        return bytes(customUris[tokenId]).length > 0
            ? string.concat(customUris[tokenId],Strings.toString(tokenId),".json")
            : string.concat(super.uri(tokenId),Strings.toString(tokenId),".json"); // Fallback to the default URI if none set
    }

    function getComponentOwner(uint256 tokenId) public view returns (address) {
        return s_collections[s_collectionTokens[tokenId]].owner;
    }
}

    // receive() external payable {
    //     // Logic for receiving ETH
    // }

    // fallback() external payable {
    //     // Fallback logic for receiving ETH
    // }
