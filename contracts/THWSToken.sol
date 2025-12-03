// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract THWSToken is ERC20, Ownable {

    constructor() ERC20("THWS Token", "THWS") Ownable(msg.sender) {
        // İstersen ilk mint burada yapılabilir
        // _mint(msg.sender, 100000 * 10 ** decimals());
    }

    /// @notice decimals override to 2 decimals
    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
