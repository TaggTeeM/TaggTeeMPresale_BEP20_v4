/*
 * Copyright © 2022 TaggTeem. ALL RIGHTS RESERVED.
 */

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./models/SwapbackToken.sol";

///
/// @title TaggTeeM (TTM) presale token BEP20 contract
///
/// @author John Daugherty
///
contract TaggTeeMPresale_BEP20_v4 is ERC20, ERC20Burnable, Pausable, AccessControl, Ownable, SwapbackToken {
    constructor () ERC20("TaggTeeMPresale", "TTP") {
        // grant token creator some basic permissions
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(Constants.MINTER_ROLE, _msgSender());
        grantRole(Constants.OWNER_ROLE, _msgSender());
        grantRole(Constants.PAUSER_ROLE, _msgSender());
        grantRole(Constants.SECURITY_ADMIN, _msgSender());
        grantRole(Constants.SWAPBACK_ADMIN, _msgSender());

        // reassign admin role for all roles to SECURITY_ADMIN
        setRoleAdmin(Constants.MINTER_ROLE, Constants.SECURITY_ADMIN);
        setRoleAdmin(Constants.OWNER_ROLE, Constants.SECURITY_ADMIN);
        setRoleAdmin(Constants.PAUSER_ROLE, Constants.SECURITY_ADMIN);
        setRoleAdmin(Constants.SECURITY_ADMIN, Constants.SECURITY_ADMIN);
        setRoleAdmin(Constants.SWAPBACK_ADMIN, Constants.SECURITY_ADMIN);

        // mint 25b tokens at 10^decimals() decimals
        _mint(_msgSender(), 25000000000 * 10 ** decimals());
    }

    /// @notice Pauses coin trading.
    ///
    /// @dev Calls parent pause function.
    function pause() 
    public 
    onlyRole(Constants.PAUSER_ROLE) 
    {
        _pause();
    }

    /// @notice Unpauses coin trading.
    ///
    /// @dev Calls parent unpause function.
    function unpause() 
    public 
    onlyRole(Constants.PAUSER_ROLE) 
    {
        _unpause();
    }

    /// @notice Mints new coins.
    ///
    /// @dev Calls parent minting function.
    function mint(address to,  uint256 amount) 
    public 
    onlyRole(Constants.MINTER_ROLE) 
    {
        _mint(to, amount);
    }

    /// @notice Destroys `amount` tokens, reducing the total supply.
    ///
    /// @dev Calls parent minting function.
    function burn(uint256 amount) 
    public 
    onlyRole(Constants.MINTER_ROLE) 
    override {
        super.burn(amount);
    }

    /// @notice Sets the admin role for a particular role. The admin role will have permissions to assign people to the role.
    ///           The DEFAULT_ADMIN_ROLE is the admin role for all roles by default.
    ///
    /// @dev Calls parent function.
    ///
    /// Requirements:
    /// - Must have DEFAULT_ADMIN_ROLE role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @param role The role to set the admin for.
    /// @param adminRole The admin role for the role specified.
    function setRoleAdmin(bytes32 role, bytes32 adminRole) 
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setRoleAdmin(role, adminRole);
    }

    /// @notice Performs appropriate swapback checks when transferring coins.
    ///
    /// @dev Checks swapback settings, attempts to transfer
    ///
    /// Requirements:
    /// - .
    ///
    /// Caveats:
    /// - .
    ///
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param amount The amount of coin to send to the provided address.
    function _transfer(address from, address to, uint256 amount)
    override
    internal
    whenNotPaused
    {
        if (to == address(this))
        {
            // if 'to' is owner address
            //   check if swapback is enabled and swapback wallet exists 
            //   transfer TTM from this contract's wallet to destination address
            //   burn from message sender's address

            require (swapbackEnabled(), "TTP: TTP -> TTM swapback is not enabled yet.");
            require (swapbackTargetWallet() != address(0), "TTP: TTP -> TTM swapback is not enabled yet.");

            // transfer exact amount of presale tokens
            swapbackTargetContract().presalesAirdrop(to, amount);

            // burn the TTP
            _burn(from, amount);
        }
        else
            super._transfer(from, to, amount); // regular transfer for everyone else
    }
}