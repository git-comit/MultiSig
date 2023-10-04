// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import {MultiSig} from "../src/MultiSig.sol";

contract DeployMultiSig is Script {
    address[] public owners;

    function run() external returns (MultiSig) {
        setOwners();
        uint256 sigsRequired = setSigsRequired(2);
        vm.startBroadcast();
        MultiSig multiSig = new MultiSig(owners,sigsRequired);
        vm.stopBroadcast();
        return (multiSig);
    }

    function setOwners() public {
        owners.push(0xaaa3ED7b39A06E09C38ddf2252FB483AC9cDDC46);
        owners.push(0xbbba75883E6d0fa5a7582208FfB1c16d3C802C89);
        owners.push(0xcccC54228D6e98f500bBD5CD864Df5493aF89Fc4);
        owners.push(0xddd2652AbcFA7a1Da38Bd156728A64053C5899A1);
    }

    function setSigsRequired(uint256 n) public pure returns (uint256 required) {
        required = n;
    }
}
