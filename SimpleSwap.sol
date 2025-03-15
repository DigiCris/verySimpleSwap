// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ERC20Factory.sol";

interface IERC20 {

    //agregada para que los tokens puedan mintearse
    function mint(uint256 quantity, address who) external;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface router {
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] memory path, address to, uint256 deadline) external returns(uint256[] memory);
}

contract SimpleSwap is router {
    IERC20 public tokenA;
    IERC20 public tokenB;


    constructor() {
        EdItcoin addr = new EdItcoin("Theter","USDT");
        tokenA = IERC20(address(addr));
        addr = new EdItcoin("EducationCoin","EDIT");
        tokenB = IERC20(address(addr));
        tokenA.mint(100000, address(this));
        tokenB.mint(100000, address(this));
        tokenA.mint(10000, msg.sender);
    }

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] memory path, address to, uint256 deadline) external returns(uint256[] memory) {
        require(deadline >= block.timestamp,"time error");

        IERC20 tokenX = IERC20(path[0]);
        IERC20 tokenY = IERC20(path[1]);
        uint256 x = tokenX.balanceOf(address(this));
        uint256 y = tokenY.balanceOf(address(this));
        uint256 dx = amountIn; // lo que yo doy
        uint256 dy = y - ((x*y)/(x+dx)); // contrato me da

        require(dy >= amountOutMin,"slipage");

        tokenX.transferFrom(msg.sender, address(this), dx);
        tokenY.transfer(to, dy);

        uint256[] memory amounts = new uint256[](2); 
        amounts[0] = dx;
        amounts[1] = dy;

        return amounts;
    }

    function QuoteSwapExactTokensForTokens(uint256 amountIn, address[] memory path) external view returns(uint256, uint256) {
        IERC20 tokenX = IERC20(path[0]);
        IERC20 tokenY = IERC20(path[1]);
        uint256 x = tokenX.balanceOf(address(this));
        uint256 y = tokenY.balanceOf(address(this));
        uint256 dx = amountIn; // lo que yo doy
        uint256 dy = y - ((x*y)/(x+dx)); // contrato me da
        return(dx,dy);
    }

}
