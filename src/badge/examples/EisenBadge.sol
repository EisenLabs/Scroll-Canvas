// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Attestation} from "@eas/contracts/IEAS.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ScrollBadgeAccessControl} from "../extensions/ScrollBadgeAccessControl.sol";
import {ScrollBadgeSingleton} from "../extensions/ScrollBadgeSingleton.sol";
import {ScrollBadgeSBT} from "../extensions/ScrollBadgeSBT.sol";
import {ScrollBadge} from "../ScrollBadge.sol";
import {ScrollBadgeNoExpiry} from "../extensions/ScrollBadgeNoExpiry.sol";
import {ScrollBadgeDefaultURI} from "../extensions/ScrollBadgeDefaultURI.sol";
import {Unauthorized} from "../../Errors.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title ScrollEisenBadge
/// @notice A simple badge that attests to the user's trade level.
contract EisenBadge is ScrollBadgeAccessControl, ScrollBadgeSingleton, ScrollBadgeSBT {
    string public sharedTokenURI;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory sharedTokenURI_,
        address resolver_
    ) ScrollBadge(resolver_) ScrollBadgeSBT(name_, symbol_) {
        sharedTokenURI = sharedTokenURI_;
    }

    /// @inheritdoc ScrollBadgeAccessControl
    function onIssueBadge(
        Attestation calldata attestation
    ) internal override(ScrollBadgeSBT, ScrollBadgeSingleton, ScrollBadgeAccessControl) returns (bool) {
        if (!super.onIssueBadge(attestation)) {
            return false;
        }

        return true;
    }

    /// @inheritdoc ScrollBadgeAccessControl
    function onRevokeBadge(
        Attestation calldata attestation
    ) internal override(ScrollBadgeAccessControl, ScrollBadgeSBT, ScrollBadgeSingleton) returns (bool) {
        return super.onRevokeBadge(attestation);
    }

    /// @inheritdoc ScrollBadge
    function badgeTokenURI(bytes32 uid) public view override(ScrollBadge) returns (string memory) {
        return sharedTokenURI;
    }

    function setBaseTokenURI(string memory tokenUri_) external onlyOwner {
        sharedTokenURI = tokenUri_;
    }

    function getBadgeTokenURI(bytes32 uid) internal view returns (string memory) {
        string memory _name = name();
        string memory description = "Scroll Level Badge";
        string memory image = badgeTokenURI(uid); // IPFS, HTTP, or data URL
        string memory tokenUriJson = Base64.encode(
            abi.encodePacked('{"name":"', _name, '", "description":"', description, '", "image": "', image, '"}')
        );
        return string(abi.encodePacked("data:application/json;base64,", tokenUriJson));
    }
}
