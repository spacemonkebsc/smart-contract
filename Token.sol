pragma solidity ^0.6.12;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

// SPDX-License-Identifier: UNLICENSED

contract Token is ERC20 {
  uint BURN_TAX = 5;
  uint ADMIN_TAX = 5;
  address public admin;
  mapping(address => bool) public excludedFromTax;

  constructor() public ERC20('TOKEN', 'TKN') {
    _mint(msg.sender, 1000000 * 10 ** 18); 
    admin = msg.sender;
    excludedFromTax[msg.sender] = true;
  }

  function transfer(address recipient, uint256 amount) 
    public 
    override 
    returns (bool) {
    if(excludedFromTax[msg.sender] == true) { 
      _transfer(_msgSender(), recipient, amount);
    } else { 
      uint burnAmount = amount.mul(BURN_TAX) / 100;
      uint adminAmount = amount.mul(ADMIN_TAX) / 100;
      _burn(_msgSender(), burnAmount);
      _transfer(_msgSender(), admin, adminAmount);
      _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
    }
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) 
    public 
    override 
    returns (bool) {
    if(excludedFromTax[sender] == true) { 
      _transfer(sender, recipient, amount);
      _approve(
        sender, 
        _msgSender(), 
        allowance(sender, _msgSender()).sub(
          amount, 
          "ERC20: transfer amount exceeds allowance"
        )
      );
    } else {
      uint burnAmount = amount.mul(BURN_TAX) / 100;
      uint adminAmount = amount.mul(ADMIN_TAX) / 100;
      _burn(sender, burnAmount);
      _transfer(sender, admin, adminAmount);
      _transfer(sender, recipient, amount.sub(burnAmount).sub(adminAmount));
      _approve(
        sender, 
        _msgSender(),
        allowance(sender, _msgSender()).sub(
          amount.sub(burnAmount).sub(adminAmount), 
          "ERC20: transfer amount exceeds allowance"
        )
      );
    }
    return true;
  }

  function addExcludedFromTax(address excluded) external {
    require(msg.sender == admin, 'only admin');
    excludedFromTax[excluded] = true;
  }
}
