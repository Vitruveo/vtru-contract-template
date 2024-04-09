// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Simple {

    uint stateValue = 0;
    
    event StateValueChanged(address indexed changedBy, uint value);

    constructor() {
    }

    function readState() external view returns(uint) {
        return stateValue;
    }

    function writeState(uint value) external {
        require(value > 0, "Value cannot be zero");

        stateValue = value;

        emit StateValueChanged(msg.sender, value);
    }
}