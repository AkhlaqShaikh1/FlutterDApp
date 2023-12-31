// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyTest {
    int public balance;
    address owner;
    
    constructor() {
        balance = 0;
    }
    
    function deposit(int amount) public {
        balance += amount;
    }
    
    function withdraw(int amount) public {
        balance -= amount;
    }
}