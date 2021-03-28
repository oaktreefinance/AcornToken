// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@pancakeswap-libs/pancake-swap-core/contracts/interfaces/IPancakePair.sol";


/**
 * @dev An Acorn LP token holder contract that will allow a beneficiary to extract the
 * tokens.
 */
contract Acornlock {
  // PancakePair basic token contract being held
  IPancakePair private _token;

  // beneficiary of tokens after they are released
  address private _beneficiary;

  // admin to call the contract
  address private _admin;

  constructor (IPancakePair token_, address beneficiary_, address admin_) public {
    _token = token_;
    _beneficiary = beneficiary_;
    _admin = admin_;
  }

  function setAdmin(address admin_) public {
        require(msg.sender == _admin, "Tokenlock: can only call by admin.");
        _admin = admin_;
    }

  /**
   * @return the token being held.
   */
  function token() public view virtual returns (IPancakePair) {
    return _token;
  }

  /**
   * @return the beneficiary of the tokens.
   */
  function beneficiary() public view virtual returns (address) {
    return _beneficiary;
  }


  /**
   * @return the admin of the lock.
   */
  function admin() public view virtual returns (address) {
    return _admin;
  }


  /**
   * @notice Transfers tokens held by lock to beneficiary.
   */
  function withdraw(uint256 _amount) public virtual {
    require(msg.sender == _admin, "Tokenlock: can only call by admin.");
    uint256 amount = token().balanceOf(address(this));
    require(amount > 0, "Tokenlock: no tokens to release");
    // if amount asking for is larger than all amount, send all amount.
    if(_amount >= amount){
      _amount = amount;
    }

    token().transfer(beneficiary(), _amount);
  }

   /**
   * @notice Transfers tokens held by lock to beneficiary.
   */
  function release() public virtual {
    require(msg.sender == _admin, "Tokenlock: can only call by admin.");
    uint256 amount = token().balanceOf(address(this));
    require(amount > 0, "Tokenlock: no tokens to release");

    token().transfer(beneficiary(), amount);
  }
}