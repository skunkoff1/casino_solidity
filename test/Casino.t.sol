// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Casino} from "../src/Casino.sol";

contract CasinoTest is Test {
    address bank = makeAddr("bank");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");
    address user6 = makeAddr("user6");
    address user7 = makeAddr("user7");
    address user8 = makeAddr("user8");
    Casino public casino;

    function setUp() public {
        vm.startPrank(bank);
        casino = new Casino();
        vm.stopPrank();
    }

    function test_bet() public {
        uint8 number = 1;
        // uint256 balanceBefore = address(user1).balance;
        // vm.assume(msg.value = 2);
        hoax(user1, 1 ether);
        casino.bet{value: 0.001 ether}(number);
        assertEq(casino.balanceOfBank(), 0.001 ether);
    }

    function test_round() public {
        hoax(user1, 1 ether);
        casino.bet{value: 0.015 ether}(1);
        casino.bet{value: 0.003 ether}(3);

        hoax(user2, 1 ether);
        casino.bet{value: 0.006 ether}(2);

        hoax(user3, 1 ether);
        casino.bet{value: 0.008 ether}(3);
        casino.bet{value: 0.008 ether}(7);

        hoax(user4, 1 ether);
        casino.bet{value: 0.02 ether}(5);

        hoax(user5, 1 ether);
        casino.bet{value: 0.015 ether}(6);

        hoax(user6, 1 ether);
        casino.bet{value: 0.015 ether}(2);

        hoax(user7, 1 ether);
        casino.bet{value: 0.005 ether}(2);

        hoax(user8, 1 ether);
        casino.bet{value: 0.005 ether}(2);

        // 10 mises en tout -> valeur : 0.1 ether
        // 5% de commission
        // la banque doit donc avoir 0.005 ether
        assertEq(casino.balanceOfBank(), 0.005 ether);
        assertEq(casino.getBalance(user2), 1.01775 ether);
    }
}
