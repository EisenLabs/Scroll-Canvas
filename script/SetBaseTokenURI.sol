// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {Attestation, IEAS} from "@eas/contracts/IEAS.sol";

import {AttesterProxy} from "../src/AttesterProxy.sol";
import {EisenBadge} from "../src/badge/examples/EisenBadge.sol";
import {ScrollBadgeResolver} from "../src/resolver/ScrollBadgeResolver.sol";

contract SetBaseTokenURI is Script {
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

        address[4] memory badges = [
            0xb355D013857Ec0862499e5Deb97CB4A6A021a756,
            0xddF3EC3B407af443e93feBA2cFa4AdE7a7Bf6EA6,
            0x9EF9f58346F958E11F26205EDAEDa36121D9a181,
            0x1c0e88E6488066cB0a2e4DCC865331F806A65416
        ];

        string[4] memory descriptions = [
            "This badge is awarded to users who have completed a swap of more than $10 in value on Scroll via Eisen. Start your journey on Eisen with this beginner-level badge and showcase your first step into the world of decentralized finance.",
            "Earn this badge by completing a swap of more than $500 in value on Scroll via Eisen. The Explorer Badge signifies your growing experience and commitment to navigating the Eisen ecosystem.",
            "This badge represents that the user completed swaps on Scroll via Eisen, totaling over $3,000 in value. As a Navigator, you demonstrate your proficiency in leveraging the Eisen platform to achieve your financial goals.",
            "Achieve the prestigious Pioneer Badge by executing swaps totaling over $5,000 in value on Scroll via Eisen. This badge marks you as a trailblazer in the Eisen ecosystem, recognizing your advanced level of participation and influence."
        ];

        string[4] memory names = [
            "Eisen Tier 4 : Beginner",
            "Eisen Tier 3 : Explorer",
            "Eisen Tier 2 : Navigator",
            "Eisen Tier 1 : Pioneer"
        ];
        string[4] memory images = [
            "https://static.eisenfinance.com/scroll/scroll-canvas-1.png",
            "https://static.eisenfinance.com/scroll/scroll-canvas-2.png",
            "https://static.eisenfinance.com/scroll/scroll-canvas-3.png",
            "https://static.eisenfinance.com/scroll/scroll-canvas-4.png"
        ];

        for (uint256 i; i < badges.length; i++) {
            EisenBadge badge = EisenBadge(badges[i]);
            string memory name = names[i];
            string memory description = descriptions[i];
            string memory image = images[i];
            string memory tokenUriJson = Base64.encode(
                bytes(
                    abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', image, '"}')
                )
            );
            badge.setBaseTokenURI(string(abi.encodePacked("data:application/json;base64,", tokenUriJson)));
        }
        vm.stopBroadcast();
    }

    function logAddress(string memory name, address addr) internal view {
        console.log(string(abi.encodePacked(name, "=", vm.toString(address(addr)))));
    }
}
