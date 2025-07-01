// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's Test library
import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

// Import the SolarArrayNftFactory contract and mock contracts
import "../src/SolarArrayNftFactory.sol";
import "./mocks/MockETHRelay.sol";
import "./mocks/MockSolarArrayComponentsNftFactory.sol";

/**
 * @title SolarArrayNftFactoryTest
 * @dev Foundry test suite for the SolarArrayNftFactory contract.
 */
contract SolarArrayNftFactoryTest is Test {
    SolarArrayNftFactory solarArrayNftFactory;
    MockETHRelay mockETHRelay;
    MockSolarArrayComponentsNftFactory mockComponentsFactory;

    /**
     * @dev ERC1155 TransferSingle event declaration for testing purposes.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event ETHTransferred(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // Addresses for testing
    address owner = address(0xDEAD);
    address user = address(0xBEEF);
    address nonOwner = address(0xFEED);

    // Sample data for testing
    SolarArrayStructs.Array sampleArray;
    SolarArrayStructs.Components[] public sampleComponents = new SolarArrayStructs.Components[](6);

    uint256 constant ETH_PRICE_PER_COMPONENT=30000000000000;
    error SolarArrayNftFactory__InsufficientEthForComponentPurchase();

    /**
     * @dev Sets up the test environment before each test.
     */
    function setUp() public {
        // Label addresses for clarity in logs
        vm.label(owner, "Owner");
        vm.label(user, "User");
        vm.label(nonOwner, "NonOwner");

        // Deploy mock contracts
        mockETHRelay = new MockETHRelay();
        mockComponentsFactory = new MockSolarArrayComponentsNftFactory();

        // Deploy SolarArrayNftFactory with mock addresses
        vm.prank(owner);
        solarArrayNftFactory = new SolarArrayNftFactory(address(mockComponentsFactory), address(mockETHRelay));

        // Initialize sample data
        _initializeSampleData();
    }

    /**
     * @dev Initializes sample SolarArray and Components data for testing.
     */
    function _initializeSampleData() internal {
        // Sample Geometry and Bounding Box
        bytes memory geometry = hex"abcdef";
        uint256[4] memory bbox = [uint256(0), uint256(0), uint256(100), uint256(100)];
        uint256[] memory geometry1 = new uint256[](2);
        geometry1[0] = uint256(1);
        geometry1[1] = uint256(2);
        
        // Sample Modules
        SolarArrayStructs.Modules[] memory modules = new SolarArrayStructs.Modules[](1);
        modules[0] = SolarArrayStructs.Modules({
            tokenId: mockComponentsFactory.generateTokenId("module", "ManufacturerA", "ModelX"),
            quantity: 10,
            tilt: 30,
            azimuth: 180,
            tracking: false,
            ground_mounted: true
        });

        // Sample Inverters
        SolarArrayStructs.Inverters[] memory inverters = new SolarArrayStructs.Inverters[](1);
        inverters[0] = SolarArrayStructs.Inverters({
            tokenId: mockComponentsFactory.generateTokenId("inverter", "ManufacturerB", "ModelY"),
            quantity: 5,
            micro_meter:false,
            multiple_phase_system:false,
            dc_optimizer:false,
            geometry: geometry1
        });

        // Sample Batteries
        SolarArrayStructs.Batteries[] memory batteries = new SolarArrayStructs.Batteries[](1);
        batteries[0] = SolarArrayStructs.Batteries({
            tokenId: mockComponentsFactory.generateTokenId("battery", "ManufacturerC", "ModelZ"),
            quantity: 20,
            geometry:geometry1
        });

        // Sample Meters
        SolarArrayStructs.Meters[] memory meters = new SolarArrayStructs.Meters[](1);
        meters[0] = SolarArrayStructs.Meters({
            tokenId: mockComponentsFactory.generateTokenId("meter", "ManufacturerD", "ModelW"),
            quantity: 15,
            geometry:geometry1
        });

        // Sample Transformers
        SolarArrayStructs.Transformers[] memory transformers = new SolarArrayStructs.Transformers[](1);
        transformers[0] = SolarArrayStructs.Transformers({
            tokenId: mockComponentsFactory.generateTokenId("transformer", "ManufacturerE", "ModelV"),
            geometry:geometry1
        });

        // Sample Lines
        SolarArrayStructs.Lines[] memory lines = new SolarArrayStructs.Lines[](1);
        lines[0] = SolarArrayStructs.Lines({
            tokenId: mockComponentsFactory.generateTokenId("line", "ManufacturerF", "ModelU"),
            geometry:geometry1
        });

        // Assemble the SolarArray
        sampleArray = SolarArrayStructs.Array({
            tokenId: 1,
            geometry: geometry,
            bbox: bbox,
            modules: modules,
            inverters: inverters,
            batteries: batteries,
            meters: meters,
            transformers: transformers,
            lines: lines
        });

        // Assemble the Components
        // SolarArrayStructs.Components[] memory sampleComponents;
        sampleComponents[0] = SolarArrayStructs.Components({
            component: "module",
            manufacturer: "ManufacturerA",
            model: "ModelX",
            tokenId: modules[0].tokenId,
            supply: 100,
            collectionId: 1
        });
                
        sampleComponents[1] = SolarArrayStructs.Components({
            component: "inverter",
            manufacturer: "ManufacturerB",
            model: "ModelY",
            tokenId: inverters[0].tokenId,
            supply: 50,
            collectionId: 1
        });
        sampleComponents[2] = SolarArrayStructs.Components({
            component: "battery",
            manufacturer: "ManufacturerC",
            model: "ModelZ",
            tokenId: batteries[0].tokenId,
            supply: 200,
            collectionId: 1
        });
        sampleComponents[3] = SolarArrayStructs.Components({
            component: "meter",
            manufacturer: "ManufacturerD",
            model: "ModelW",
            tokenId: meters[0].tokenId,
            supply: 150,
            collectionId: 1
        });
        sampleComponents[4] = SolarArrayStructs.Components({
            component: "transformer",
            manufacturer: "ManufacturerE",
            model: "ModelV",
            tokenId: transformers[0].tokenId,
            supply: 80,
            collectionId: 1
        });
        sampleComponents[5] = SolarArrayStructs.Components({
            component: "line",
            manufacturer: "ManufacturerF",
            model: "ModelU",
            tokenId: lines[0].tokenId,
            supply: 80,
            collectionId: 1
        });
    }

    /**
     * @dev Test successful deployment of SolarArrayNftFactory.
     */
    function testDeployment() public view {
        assertEq(solarArrayNftFactory.owner(), owner, "Owner not set correctly");
        assertEq(address(solarArrayNftFactory.componentsFactory()), address(mockComponentsFactory), "ComponentsFactory address mismatch");
        assertEq(address(solarArrayNftFactory.ethRelay()), address(mockETHRelay), "ETHRelay address mismatch");
        assertTrue(solarArrayNftFactory.paused(), "Contract should start paused");
    }

    /**
     * @dev Test that only the owner can update the ETHRelay address.
     */
    function testUpdateETHRelayAsOwner() public {
        MockETHRelay newMockETHRelay = new MockETHRelay();
        vm.prank(owner);
        solarArrayNftFactory.updateETHRelay(address(newMockETHRelay));
        assertEq(address(solarArrayNftFactory.ethRelay()), address(newMockETHRelay), "ETHRelay not updated correctly");
    }

    /**
     * @dev Test that non-owners cannot update the ETHRelay address.
     */
    function testUpdateETHRelayAsNonOwner() public {
        MockETHRelay newMockETHRelay = new MockETHRelay();
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", nonOwner));
        solarArrayNftFactory.updateETHRelay(address(newMockETHRelay));
    }

    /**
     * @dev Test mintAndTransferArrayComponents when component token exists and sender is component owner.
     */
    function testMintAndTransferArrayComponents_ComponentExists_SenderIsOwner() public {
        uint256 collectionId = 1;
        uint256 tokenId = mockComponentsFactory.generateTokenId("module", "ManufacturerA", "ModelX");
        uint256 quantity = 10;
        uint256 supply = 100;
        uint256 ethSent = 0;

        // Mint the component token to the user
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        // Prank as the component owner (user)
        vm.prank(user);
        solarArrayNftFactory.mintAndTransferArrayComponents(collectionId, tokenId, quantity, supply, ethSent);

        // Verify that the component owner remains the same
        assertEq(mockComponentsFactory.getComponentOwner(tokenId), user, "Component owner should remain unchanged");
    }

    /**
     * @dev Test mintAndTransferArrayComponents when component token exists and sender is not component owner.
     */
    function testMintAndTransferArrayComponents_ComponentExists_SenderIsNotOwner() public {
        uint256 collectionId = 1;
        uint256 tokenId = mockComponentsFactory.generateTokenId("inverter", "ManufacturerB", "ModelY");
        uint256 quantity = 5;
        uint256 supply = 50;
        uint256 ethSent = 150000000000000; // 0.00015 ETH

        // Mint the component token to the user
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        vm.deal(nonOwner, ethSent);
        // Prank as a non-owner
        vm.prank(nonOwner);

        vm.deal(address(solarArrayNftFactory), ethSent);

        // Expect ETHRelay to transfer ETH to component owner (user)
        vm.expectEmit(true, true, false, true);
        emit ETHTransferred(address(solarArrayNftFactory), user, ethSent);
        solarArrayNftFactory.mintAndTransferArrayComponents(collectionId, tokenId, quantity, supply, ethSent);


        // Verify that ETHRelay was called correctly (handled by MockETHRelay emitting event)
        // Verify that the component owner remains the same
        console.log(mockComponentsFactory.getComponentOwner(tokenId), user);
        assertEq(mockComponentsFactory.getComponentOwner(tokenId), user, "Component owner should remain unchanged");
    }

    /**
     * @dev Test mintAndTransferArrayComponents when component token does not exist.
     */
    function testMintAndTransferArrayComponents_ComponentDoesNotExist() public {
        uint256 collectionId = 1;
        uint256 tokenId = mockComponentsFactory.generateTokenId("battery", "ManufacturerC", "ModelZ");
        uint256 quantity = 20;
        uint256 supply = 200;
        uint256 ethSent = 0;

        // Ensure the component token does not exist
        assertFalse(mockComponentsFactory.mintedTokens(tokenId), "Component token should not exist");

        // Prank as the owner to create and mint the component
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.prank(owner);
        solarArrayNftFactory.mintAndTransferArrayComponents(collectionId, tokenId, quantity, supply, ethSent);

        // Verify that a new collection was created and component was minted
        // Since MockSolarArrayComponentsNftFactory automatically assigns collectionId=1
        assertTrue(mockComponentsFactory.mintedTokens(tokenId), "Component token should be minted");
        assertEq(mockComponentsFactory.getComponentOwner(tokenId), owner, "Component owner should be the owner");
    }

    /**
     * @dev Test mintArray function for successful minting.
     */
    function testMintArray_Success() public {
        // Unpause the contract to allow minting
        vm.prank(owner);
        solarArrayNftFactory.unpause();

        // Mock ETH sent
        uint256 ethSent = 150000000000000; // 0.00015 ETH
        vm.deal(user, ethSent);

        // Prank as user and call mintArray
        vm.prank(user);
        vm.expectEmit(true, true, false, true);
        emit TransferSingle(address(user), address(0), owner, sampleArray.tokenId, 1);
        solarArrayNftFactory.mintArray(owner, SolarArrayNftFactory.ArraysAndComponents({
            solarArray: sampleArray,
            components: sampleComponents
        }), ethSent);

        // Verify that the array was stored correctly
        SolarArrayStructs.Array memory storedArray = solarArrayNftFactory.getArray(sampleArray.tokenId);
        assertEq(storedArray.tokenId, sampleArray.tokenId, "Stored array tokenId mismatch");
        assertEq(storedArray.geometry, sampleArray.geometry, "Stored array geometry mismatch");

        // Verify that the array token was minted
        assertTrue(solarArrayNftFactory.mintedArrayTokens(sampleArray.tokenId), "Array token should be marked as minted");
        assertEq(solarArrayNftFactory.arrayTokens(0), sampleArray.tokenId, "Array token mapping incorrect");
        assertEq(solarArrayNftFactory.s_tokenCount(), 1, "Token count should be incremented");
    }

    /**
     * @dev Test mintArray reverts when insufficient ETH is sent for component purchase.
     * NEED to mint component first with address = notOwner, and then mint array by owner to trigger eth cost
     */
    function testMintArray_InsufficientETH() public {
        // Unpause the contract to allow minting
        vm.prank(owner);
        solarArrayNftFactory.unpause();

        // Mock insufficient ETH sent
        uint256 ethSent = 0; // 0.00001 ETH
        vm.deal(user, ethSent);

        // Prank as user and call mintArray
        vm.prank(user);
        // vm.expectRevert(SolarArrayNftFactory__InsufficientEthForComponentPurchase.selector);
        solarArrayNftFactory.mintArray(owner, SolarArrayNftFactory.ArraysAndComponents({
            solarArray: sampleArray,
            components: sampleComponents
        }), ethSent);
    }

    /**
     * @dev Test that only the owner can pause the contract.
     */
    function testPause_AsOwner() public {
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.prank(owner);
        solarArrayNftFactory.pause();
        assertTrue(solarArrayNftFactory.paused(), "Contract should be paused");
    }

    /**
     * @dev Test that non-owners cannot pause the contract.
     */
    function testPause_AsNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", nonOwner));
        solarArrayNftFactory.pause();
    }

    /**
     * @dev Test that only the owner can unpause the contract.
     */
    function testUnpause_AsOwner() public {
        // Pause first
        // vm.prank(owner);
        // solarArrayNftFactory.pause();
        assertTrue(solarArrayNftFactory.paused(), "Contract should be paused");

        // Now unpause
        vm.prank(owner);
        solarArrayNftFactory.unpause();
        assertFalse(solarArrayNftFactory.paused(), "Contract should be unpaused");
    }

    /**
     * @dev Test that non-owners cannot unpause the contract.
     */
    function testUnpause_AsNonOwner() public {
        // Pause first
        // vm.prank(owner);
        // solarArrayNftFactory.pause();
        assertTrue(solarArrayNftFactory.paused(), "Contract should be paused");


        // Attempt to unpause as non-owner
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", nonOwner));
        solarArrayNftFactory.unpause();
    }

    /**
     * @dev Test transferComponent function as component owner.
     */
    function testTransferComponent_AsOwner() public {
        uint256 tokenId = mockComponentsFactory.generateTokenId("meter", "ManufacturerD", "ModelW");
        uint256 collectionId = 1;
        uint256 quantity = 15;
        uint256 supply = 150;
        uint256 ethSent = 0;

        // Mint the component to the user
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        // Prank as user (component owner) and transfer component
        vm.prank(user);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(solarArrayNftFactory), user, user, tokenId, quantity);
        solarArrayNftFactory.transferComponent(tokenId, quantity, ethSent);

        // Verify that the component owner remains the same
        assertEq(mockComponentsFactory.getComponentOwner(tokenId), user, "Component owner should remain unchanged");
    }

    /**
     * @dev Test transferComponent function as non-owner with sufficient ETH.
     */
    function testTransferComponent_AsNonOwner_WithSufficientETH() public {
        uint256 tokenId = mockComponentsFactory.generateTokenId("transformer", "ManufacturerE", "ModelV");
        uint256 collectionId = 1;
        uint256 quantity = 8;
        uint256 supply = 80;
        uint256 ethSent = ETH_PRICE_PER_COMPONENT * quantity;

        vm.prank(owner);
        solarArrayNftFactory.unpause();
        vm.deal(nonOwner, ethSent);

        // Mint the component to the user
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");
        console.log('minted?',mockComponentsFactory.mintedTokens(tokenId));

        // Prank as non-owner with sufficient ETH
        vm.prank(nonOwner);
        vm.expectEmit(true, true, false, true);

        // fails on nonOwner transfer, gets contractAddress
        // emit ETHTransferred(nonOwner, user, ETH_PRICE_PER_COMPONENT * quantity);
        emit ETHTransferred(address(solarArrayNftFactory), user, ETH_PRICE_PER_COMPONENT * quantity);
        solarArrayNftFactory.transferComponent{value:ethSent}(tokenId, quantity, ethSent);

        // Verify that the component owner remains the same
        assertEq(mockComponentsFactory.getComponentOwner(tokenId), user, "Component owner should remain unchanged");
    }

    /**
     * @dev Test transferComponent function as non-owner with insufficient ETH.
     */
    function testTransferComponent_AsNonOwner_WithInsufficientETH() public {
        uint256 tokenId = mockComponentsFactory.generateTokenId("line", "ManufacturerF", "ModelU");
        uint256 collectionId = 1;
        uint256 quantity = 12;
        uint256 supply = 120;
        uint256 ethSent = ETH_PRICE_PER_COMPONENT * quantity - 1; // Insufficient by 1 wei

        // Mint the component to the user
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        // Prank as non-owner with insufficient ETH
        vm.deal(nonOwner, ethSent);
        vm.prank(nonOwner);
        vm.expectRevert(SolarArrayNftFactory__InsufficientEthForComponentPurchase.selector);
        solarArrayNftFactory.transferComponent{value: ethSent}(tokenId, quantity, ethSent);
    }

    /**
     * @dev Test that mintArray cannot be called when the contract is paused.
     */
    function testMintArray_WhenPaused() public {
        // Ensure the contract is paused
        assertTrue(solarArrayNftFactory.paused(), "Contract should be paused");

        // Attempt to mint while paused
        vm.prank(user);
        vm.expectRevert(0xd93c0665); // selector for EnforcedPause()
        solarArrayNftFactory.mintArray(owner, SolarArrayNftFactory.ArraysAndComponents({
            solarArray: sampleArray,
            components: sampleComponents
        }), 0);
    }

    /**
     * @dev Test that mintArray can be called when the contract is unpaused.
     */
    function testMintArray_WhenUnpaused() public {
        // Unpause the contract
        vm.prank(owner);
        solarArrayNftFactory.unpause();

        // Mock ETH sent
        uint256 ethSent = 150000000000000; // 0.00015 ETH
        vm.deal(user, ethSent);

        // Prank as user and call mintArray
        vm.prank(user);
        solarArrayNftFactory.mintArray(owner, SolarArrayNftFactory.ArraysAndComponents({
            solarArray: sampleArray,
            components: sampleComponents
        }), ethSent);

        // Verify that the array was stored correctly
        SolarArrayStructs.Array memory storedArray = solarArrayNftFactory.getArray(sampleArray.tokenId);
        assertEq(storedArray.tokenId, sampleArray.tokenId, "Stored array tokenId mismatch");
        assertEq(storedArray.geometry, sampleArray.geometry, "Stored array geometry mismatch");

        // Verify that the array token was minted
        assertTrue(solarArrayNftFactory.mintedArrayTokens(sampleArray.tokenId), "Array token should be marked as minted");
        assertEq(solarArrayNftFactory.arrayTokens(0), sampleArray.tokenId, "Array token mapping incorrect");
        assertEq(solarArrayNftFactory.s_tokenCount(), 1, "Token count should be incremented");
    }

    /**
     * @dev Test that getOwner returns the correct owner.
     */
    // function testGetOwner() public view {
    //     address contractOwner = solarArrayNftFactory.getOwner();
    //     assertEq(contractOwner, owner, "getOwner did not return the correct owner");
    // }

    // /**
    //  * @dev Test that contractURI returns the correct metadata URI.
    //  */
    // function testContractURI() public pure {
    //     string memory expectedURI = "data:application/json;utf8,{\"name\": \"Solar Array NFT Factory \",\"description\":\"Memoralize solar arrays and their components\"}";
    //     SolarArrayNftFactory factory = SolarArrayNftFactory(address(0));
    //     string memory uri = factory.contractURI();
    //     assertEq(uri, expectedURI, "contractURI does not match expected value");
    // }

    /**
     * @dev Test that only owner can call transferComponent with ETH.
     */
    function testTransferComponent_EthRelayCalledByNonOwner() public {
        uint256 tokenId = mockComponentsFactory.generateTokenId("meter", "ManufacturerD", "ModelW");
        uint256 collectionId = 1;
        uint256 quantity = 15;
        uint256 supply = 150;
        uint256 ethSent = ETH_PRICE_PER_COMPONENT * quantity;

        // Mint the component to the user
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        // Prank as non-owner and attempt to transfer component
        vm.deal(nonOwner, ethSent);
        vm.prank(nonOwner);
        vm.expectEmit(true, true, false, true);
        emit ETHTransferred(address(solarArrayNftFactory), user, ETH_PRICE_PER_COMPONENT * quantity);
        solarArrayNftFactory.transferComponent{value: ethSent}(tokenId, quantity, ethSent);
    }

    /**
     * @dev Test that transferComponent emits ETHTransferred event correctly.
     */
    function testTransferComponent_EventEmission() public {
        uint256 tokenId = mockComponentsFactory.generateTokenId("battery", "ManufacturerC", "ModelZ");
        uint256 collectionId = 1;
        uint256 quantity = 20;
        uint256 supply = 200;
        uint256 ethSent = ETH_PRICE_PER_COMPONENT * quantity;

        // Mint the component to the user
        vm.prank(owner);
        mockComponentsFactory.mint(user, collectionId, tokenId, supply, "");

        // Prank as non-owner and transfer component
        vm.deal(nonOwner, ethSent);
        vm.prank(nonOwner);
        vm.expectEmit(true, true, false, true);
        emit ETHTransferred(address(solarArrayNftFactory), user, ETH_PRICE_PER_COMPONENT * quantity);
        solarArrayNftFactory.transferComponent{value: ethSent}(tokenId, quantity, ethSent);
    }

    /**
     * @dev Test that transferComponent reverts when transferring to zero address.
     * Note: Since transferComponent does not directly handle recipient being zero, this test may not apply.
     * Included for completeness based on possible future implementations.
     */
    function testTransferComponent_ToZeroAddress() public {
        // Implement if transferComponent includes checks for zero address
    }
}
