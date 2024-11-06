// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {IHubV2} from "src/hub/IHub.sol";

/**
 * @title Faucet contract for Rings (test version of Circles).
 * @notice The Faucet contract is the entrance for the Rings developers to self-register.
 */
contract Faucet {
    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/
    /// Registration status can be updated only by admin.
    error OnlyAdmin();
    /// Developer registration in Rings is currently closed by the admin.
    error RegistrationClosed();

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted on registration status update.
    /// @param closed True if registration was closed, False otherwise.
    event RegistrationStatusUpdated(bool closed);
    /// @notice Emitted on developer registration in Rings.
    /// @param developer Address of registered developer.
    event NewDeveloperRegistered(address developer);

    /*//////////////////////////////////////////////////////////////
                             CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Hub v2 contract for Rings (test version of Circles).
    IHubV2 public immutable HUB_V2;
    /// @dev Address, which is allowed to call setRegistrationStatus.
    address internal immutable ADMIN;

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @notice Flag indicating whether registration (registerAsDeveloper calls) is closed.
    bool public closed;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Constructor initialize immutables.
     * @param _hubV2 address of Hub v2 contract for Rings.
     * @param _admin address, which is allowed to call setRegistrationStatus.
     */
    constructor(address _hubV2, address _admin) payable {
        HUB_V2 = IHubV2(_hubV2);
        ADMIN = _admin;
    }

    /*//////////////////////////////////////////////////////////////
                          ADMINISTRATION LOGIC
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Method sets registration status, callable only by admin.
     * @param _closed True to close registration, False to open it.
     */
    function setRegistrationStatus(bool _closed) external {
        if (msg.sender != ADMIN) revert OnlyAdmin();
        closed = _closed;
        emit RegistrationStatusUpdated(_closed);
    }

    /*//////////////////////////////////////////////////////////////
                          REGISTRATION LOGIC
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Method registers developer in Rings. Developer receives avatar
     *         in Rings and developer bonus.
     * @dev Registration can be closed by admin.
     * @param _metadataDigest public launch metadata.
     */
    function registerAsDeveloper(bytes32 _metadataDigest) external {
        if (closed) revert RegistrationClosed();
        HUB_V2.registerDeveloper(msg.sender, _metadataDigest);
        emit NewDeveloperRegistered(msg.sender);
    }
}
