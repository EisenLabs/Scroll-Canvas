// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";

import {EAS} from "@eas/contracts/EAS.sol";
import {EMPTY_UID, NO_EXPIRATION_TIME} from "@eas/contracts/Common.sol";
import {ISchemaResolver} from "@eas/contracts/resolver/ISchemaResolver.sol";
import {SchemaRegistry, ISchemaRegistry} from "@eas/contracts/SchemaRegistry.sol";

import {IEAS, AttestationRequest, AttestationRequestData, RevocationRequest, RevocationRequestData} from "@eas/contracts/IEAS.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ScrollBadgeResolver} from "../src/resolver/ScrollBadgeResolver.sol";
import {ProfileRegistry} from "../src/profile/ProfileRegistry.sol";
import {console} from "forge-std/console.sol";

contract ScrollBadgeTestBase is Test {
    ISchemaRegistry internal registry;
    IEAS internal eas;
    ScrollBadgeResolver internal resolver;

    bytes32 schema;

    address internal constant alice = address(1);
    address internal constant bob = address(2);

    address internal constant PROXY_ADMIN_ADDRESS = 0x2000000000000000000000000000000000000000;

    function setUp() public virtual {
        vm.createSelectFork(vm.envString("SCROLL_MAINNET_RPC_URL"));
        // EAS infra
        registry = SchemaRegistry(vm.envAddress("SCROLL_MAINNET_EAS_SCHEMA_REGISTRY_ADDRESS"));
        console.log("registry", address(registry));
        eas = EAS(vm.envAddress("SCROLL_MAINNET_EAS_ADDRESS"));
        console.log("eas", address(eas));
        // Scroll components
        // no need to initialize the registry, since resolver
        // only uses it to see if a profile has been minted or not.
        address profileRegistry = address(vm.envAddress("SCROLL_MAINNET_PROFILE_REGISTRY_ADDRESS"));
        console.log("profileRegistry", profileRegistry);
        address resolverImpl; // = address(new ScrollBadgeResolver(address(eas), profileRegistry));
        address resolverProxy; // = address(new TransparentUpgradeableProxy(resolverImpl, PROXY_ADMIN_ADDRESS, ""));
        resolver = ScrollBadgeResolver(payable(vm.envAddress("SCROLL_MAINNET_BADGE_RESOLVER_ADDRESS")));
        // resolver.initialize();
        console.log("resolver", address(resolver));

        schema = vm.envBytes32("SCROLL_MAINNET_BADGE_SCHEMA");
        console.logBytes32(schema);

        address owner = resolver.owner();
        vm.startPrank(owner);
        resolver.toggleBadge(address(0xb355D013857Ec0862499e5Deb97CB4A6A021a756), true);
        resolver.toggleWhitelist(false);
        vm.stopPrank();
    }

    function _attest(address badge, bytes memory payload, address recipient) internal returns (bytes32) {
        bytes memory attestationData = abi.encode(badge, payload);

        AttestationRequestData memory _attData = AttestationRequestData({
            recipient: recipient,
            expirationTime: NO_EXPIRATION_TIME,
            revocable: true,
            refUID: EMPTY_UID,
            data: attestationData,
            value: 0
        });

        AttestationRequest memory _req = AttestationRequest({schema: schema, data: _attData});

        return eas.attest(_req);
    }

    function _revoke(bytes32 uid) internal {
        RevocationRequestData memory _data = RevocationRequestData({uid: uid, value: 0});

        RevocationRequest memory _req = RevocationRequest({schema: schema, data: _data});

        eas.revoke(_req);
    }
}
