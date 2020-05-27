pragma solidity ^0.6.4;

contract HasAdmin
{
	address payable public admin;

	constructor() public
	{
		admin = msg.sender;
	}

	modifier onlyAdmin()
	{
		require(msg.sender == admin,
		"Sender not authorised to access.");
		_;
	}
	function transferOwnership(address payable newAdmin) external onlyAdmin
	{
        if (newAdmin != address(0)) {
            admin = newAdmin;
        }
    }

	function removeAdmin() external onlyAdmin {
		admin = address(0);
	}

}