// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// https://dev.to/truongpx396/blockchain-nft-erc1155-from-basics-to-production-13o4

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IETHRelay} from "./IETHRelay.sol";
import {ISolarArrayComponentsNftFactory} from "./ISolarArrayComponentsNftFactory.sol";
import {SolarArrayStructs} from "./SolarArrayStructs.sol";
import {SolarArraySetters} from "./SolarArraySetters.sol";
import {SolarArrayVerifier} from "./SolarArrayVerifier.sol";

contract SolarArrayNftFactory is ERC1155, Pausable, Ownable {
    using SolarArrayVerifier for *;

    error SolarArrayNftFactory__InvalidComponentCollectionId();
    error SolarArrayNftFactory__MissingComponentURI();
    error SolarArrayNftFactory__ComponentQuantityExceedsSupply();
    error SolarArrayNftFactory__ComponentMintingFailed();
    error SolarArrayNftFactory__InsufficientEthForComponentPurchase();
    error InvalidETHRelayaddress();

    ISolarArrayComponentsNftFactory public componentsFactory;
    IETHRelay public ethRelay;

    uint32 constant DEFAULT_MODULE_SUPPLY = 1e6;
    uint32 constant DEFAULT_MINIMUM_SUPPLY = 1e5;
    uint256 constant ETH_PRICE_PER_COMPONENT = 30000000000000;
    string public constant name = "Solar Array NFT Factory";
    string public constant symbol = "WATT";

    mapping(uint256 => string) private customUris;
    mapping(uint256 => SolarArrayStructs.Array) public s_arrays;
    mapping(uint256 => bool) public mintedArrayTokens;
    mapping(uint256 => uint256) public arrayTokens;

    address public i_owner; // Contract owner address
    uint256 public s_tokenCount = 0;

    event TokenCreated(address indexed i_owner, uint256 indexed tokenId, string uri);

    constructor(
        address _componentsFactory,
        address _ethRelayAddress
    ) ERC1155("ipfs://bafybeibilz47fthsx5surktoy36pcxexthcluatjdxjth6gcp5k7sm5ocu/solar_array/") Ownable(msg.sender) {
        // store contract owner
        i_owner = owner();

        // Components Factory Interface
        componentsFactory = ISolarArrayComponentsNftFactory(_componentsFactory);
        if(_ethRelayAddress==address(0)){
            revert InvalidETHRelayaddress();
        }
        ethRelay = IETHRelay(_ethRelayAddress);

        // Start the contract in paused state
        _pause();
    }

    /**
     * @dev Sets the contract name, description.
     * @return string The json encoded string.
     */
    function contractURI() public pure returns (string memory) {
        string memory json = '{"name": "Solar Array NFT Factory ","description":"Memoralize solar arrays and their components"}';
        return string.concat("data:application/json;utf8,", json);
    }

    function setCustomUri(uint256 tokenId, string memory newUri) public  {
        customUris[tokenId] = newUri;
    }

    /**
     * @dev Updates the ETHRelay contract address. Only the owner can call this.
     * @param _newETHRelayAddress The new ETHRelay contract address.
     */
    function updateETHRelay(address _newETHRelayAddress) external onlyOwner {
        if(_newETHRelayAddress == address(0)) revert InvalidETHRelayaddress();
        ethRelay = IETHRelay(_newETHRelayAddress);
    }

    function mintAndTransferArrayComponents(
        uint256 collectionId, uint256 tokenId, uint256 quantity, uint256 supply, uint256 ethSent
    ) public whenNotPaused {

        bool componentTokenExists = false;
        address componentOwner;

        (string memory tokenURI,) = componentsFactory.getCollectionURI(collectionId);


        componentTokenExists = componentsFactory.mintedTokens(tokenId);

        if (componentTokenExists) {
            // no transfer required, need some segregation or decrease in total supply.
            // replace with new transfer that segregates component owner/array owner quantity from total supply
            // use zeppelin totalSupply extension for owner balances vs token supply balance
            componentOwner = componentsFactory.getComponentOwner(tokenId);

            if (msg.sender == componentOwner){
                // Transfer the ETH to the component owner
                transferComponent(tokenId, quantity, 0);
            } else {
                //should be the component fraction of ethSent
                //transferComponent should return all unspent ethSent
                transferComponent(tokenId, quantity, ethSent);
            }
        } else {
            if (collectionId==0 && bytes(tokenURI).length!=0) {
                collectionId = componentsFactory.createCollection(msg.sender, tokenURI);
            }
            // create new component token
            // componentsFactory.mint{gas: DEFAULT_GAS_COMPONENT}(msg.sender, collectionId, tokenId, supply, "");
            componentsFactory.mint(msg.sender, collectionId, tokenId, supply, "");
            // quantity s/b segregated in contract?
            transferComponent(tokenId, quantity, 0);
        }
    }

    struct ArraysAndComponents {
        SolarArrayStructs.Array solarArray;
        SolarArrayStructs.Components[] components;
    }

    function mintArray(
        address owner,
        ArraysAndComponents memory arraysAndComponents,
        uint256 ethSent
    ) public payable {
        uint256 componentQuantity;
        uint32  supply = DEFAULT_MODULE_SUPPLY;

        if (ethSent > (msg.sender).balance)
            revert SolarArrayNftFactory__InsufficientEthForComponentPurchase();

        SolarArrayStructs.Array memory solarArray = arraysAndComponents.solarArray;

        // Verify solar array details
        SolarArrayVerifier.verify(
            solarArray,
            arraysAndComponents.components,
            componentsFactory,
            s_arrays,
            arrayTokens,
            s_tokenCount
        );

        // Store the solar array
        // problem with remix compiler for copying component memory arrays directly
        // s_arrays[solarArray.tokenId] = solarArray;

        SolarArraySetters.setSolarArray(
            s_arrays[solarArray.tokenId],
            solarArray
        );

        // Add components

        // Modules
        uint256 collectionId = 0;
        uint16 indexOfComponents = 0;

        for (uint256 i = 0; i < solarArray.modules.length; i++) {
            componentQuantity = solarArray.modules[i].quantity;

            supply = arraysAndComponents.components[indexOfComponents].supply;
            collectionId = arraysAndComponents.components[indexOfComponents].collectionId;
            indexOfComponents++;

            if (componentQuantity>supply) {
                revert SolarArrayNftFactory__ComponentQuantityExceedsSupply();
            }

            mintAndTransferArrayComponents(collectionId, solarArray.modules[i].tokenId, componentQuantity, supply, ethSent);

            SolarArraySetters.addModuleToArray(
                s_arrays[solarArray.tokenId],solarArray.modules[i]);
        }
        // Inverters
        for (uint256 i = 0; i < solarArray.inverters.length; i++) {
            componentQuantity = solarArray.inverters[i].quantity;

            supply = arraysAndComponents.components[indexOfComponents].supply;
            collectionId = arraysAndComponents.components[indexOfComponents].collectionId;
            indexOfComponents++;

            if (componentQuantity>supply) {
                revert SolarArrayNftFactory__ComponentQuantityExceedsSupply();
            }

            mintAndTransferArrayComponents(collectionId, solarArray.inverters[i].tokenId, componentQuantity, supply, ethSent);

            SolarArraySetters.addInverterToArray(
                s_arrays[solarArray.tokenId],solarArray.inverters[i]);
        }
        // Batteries
        for (uint256 i = 0; i < solarArray.batteries.length; i++) {
            SolarArraySetters.addBatteryToArray(
                s_arrays[solarArray.tokenId],solarArray.batteries[i]);
        }
        // Meters
        for (uint256 i = 0; i < solarArray.meters.length; i++) {
            SolarArraySetters.addMeterToArray(
                s_arrays[solarArray.tokenId],solarArray.meters[i]);
        }
        // Transformers
        for (uint256 i = 0; i < solarArray.transformers.length; i++) {
            SolarArraySetters.addTransformerToArray(
                s_arrays[solarArray.tokenId],solarArray.transformers[i]);
        }
        // Lines
        for (uint256 i = 0; i < solarArray.lines.length; i++) {
            SolarArraySetters.addLineToArray(
                s_arrays[solarArray.tokenId],solarArray.lines[i]);
        }

        // Minting the solar array
        // setCustomUri(solarArray.tokenId, newTokenURI); // Optional if using token-specific URIs
        emit TokenCreated(owner, solarArray.tokenId, uri(solarArray.tokenId));
        _mint(owner, solarArray.tokenId, 1, solarArray.geometry);

        // Update mappings, counter
        arrayTokens[s_tokenCount] = solarArray.tokenId;
        mintedArrayTokens[solarArray.tokenId] = true;
        s_tokenCount += 1;
    }

    function transferComponent(
        uint256 tokenId,
        uint256 amount,
        uint256 ethSent
    ) public payable {
        // Get the component owner from the components factory
        // payable here and on call below redundant?
        address componentOwner = componentsFactory.getComponentOwner(tokenId);

        // Define the price per component (in wei)
        uint256 pricePerComponent = ETH_PRICE_PER_COMPONENT;

        // Calculate total cost
        uint256 totalCost = pricePerComponent * amount;

        // check account balance for sufficient ETH
        // Ensure the sender has sent enough ETH
        if (msg.sender!=componentOwner){
            if (ethSent < totalCost)
                revert SolarArrayNftFactory__InsufficientEthForComponentPurchase();

            ethRelay.transferETH{value: totalCost}(payable(componentOwner));
        }

        // Transfer the component tokens from the component owner to the buyer
        // componentsFactory.safeTransferFrom{gas: 2 * DEFAULT_GAS_COMPONENT}(
        componentsFactory.safeTransferFrom(
            componentOwner, // From the component owner
            msg.sender, // To the buyer (caller)
            tokenId, // Token ID of the component
            amount, // Quantity to transfer
            "" // Data (none in this case)
        );
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

    function uri(uint256 tokenId) public view override returns (string memory) {
        return bytes(customUris[tokenId]).length > 0
            ? string.concat(customUris[tokenId],Strings.toString(tokenId),".json")
            : string.concat(super.uri(tokenId),Strings.toString(tokenId),".json"); // Fallback to the default URI if none set
    }

    // Getter function for Array
    /**
     * @dev Retrieves the details of a specific solar array.
     */
    function getArray(uint256 tokenId)
        external
        view
        returns (SolarArrayStructs.Array memory)
    {
        return s_arrays[tokenId];
    }

    receive() external payable {}
}
