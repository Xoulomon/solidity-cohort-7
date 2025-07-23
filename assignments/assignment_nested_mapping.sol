// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract allowanceMapping {

    mapping(address => mapping(address => uint)) private _allowance;

    //this function sets the spenders allowance
    function approval( address _addrSpender, uint allowance_value) public {
        _allowance[msg.sender][_addrSpender] = allowance_value;
    }

    //this function get the allowance value of spender
    function allowance(address _addrSpender) public view returns (uint) {
        return _allowance[msg.sender][_addrSpender];
    }
}