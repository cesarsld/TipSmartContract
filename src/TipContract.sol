pragma solidity ^0.6.4;

import "./ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract TipContract is Ownable
{
	using SafeMath for uint256;

	mapping(address => uint256) public balances;

	event DiscordDeposit(address tokenContract, uint256 amount, uint64 discordId);

	function viewBalanceOf(address tokenContract)  external view returns (uint256)
	{
		return balances[tokenContract];
	}

	function depositToken(uint256 amount, address tokenContract, uint64 discordId) external
	{
		require(IERC20(tokenContract).transferFrom(msg.sender, address(this), amount), "Transfer from function failed.");
		balances[tokenContract].add(amount);
		emit DiscordDeposit(tokenContract, amount, discordId);
	}

	function withdrawToken(uint256 amount, uint256 fee, address tokenContract, address recipient) public onlyOwner
	{
		require(IERC20(tokenContract).transfer(recipient, amount), "Transfer function failed.");
		balances[tokenContract].sub(amount.add(fee));
	}
}