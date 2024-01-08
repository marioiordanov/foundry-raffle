// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkTokenMock.sol";
import {DevOpsTools} from "@foundry-devops/DevOpsTools.sol";

contract CreateSubscription is Script {
    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }

    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperCongig = new HelperConfig();
        (, , address coordinator, , , , , uint256 deployerKey) = helperCongig
            .activeNetworkConfig();
        return createSubscription(coordinator, deployerKey);
    }

    function createSubscription(
        address coordinator,
        uint256 deployerKey
    ) public returns (uint64) {
        console.log("Creating subscription on chain: ", block.chainid);
        vm.startBroadcast(deployerKey);
        uint64 subscriptionId = VRFCoordinatorV2Mock(coordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Subscription created with id: ", subscriptionId);
        console.log("Please update HelperConfig.s.sol");
        return subscriptionId;
    }
}

contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address coordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        fundSubscription(coordinator, subscriptionId, link, deployerKey);
    }

    function fundSubscription(
        address coordinator,
        uint64 subscriptionId,
        address linkToken,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription on sub id: ", subscriptionId);
        console.log("Using vrf coordinator: ", coordinator);
        console.log("On chain id: ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(coordinator).fundSubscription(
                subscriptionId,
                uint96(FUND_AMOUNT)
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerKey);
            LinkToken(linkToken).transferAndCall(
                coordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );

        addConsumerUsingConfig(raffle);
    }

    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address coordinator,
            ,
            uint64 subscriptionId,
            ,
            ,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        addConsumer(raffle, coordinator, subscriptionId, deployerKey);
    }

    function addConsumer(
        address raffle,
        address coordinator,
        uint64 subscriptionId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract ", raffle);
        console.log("Using vrf coordinator: ", coordinator);
        console.log("On chain id: ", block.chainid);

        vm.startBroadcast(deployerKey);

        VRFCoordinatorV2Mock(coordinator).addConsumer(subscriptionId, raffle);

        vm.stopBroadcast();
    }
}
