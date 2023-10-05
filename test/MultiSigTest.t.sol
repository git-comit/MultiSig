// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {MultiSig} from "../src/MultiSig.sol";
import {DeployMultiSig} from "../script/DeployMultiSig.s.sol";

contract MultiSigTest is Test {
    MultiSig multiSig;
    address[] owners;
    uint256 sigsRequired;

    function setUp() public {
        owners.push(0xaaa3ED7b39A06E09C38ddf2252FB483AC9cDDC46);
        owners.push(0xbbba75883E6d0fa5a7582208FfB1c16d3C802C89);
        owners.push(0xcccC54228D6e98f500bBD5CD864Df5493aF89Fc4);
        owners.push(0xddd2652AbcFA7a1Da38Bd156728A64053C5899A1);

        sigsRequired = 2;
        DeployMultiSig deployMultiSig = new DeployMultiSig();
        deployMultiSig.setOwnersAndSigs(owners, sigsRequired);
        multiSig = deployMultiSig.run();
        vm.deal(address(multiSig), 200 ether);
    }

    function test_Deposit() public {
        vm.deal(address(multiSig), 200 ether);
    }

    function testFail_SubmitNotOwner() public {
        address to = owners[0];
        multiSig.submit(to, 100 ether, "");
    }

    function test_Submit() public {
        for (uint256 i = 0; i < owners.length; i++) {
            vm.prank(owners[i]);
            multiSig.submit(owners[0], 100 ether, "");
        }
    }

    function testFail_ApproveNotOwner() public {
        address to = owners[0];
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
    }

    function testFail_ApproveNotSubmitted() public {
        multiSig.approve(0);
    }

    function testFail_ApproveAlreadyApproved() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
        multiSig.approve(0);
        vm.stopPrank();
    }

    function test_Approve() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
        vm.stopPrank();
    }

    function testFail_ExecuteNotApproved() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.execute(0);
        vm.stopPrank();
    }

    function testFail_ExecuteNotSubmitted() public {
        multiSig.execute(0);
    }

    function test_Execute() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
        vm.startPrank(owners[1]);
        multiSig.approve(0);
        multiSig.execute(0);
        vm.stopPrank();
        assertEq(address(multiSig).balance, 100 ether);
        assertEq(to.balance, 100 ether);
    }

    function testFail_ExecuteAlreadyExecuted() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
        vm.startPrank(owners[1]);
        multiSig.approve(0);
        multiSig.execute(0);
        multiSig.execute(0);
        vm.stopPrank();
    }

    function test_revoke() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.approve(0);
        multiSig.revoke(0);
        vm.stopPrank();
    }

    function testFail_revokeNotApproved() public {
        address to = owners[0];
        vm.startPrank(owners[0]);
        multiSig.submit(to, 100 ether, "");
        multiSig.revoke(0);
        vm.stopPrank();
    }
}
