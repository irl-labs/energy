// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SolarArrayComponentsNftFactory.sol";

contract SolarArrayComponentsNftFactoryTest is Test {
    SolarArrayComponentsNftFactory nftFactory;
    address owner = address(1);
    address owner2 = address(2);
    address nonOwner = address(3);

    function setUp() public {
        vm.prank(owner);
        nftFactory = new SolarArrayComponentsNftFactory();
    }

    /// @dev 1. Check for expectedRevert for createCollection, mint, and mintBatch when contract is paused
    function testRevertWhenPaused() public {
        // Check revert on createCollection when paused
        // vm.expectRevert(SolarArrayComponentsNftFactory.EnforcedPause.selector); // Expecting the custom error
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vm.prank(owner);
        nftFactory.createCollection(owner, "ipfs://bafybeidbcsytbqfohee3ue5cai5yxirnqixqunanxuqaqqk35ptv65xcoa/{id}.json");

        // Check revert on mint when paused
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vm.prank(owner);
        nftFactory.mint(owner, 0, 1, 1, "","");

        // Check revert on mintBatch when paused
        string[] memory components = new string[](1);
        components[0] = "module";
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vm.prank(owner);
        nftFactory.mintBatch(owner, 0, components, ids, amounts, "");
    }
    /// @dev 2. Unpause the contract, create two collections with different owners and test minting rights
    function testMintingByRespectiveOwners() public {
        // Unpause the contract
        vm.prank(owner);
        nftFactory.unpause();

        // Create first collection by owner
        vm.prank(owner);
        uint256 collection1 = nftFactory.createCollection(owner, "ipfs://bafybeidbcsytbqfohee3ue5cai5yxirnqixqunanxuqaqqk35ptv65xcoa1/{id}.json");

        // Create second collection by owner2
        vm.prank(owner2);
        uint256 collection2 = nftFactory.createCollection(owner2, "ipfs://bafybeidbcsytbqfohee3ue5cai5yxirnqixqunanxuqaqqk35ptv65xcoa2/{id}.json");

        // Test that owner can mint in collection1
        vm.prank(owner);
        nftFactory.mint(owner, collection1, 1, 1, "","");

        // Test that owner2 can mint in collection2
        vm.prank(owner2);
        nftFactory.mint(owner2, collection2, 2, 1, "","");

        // Test that non-owner cannot mint in either collection
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__MustBeCollectionOwner.selector);
        vm.prank(nonOwner);
        nftFactory.mint(nonOwner, collection1, 1, 1, "","");

        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__MustBeCollectionOwner.selector);
        vm.prank(nonOwner);
        nftFactory.mint(nonOwner, collection2,1, 1, "","");
    }

    /// @dev 3. Test revert on mint for duplicate IDs, invalid collection, and not owner of collection
    function testMintReverts() public {
        // Unpause the contract
        vm.prank(owner);
        nftFactory.unpause();

        // Create a collection
        vm.prank(owner);
        uint256 collection1 = nftFactory.createCollection(owner, "ipfs://bafybeidbcsytbqfohee3ue5cai5yxirnqixqunanxuqaqqk35ptv65xcoa/{id}.json");

        // Test mint works the first time
        vm.prank(owner);
        nftFactory.mint(owner, collection1, 1, 1, "","");

        // Test revert on duplicate ID mint
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__TokenExists.selector);
        vm.prank(owner);
        nftFactory.mint(owner, collection1, 1, 1, "","");

        // Test revert on minting in an invalid collection
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__InvalidCollectionId.selector);
        vm.prank(owner);
        nftFactory.mint(owner, 999, 1, 1, "","");

        // Test revert on mint by non-owner
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__MustBeCollectionOwner.selector);
        vm.prank(nonOwner);
        nftFactory.mint(nonOwner, collection1, 1, 1, "","");
    }

    /// @dev 4. Test the same for mintBatch
    function testMintBatchReverts() public {
        // Unpause the contract
        vm.prank(owner);
        nftFactory.unpause();

        // Create a collection
        vm.prank(owner);
        uint256 collection1 = nftFactory.createCollection(owner, "ipfs://bafybeidbcsytbqfohee3ue5cai5yxirnqixqunanxuqaqqk35ptv65xcoa/{id}.json");

        string[] memory components = new string[](1);
        components[0] = "module";
        uint256[] memory ids = new uint256[](1);
        ids[0] = uint256(keccak256(bytes("module|manufacturer|model")));
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;

        // Test mintBatch works the first time
        vm.prank(owner);
        nftFactory.mintBatch(owner, collection1, components, ids, amounts, "");

        // Test revert on mintBatch with duplicate IDs
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__TokenExists.selector);
        vm.prank(owner);
        nftFactory.mintBatch(owner, collection1, components, ids, amounts, "");

        // Test revert on mintBatch in an invalid collection
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__InvalidCollectionId.selector);
        vm.prank(owner);
        components[0] = "module1";
        ids[0] = uint256(keccak256(bytes("module1|manufacturer1|model1")));
        amounts[0] = 1;
        nftFactory.mintBatch(owner, 999, components, ids, amounts, "");

        // Test revert on mintBatch by non-owner
        vm.expectRevert(SolarArrayComponentsNftFactory.SolarArrayComponentsNftFactory__MustBeCollectionOwner.selector);
        vm.prank(nonOwner);
        nftFactory.mintBatch(nonOwner, collection1, components, ids, amounts, "");
    }

}
