// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address admin;

    mapping (address account => uint256 balance) public  balanceOf;
    mapping (address owner => mapping (address spender => uint256 amount)) public _allowance;

    constructor(string memory _name, string memory _symbols, uint8 _decimals) {
        name = _name;
        symbol = _symbols;
        decimals = _decimals;
        admin = msg.sender;
    }

    // The contract uses raw arithmetic operations (e.g., +=, -=) for balanceOf, totalSupply, and _allowance 
    // without checks for overflow or underflow. Although Solidity ^0.8.0 includes built-in overflow checks.

    function allowance(address owner, address spender) external view returns (uint256) {
            return _allowance[owner][spender];
        }

    function transfer(address recipient, uint256 amount) external returns (bool){
        require(amount > 0, "Amount to be transfered must be greater than zero");
        require( balanceOf[msg.sender] >= amount, "Insufficient funds");
        require(msg.sender != address(0), "Invalid caller");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool){
        require(amount > 0, "Amount to be transfered must be greater than zero");
        require(balanceOf[owner] >= amount, "Insufficient funds");
        require(_allowance[owner][msg.sender] >= amount, "Insufficient allowance");
        require(msg.sender != address(0), "Invalid caller");

        _allowance[owner][msg.sender] -= amount;
        balanceOf[owner] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(owner, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        //1 approve function has exposed to reentrancy attack
        //2 it is possible to frontrun approval where the current non zero allowance is being used b4 the approve function
        //  implemented to change the allowance
        
        require(amount > 0, "Amount to be approved must be greater than zero");
        _allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) external returns (bool) {
        require(amount > 0, "Amount to be approved must be greater than zero");
        _allowance[msg.sender][spender] += amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) external returns (bool) {
        require(amount > 0, "Amount to be approved must be greater than zero");
        _allowance[msg.sender][spender] -= amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // functionality similar to what revoke.cash does

    function resetAllowance(address spender) external returns (bool) {
        _allowance[msg.sender][spender] -= 0;

        emit Approval(msg.sender, spender, 0);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }
    
    function _burn(address from, uint256 amount) internal  {
        require(balanceOf[from] >= amount, "Insufficient Funds");
        require(amount > 0, "Can't burn zero");

        balanceOf[from] -= amount;
        totalSupply -= amount;

        // the commented code could cause conflict in total and circulating supply
        // balanceOf[address(0)] += amount;

        emit Transfer(from, address(0), amount);

    }

    function mint(address to, uint256 amount) external  returns (bool) {
        require(msg.sender == admin, "Unauthorised");
        _mint(to, amount);

        return true;
    }

    function burn(address from, uint256 amount) external returns (bool) {
        require(msg.sender == admin, "Unauthorised");
        _burn(from, amount);

        return true;
    }

}