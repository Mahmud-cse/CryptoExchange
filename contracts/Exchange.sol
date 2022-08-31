// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Import this file to use console.log
import "hardhat/console.sol";
import "./Token.sol";

contract Exchange{
	address public feeAccount;
	uint256 public feePercent;
	mapping(address => mapping(address=>uint256))public tokens; 
	mapping(uint256 => _Order)public orders;
	uint256 public ordersCount;
	mapping(uint256 => bool)public orderCancelled; //true or false(boolean / bool)

	event Deposit(address token, address user, uint256 amount, uint256 balance);
	event Withdraw(address token, address user, uint256 amount, uint256 balance);

	event Order(
			uint256 id,
			address user, //User who made order
			address tokenGet,
			uint256 amountGet, //Amount they receive
			address tokenGive, //Address of token they give
			uint256 amountGive, //Amount they give
			uint256 timestamp
	);

	event Cancel(
			uint256 id,
			address user, //User who made order
			address tokenGet,
			uint256 amountGet, //Amount they receive
			address tokenGive, //Address of token they give
			uint256 amountGive, //Amount they give
			uint256 timestamp
	);

	struct _Order{
		// Attributes of an order
		uint256 id; //Unique identifier for order
		address user; //User who made order
		address tokenGet; //Address of the token they receive
		uint256 amountGet; //Amount they receive
		address tokenGive; //Address of token they give
		uint256 amountGive; //Amount they give
		uint256 timestamp; //When order was created
	}

	constructor(address _feeAccount, uint256 _feePercent){
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}

	// Deposit and Withdraw Tokens
	function depositToken(address _token, uint256 _amount) public {
		// Transfer tokens to exchange
		require(Token(_token).transferFrom(msg.sender,address(this),_amount));
		// Update User Balance
		tokens[_token][msg.sender] = tokens[_token][msg.sender]+_amount;
		// Emit an event
		emit Deposit(_token,msg.sender,_amount,tokens[_token][msg.sender]);

	}

	function withdrawToken(address _token, uint256 _amount) public{
		// Ensure user has enough tokens to withdraw
		require(tokens[_token][msg.sender] >= _amount);

		// Transfer tokens to the user
		Token(_token).transfer(msg.sender, _amount);

		// Update user balance
		tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;

		// Emit event
		emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	// Check Balances
	function balanceOf(address _token, address _user)public view returns (uint256){
		return tokens[_token][_user];
	}


	// Make and Cancel Orders

	function makeOrder(address _tokenGet,uint256 _amountGet, address _tokenGive, uint256 _amountGive)public{
		// Token Give(The token they want to spend)-Which token, and how much?
		// Token Get(The token they want to receive)-Which token, and how much?

		// Prevent orders if tokens aren't on exchange
		require(balanceOf(_tokenGive, msg.sender)>= _amountGive);

		// Create Order
		ordersCount = ordersCount+1;
		orders[ordersCount]=
		_Order(1, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive,  block.timestamp);

		// Emit event
		emit Order(
			ordersCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive,  block.timestamp
		);

	}

	function cancelOrder(uint256 _id)public{
		// Fetch Order
		_Order storage _order = orders[_id];

		// Cancel the order

		orderCancelled[_id] = true;

		// Ensure the caller of the function is the owner of the order

		require(address(_order.user) == msg.sender);

		// Order must exist
		require(_order.id == _id);

		// Emit event
		emit Cancel(
			_order.id,
			msg.sender,
			_order.tokenGet,
			_order.amountGet,
			_order.tokenGive,
			_order.amountGive,
			block.timestamp
		);
	}
}