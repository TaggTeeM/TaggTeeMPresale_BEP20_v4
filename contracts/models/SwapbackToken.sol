/*
 * Copyright © 2022 TaggTeem. ALL RIGHTS RESERVED.
 */

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/AccessControl.sol";

import "../interfaces/ITaggTeeM.sol";

import "../../libraries/Constants.sol";

///
/// @title TaggTeeM (TTM) token SWAPBACKTOKEN contract
///
/// @author John Daugherty
///
contract SwapbackToken is AccessControl {
    // settings for swapback
    address private _swapbackTargetContractAddress;
    ITaggTeeM private _swapbackTargetContract;
    bool private _swapbackEnabled = false;

    function swapbackTargetContractAddress()
    internal
    view
    returns (address)
    {
        return _swapbackTargetContractAddress;
    }

    function swapbackEnabled()
    internal
    view
    returns (bool)
    {
        return _swapbackEnabled;
    }

    function swapbackTargetContract()
    internal
    view
    returns (ITaggTeeM)
    {
        return _swapbackTargetContract;
    }

    /// @notice Updates the swapback contract address target address.
    ///
    /// @dev Checks that the new contract address address is not 0, then sets the contract address address.
    ///
    /// Requirements:
    /// - Must have SWAPBACK_ADMIN role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @param newSwapbackTargetContractAddress The new contract address address.
    /// @return Whether the swapback target contract address was successfully set.
    function setSwapbackTargetContractAddress(address newSwapbackTargetContractAddress) 
    public
    onlyRole(Constants.SWAPBACK_ADMIN)
    returns (bool)
    {
        // require that the new target contract address is not 0
        require (newSwapbackTargetContractAddress != address(0), "TTP: Swapback address cannot be 0.");

        // update target contract address
        _swapbackTargetContractAddress = newSwapbackTargetContractAddress;
        _swapbackTargetContract = ITaggTeeM(_swapbackTargetContractAddress);

        return true;
    }

    /// @notice Gets the current active swapback target contract address.
    ///
    /// Requirements:
    /// - Must have SWAPBACK_ADMIN role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @return The current swapback target contract address.
    function getSwapbackTargetContractAddress() 
    public
    view
    onlyRole(Constants.SWAPBACK_ADMIN)
    returns (address)
    {
        return swapbackTargetContractAddress();
    }

    /// @notice Enables or disabled token swapback.
    ///
    /// @dev Sets the swapback enabled flag.
    ///
    /// Requirements:
    /// - Must have SWAPBACK_ADMIN role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @param isSwapbackEnabled Whether swapback is enabled.
    /// @return Whether the swapback was successfully enabled/disabled.
    function setSwapbackEnabled(bool isSwapbackEnabled) 
    public
    onlyRole(Constants.SWAPBACK_ADMIN)
    returns (bool)
    {
        // update enabled
        _swapbackEnabled = isSwapbackEnabled;

        return true;
    }

    /// @notice Gets the current state of the swapback enable flag.
    ///
    /// Requirements:
    /// - Must have SWAPBACK_ADMIN role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @return The current swapback enable flag.
    function getSwapbackEnabled() 
    public
    view
    onlyRole(Constants.SWAPBACK_ADMIN)
    returns (bool)
    {
        return swapbackEnabled();
    }

    /// @notice Returns all swapback coins to the owner.
    ///
    /// Requirements:
    /// - Must have SWAPBACK_ADMIN role.
    ///
    /// Caveats:
    /// - .
    ///
    /// @param owner The address of the owner's contract address to return tokens to.
    /// @return Whether the coins were successfully returned.
    function returnSwapbackCoins(address owner) 
    public
    onlyRole(Constants.SWAPBACK_ADMIN)
    returns (bool)
    {
        // get this contract's balance
        uint contractBalance = _swapbackTargetContract.balanceOf(address(this));

        // return it back to the owner
        _swapbackTargetContract.transfer(owner, contractBalance);

        return true;
    }
}