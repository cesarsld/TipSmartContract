pragma solidity ^0.6.4;

import "./ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract TipContract is Ownable
{
	using SafeMath for uint256;

	uint256 public etherBalance;
	mapping(address => uint256) public balances;
	mapping(address => uint256) public fees;

	event DiscordDeposit(address tokenContract, uint256 amount, uint64 indexed discordId);
	event DiscordWithdrawal(address tokenContract, uint256 amount, address recipient, uint64 indexed discordId);

	function depositEther(uint64 discordId) external payable
	{
		etherBalance = etherBalance.add(msg.value);
		emit DiscordDeposit(address(0), msg.value, discordId);
	}

	function withdrawEther(uint256 amount, uint256 fee, address payable recipient, uint64 discordId) public onlyOperator
	{
		require(etherBalance > amount.add(fee), "Unsufficient funds.");
		etherBalance = etherBalance.sub(fee);
		etherBalance = etherBalance.sub(amount);
		recipient.transfer(amount);
		emit  DiscordWithdrawal(address(0), amount, recipient, discordId);
	}

	function depositToken(uint256 amount, address tokenContract, uint64 discordId) external
	{
		require (IERC20(tokenContract).transferFrom(msg.sender, address(this), amount), "Transfer from function failed.");
		balances[tokenContract] = balances[tokenContract].add(amount);
		emit DiscordDeposit(tokenContract, amount, discordId);
	}

	function withdrawToken(uint256 amount, uint256 fee, address tokenContract, address recipient, uint64 discordId) public onlyOperator
	{
		require (IERC20(tokenContract).transfer(recipient, amount.sub(fee)), "Transfer function failed.");
		balances[tokenContract] = balances[tokenContract].sub(amount.add(fee));
		fees[tokenContract] = fees[tokenContract].add(fee);
		emit DiscordWithdrawal(tokenContract, amount, recipient, discordId);
	}

	function withdrawFees(address recipient, address tokenContract) public onlyOwner returns (bool)
	{
		require (fees[tokenContract] > 0, "Balance is empty.");
		require (IERC20(tokenContract).transfer(recipient, fees[tokenContract]), "Transfer function failed.");
		fees[tokenContract] = 0;
		return true;
	}

	function syphonEther(uint256 amount) public onlyOperator
	{
		require (amount < address(this).balance.sub(etherBalance), "Amount is higher than ether balance");
		owner.transfer(amount);
	}
}