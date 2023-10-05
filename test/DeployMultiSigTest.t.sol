// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {MultiSig} from "../src/MultiSig.sol";
import {DeployMultiSig} from "../script/DeployMultiSig.s.sol";

contract DeployMultiSigTest is Test {
    function test_DeployMultiSig() public {
        address[] memory owners = new address[](4);
        owners[0] = 0xaaa3ED7b39A06E09C38ddf2252FB483AC9cDDC46;
        owners[1] = 0xbbba75883E6d0fa5a7582208FfB1c16d3C802C89;
        owners[2] = 0xcccC54228D6e98f500bBD5CD864Df5493aF89Fc4;
        owners[3] = 0xddd2652AbcFA7a1Da38Bd156728A64053C5899A1;
        uint256 sigsRequired = 2;
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.setOwnersAndSigs(owners, sigsRequired);
        MultiSig multiSig = deployMultiSig.run();
        vm.deal(address(multiSig), 200 ether);
    }

    function testFail_VarsNotSet() public {
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.run();
    }

    function testFail_NoRequiredSigs() public {
        address[] memory owners = new address[](4);
        owners[0] = 0xaaa3ED7b39A06E09C38ddf2252FB483AC9cDDC46;
        owners[1] = 0xbbba75883E6d0fa5a7582208FfB1c16d3C802C89;
        owners[2] = 0xcccC54228D6e98f500bBD5CD864Df5493aF89Fc4;
        owners[3] = 0xddd2652AbcFA7a1Da38Bd156728A64053C5899A1;
        uint256 sigsRequired = 0;
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.setOwnersAndSigs(owners, sigsRequired);
        deployMultiSig.run();
    }

    function testFail_MoreRequiredSigsThanOwners() public {
        address[] memory owners = new address[](4);
        owners[0] = 0xaaa3ED7b39A06E09C38ddf2252FB483AC9cDDC46;
        owners[1] = 0xbbba75883E6d0fa5a7582208FfB1c16d3C802C89;
        owners[2] = 0xcccC54228D6e98f500bBD5CD864Df5493aF89Fc4;
        owners[3] = 0xddd2652AbcFA7a1Da38Bd156728A64053C5899A1;
        uint256 sigsRequired = 6;
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.setOwnersAndSigs(owners, sigsRequired);
        deployMultiSig.run();
    }

    function testFail_NoOwners() public {
        address[] memory owners = new address[](0);
        uint256 sigsRequired = 1;
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.setOwnersAndSigs(owners, sigsRequired);
        deployMultiSig.run();
    }
}
