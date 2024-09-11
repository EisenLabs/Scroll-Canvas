// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ScrollBadgeTestBase} from "./ScrollBadgeTestBase.sol";

import {EMPTY_UID, NO_EXPIRATION_TIME} from "@eas/contracts/Common.sol";
import {Attestation, AttestationRequest, AttestationRequestData} from "@eas/contracts/IEAS.sol";

import {EisenBadge} from "../src/badge/examples/EisenBadge.sol";
import {AttestationBadgeMismatch, Unauthorized} from "../src/Errors.sol";
import {console} from "forge-std/console.sol";

contract EisenBadgeTest is ScrollBadgeTestBase {
    EisenBadge internal badge;

    function setUp() public virtual override {
        super.setUp();
        badge = EisenBadge(0xb355D013857Ec0862499e5Deb97CB4A6A021a756);
        console.log("toggleBadge", address(badge));

        // address owner = resolver.owner();
        // console.log("owner", owner);
        // deal(owner, 1 ether);
        // vm.startPrank(owner);
        // resolver.toggleBadge(address(badge), true);
        // vm.stopPrank();
    }

    function testGetBadge() external {
        address attesterProxy = address(0xB3fAf6dB995a063d020c3e4FcfBfdAa3F4e3e54e);

        address recipient = address(0x63CA0543b2937A5DAA8594BF596B076f2f1Ee7AC);
        address owner = address(0xdAf87a186345f26d107d000fAD351E79Ff696d2C);
        vm.startPrank(recipient);
        deal(recipient, 1 ether);

        bytes
            memory txBytes = hex"3c0427150000000000000000000000000000000000000000000000000000000000000020d57de4f41c3d3cc855eadef68f98c0d4edd22d57161d96b7c06d2f4336cc3b4900000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000001b7366deaa3c01d4274b4a74a272e48e416d8aaab27fd682598f3d64f2fcec88f431139cfb8bea897730bcb1ff766b13cdda49db23c8267ffc1b60e3a6037ecf9300000000000000000000000060bf513f1c13d8ebad77738facc76231294758850000000000000000000000000000000000000000000000000000000066c2570d00000000000000000000000063ca0543b2937a5daa8594bf596b076f2f1ee7ac00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000b355d013857ec0862499e5deb97cb4a6a021a7560000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000003e307836336361303534336232393337613564616138353934626635393662303736663266316565376163206861732073776170706564206f7665722031300000";

        (bool success, bytes memory outputs) = attesterProxy.call(txBytes);
        assertEq(success, true);

        // bytes32 uid = _attest(address(badge), "", recipient);
        // console.log(badge.badgeTokenURI(uid));
    }
}
