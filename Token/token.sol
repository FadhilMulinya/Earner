// SPDX-License-Identifier: MIT

pragma solidity 0.8.28; 

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EarnerToken 
 * @dev A simple meme coin token contract for educational purposes
 * @dev Don't use on a commercial scale as it is not audited.
 */

contract EarnerToken is ERC20, Ownable {
    // Events to track token transfers, burns and mints
    event TokensSent(address indexed from, address indexed to, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMinted(address indexed recipient, uint256 amount);

    // Maximum supply of tokens (21 million with 18 decimals)
    uint256 public constant MAX_SUPPLY =  21_000_000e18
;

    constructor() ERC20("Earner Token","ENT") Ownable(msg.sender) {
        // Mint initial supply to contract deployer (2 million tokens)
        _mint(msg.sender, 2_000_000e18);
    }
    /**
     * @dev Owner can mint new tokens up to MAX_SUPPLY
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(totalSupply() + amount <= MAX_SUPPLY, "Would exceed max supply");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Allows users to burn their own tokens
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        require(amount > 0, "Cannot burn zero tokens");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to burn");

        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }


    /**
     * @dev Get token information
     * @return _name Token name
     * @return _symbol Token symbol
     * @return _decimals Token decimals
     * @return _supply Current total supply
     */
    function getTokenInfo() public view returns (
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply
    ) {
        return (
            name(),
            symbol(),
            decimals(),
            totalSupply()
        );
    }
}
