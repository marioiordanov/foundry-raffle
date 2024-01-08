// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CreateSubscription, FundSubscription} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract InteractionsTest is Test {
    uint256 public constant ANVIL_CHAIN_ID = 31337;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;

    modifier onlySepolia() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            _;
        }
    }

    modifier onlyAnvil() {
        if (block.chainid == ANVIL_CHAIN_ID) {
            _;
        }
    }

    ////////////////////////
    // createSubscription //
    ////////////////////////
    function testAnvilNetworkCreateSubscriptionUsingConfigCompletesSuccessfully()
        public
        onlyAnvil
    {
        CreateSubscription createSubscription = new CreateSubscription();
        uint64 subscriptionId = createSubscription
            .createSubscriptionUsingConfig();
        assert(subscriptionId == 1);
    }

    function testSepoliaNetworkCreateSubscriptionUsingConfigCompletesSuccessfully()
        public
        onlySepolia
    {
        CreateSubscription createSubscription = new CreateSubscription();
        uint64 subscriptionId = createSubscription
            .createSubscriptionUsingConfig();
        assert(subscriptionId > 0);
    }

    function testCreateSubscriptionFailsWhenUsingNonExistingCoordinator(
        address randomAddress
    ) public {
        CreateSubscription createSubscription = new CreateSubscription();
        HelperConfig helperConfig = new HelperConfig();
        (, , address coordinator, , , , , uint256 deployerKey) = helperConfig
            .activeNetworkConfig();

        if (randomAddress != coordinator) {
            console.log("Random address: ", randomAddress);
            vm.expectRevert();
            createSubscription.createSubscription(randomAddress, deployerKey);
        }
    }

    //////////////////////
    // fundSubscription //
    //////////////////////
    function testOnAnvilFundSubscriptionUsingConfigCompletesSuccessfully()
        public
        onlyAnvil
    {
        CreateSubscription create = new CreateSubscription();
        HelperConfig config = new HelperConfig();
        (
            ,
            ,
            address coordinator,
            ,
            ,
            ,
            address linkToken,
            uint256 deployerKey
        ) = config.activeNetworkConfig();
        uint64 subscriptionId = create.createSubscription(
            coordinator,
            deployerKey
        );

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            coordinator,
            subscriptionId,
            linkToken,
            deployerKey
        );
    }

    //////////////////
    // DeployRaffle //
    //////////////////

    function testRaffleDeploymentIfSubscriptionIdFromConfigIsZeroItShouldCreateASubscription()
        public
    {
        (, , , , uint64 subscriptionId, , , ) = new HelperConfig()
            .activeNetworkConfig();
        DeployRaffle deployScript = new DeployRaffle();

        if (subscriptionId == 0) {
            vm.recordLogs();
            deployScript.run();
            Vm.Log[] memory entries = vm.getRecordedLogs();
            bytes32 newSubscriptionId = entries[1].topics[1];

            console.log("New subscription id: ", uint256(newSubscriptionId));
            assert(subscriptionId != uint256(newSubscriptionId));
        }
    }

    function testRaffleDeploymentIfSubscriptionIsNotZero() public {
        (, , , , uint64 subscriptionId, , , ) = new HelperConfig()
            .activeNetworkConfig();
        DeployRaffle deployScript = new DeployRaffle();

        if (subscriptionId != 0) {
            deployScript.run();
        }
    }
}
