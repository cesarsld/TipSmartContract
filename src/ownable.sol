pragma solidity ^0.6.4;

contract TipContract is Ownable {
	using SafeMath for uint256;

	uint256 public etherBalance;
	mapping(address => uint256) public fees;
	mapping(address => bool) whitelistedTokens;

	event DiscordDeposit(address indexed tokenContract, uint256 amount, uint64 indexed discordId);
	event DiscordWithdrawal(address indexed tokenContract, uint256 amount, address recipient, uint64 indexed discordId);

	function updateTokens(address[] calldata _tokens, bool _value) external onlyOwner {
		for (uint256 i = 0; i < _tokens.length; i++)
			whitelistedTokens[_tokens[i]]  =  _value;
	}

	function depositEther(uint64 discordId) external payable {
		etherBalance = etherBalance.add(msg.value);
		emit DiscordDeposit(address(0), msg.value, discordId);
	}

	function withdrawEther(uint256 amount, uint256 fee, address payable recipient, uint64 discordId) public onlyOperator {
		etherBalance = etherBalance.sub(fee);
		etherBalance = etherBalance.sub(amount);
		recipient.transfer(amount.sub(fee));
		emit  DiscordWithdrawal(address(0), amount.sub(fee), recipient, discordId);
	}

	function depositToken(uint256 amount, address tokenContract, uint64 discordId) external {
		require(whitelistedTokens[tokenContract], "TipContract: Token not whitelisted.");
		IERC20(tokenContract).transferFrom(msg.sender, address(this), amount);
		emit DiscordDeposit(tokenContract, amount, discordId);
	}

	function withdrawToken(uint256 amount, uint256 fee, address tokenContract, address recipient, uint64 discordId) public onlyOperator {
		fees[tokenContract] = fees[tokenContract].add(fee);
		IERC20(tokenContract).transfer(recipient, amount.sub(fee));
		emit DiscordWithdrawal(tokenContract, amount.sub(fee), recipient, discordId);
	}

	function withdrawFees(address tokenContract) public onlyOwner returns (bool) {
		require (fees[tokenContract] > 0, "TipContract: Balance is empty.");
		uint256 fee = fees[tokenContract];
		fees[tokenContract] = 0;
		return IERC20(tokenContract).transfer(owner, fee);
	}

	function syphonEther(uint256 amount) public onlyOperator {
		require (amount < address(this).balance.sub(etherBalance), "TipContract: Amount is higher than ether balance");
		owner.transfer(amount);
	}
}