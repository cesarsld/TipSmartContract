pragma solidity ^0.6.4;

contract Ownable
{
	address payable public owner;
	address public operator;

	constructor() public
	{
		owner = msg.sender;
		operator = msg.sender;
	}

	modifier onlyOwner()
	{
		require(msg.sender == owner,
		"Sender not authorised to access.");
		_;
	}

	modifier onlyOperator()
	{
		require(msg.sender == owner || msg.sender == operator,
		"Sender not authorised to access.");
		_;
	}

	function transferOwnership(address payable newOwner) external onlyOwner
	{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

	function transferOperatorRights(address payable newOperator) external onlyOwner
	{
        if (newOperator != address(0)) {
            operator = newOperator;
        }
    }
}