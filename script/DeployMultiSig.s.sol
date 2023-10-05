// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import {MultiSig} from "../src/MultiSig.sol";

contract DeployMultiSig is Script {
    error DeployMultiSig__invalid_number_of_required_sigs(uint256 required, uint256 actual);
    error DeployMultiSig__0_sigsRequired(uint256 required);
    error DeployMultiSig__invalid_number_of_owners(uint256 required, uint256 actual);

    address[] public owners;
    uint256 public sigsRequired;

    function run() external returns (MultiSig) {
        vm.startBroadcast();
        MultiSig multiSig = new MultiSig(owners,sigsRequired);
        vm.stopBroadcast();
        return (multiSig);
    }

    function setOwnersAndSigs(address[] memory _owners, uint256 _sigsRequired) public {
        if (_owners.length == 0) {
            revert DeployMultiSig__invalid_number_of_owners(1, _owners.length);
        }
        for (uint256 i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
        }
        if (_sigsRequired > owners.length) {
            revert DeployMultiSig__invalid_number_of_required_sigs(_sigsRequired, owners.length);
        }
        if (_sigsRequired == 0) {
            revert DeployMultiSig__0_sigsRequired(_sigsRequired);
        }
        sigsRequired = _sigsRequired;
    }
}
