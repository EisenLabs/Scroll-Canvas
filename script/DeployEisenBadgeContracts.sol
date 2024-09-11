// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Attestation, IEAS} from "@eas/contracts/IEAS.sol";

import {AttesterProxy} from "../src/AttesterProxy.sol";
import {EisenBadge} from "../src/badge/examples/EisenBadge.sol";
import {ScrollBadgeResolver} from "../src/resolver/ScrollBadgeResolver.sol";

contract DeployEisenBadgeContracts is Script {
    uint256 DEPLOYER_PRIVATE_KEY = vm.envUint("DEPLOYER_PRIVATE_KEY");
    bool IS_MAINNET = vm.envBool("IS_MAINNET");

    address RESOLVER_ADDRESS =
        IS_MAINNET
            ? vm.envAddress("SCROLL_MAINNET_BADGE_RESOLVER_ADDRESS")
            : vm.envAddress("SCROLL_SEPOLIA_BADGE_RESOLVER_ADDRESS");

    address EAS_ADDRESS =
        IS_MAINNET ? vm.envAddress("SCROLL_MAINNET_EAS_ADDRESS") : vm.envAddress("SCROLL_SEPOLIA_EAS_ADDRESS");

    address SIGNER_ADDRESS = vm.addr(vm.envUint("SIGNER_PRIVATE_KEY"));

    function run() external {
        vm.startBroadcast(DEPLOYER_PRIVATE_KEY);

        ScrollBadgeResolver resolver = ScrollBadgeResolver(payable(RESOLVER_ADDRESS));
        // deploy test badges
        EisenBadge badge1 = new EisenBadge(
            "Eisen Hiker Level 1",
            "Eisen Lv.1",
            "https://static.eisenfinance.com/scroll/scroll-canvas-1.png",
            address(resolver)
        );

        EisenBadge badge2 = new EisenBadge(
            "Eisen Hiker Level 2",
            "Eisen Lv.2",
            "https://static.eisenfinance.com/scroll/scroll-canvas-2.png",
            address(resolver)
        );

        EisenBadge badge3 = new EisenBadge(
            "Eisen Hiker Level 3",
            "Eisen Lv.3",
            "https://static.eisenfinance.com/scroll/scroll-canvas-3.png",
            address(resolver)
        );

        EisenBadge badge4 = new EisenBadge(
            "Eisen Hiker Level 4",
            "Eisen Lv.4",
            "https://static.eisenfinance.com/scroll/scroll-canvas-4.png",
            address(resolver)
        );

        AttesterProxy attesterProxy = new AttesterProxy(IEAS(EAS_ADDRESS));
        attesterProxy.toggleAttester(SIGNER_ADDRESS, true);

        // set permissions
        resolver.toggleBadge(address(badge1), true);
        resolver.toggleBadge(address(badge2), true);
        resolver.toggleBadge(address(badge3), true);
        resolver.toggleBadge(address(badge4), true);

        // log addresses
        logAddress("DEPLOYER_ADDRESS", vm.addr(DEPLOYER_PRIVATE_KEY));
        logAddress("SIMPLE_BADGE_A_CONTRACT_ADDRESS", address(badge1));
        logAddress("SIMPLE_BADGE_B_CONTRACT_ADDRESS", address(badge2));
        logAddress("SIMPLE_BADGE_C_CONTRACT_ADDRESS", address(badge3));
        logAddress("SIMPLE_BADGE_D_CONTRACT_ADDRESS", address(badge4));
        logAddress("ATTESTER_PROXY_ADDRESS", address(attesterProxy));

        vm.stopBroadcast();
    }

    function logAddress(string memory name, address addr) internal view {
        console.log(string(abi.encodePacked(name, "=", vm.toString(address(addr)))));
    }
}
