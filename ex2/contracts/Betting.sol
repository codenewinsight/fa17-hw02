pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address public owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint public numOutcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;
	/* Keep track of all outcomes (maps index to numerical outcome) */
	mapping (uint => uint) public outcomes;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {

      require(
         msg.sender == owner,
         "Only by owner"
	  );
		_;
	}

	modifier OracleOnly() {
    require(
			 msg.sender == oracle,
			 "Only by oracle"
			);
		_;
	}

	modifier OutcomeExists(uint outcome) {
		uint i = 0;

		//Iterate all the outcome and try to find match
		for (i = 0; i < numOutcomes; i++){
	      if (outcomes[i] == outcome)
				   break;
			}

    //No match found until the end of array, revert.
    if (i == numOutcomes)
	    revert();

		_;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		owner = msg.sender;
		numOutcomes = _outcomes.length;

		for (uint i = 0;i < _outcomes.length; i++){
		   outcomes[i] = _outcomes[i];
		}
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		if ((_oracle != gamblerA) && (_oracle != gamblerB))
		    oracle = _oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
	 //Check whether caller is ower or Oracle
	 if ((msg.sender == owner) || (msg.sender == oracle))
	    revert();

	 //check whether outcome is within range
	 if (checkOutcomes(_outcome) >= numOutcomes)
	     revert();

     //SEt the gambler if it is not set yet. Otherwise return as we can have only up to 2  gambler
	 if (gamblerA == 0x0)
	    gamblerA = msg.sender;
	 else if (gamblerB == 0x0)
	    gamblerB = msg.sender;
	 else
	    revert();

     //REcord the bet
	 bets[msg.sender].outcome = _outcome;
     bets[msg.sender].amount = msg.value;
	 bets[msg.sender].initialized = true;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() OutcomeExists(_outcome) {
    //REturn if gamblers are  not set
		if (gamblerA == 0x0)
		   revert();
		else if (gamblerB == 0x0)
		   revert();

    //if gamblers bet the same outcome, they both win
		if (bets[gamblerA].outcome == bets[gamblerB].outcome){
			winnings[gamblerA] =bets[gamblerA].amount;
			winnings[gamblerB] = bets[gamblerB].amount;
		}
	  else {
			winnings[oracle] = bets[gamblerA].amount + bets[gamblerB].amount;
		}
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {

	}

	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes(uint outcome) constant returns (uint) {
		uint i= 0;
		//Iterate all the outcome and try to find match
		for (i = 0; i < numOutcomes; i++){
				if (outcomes[i] == outcome)
					 break;
			}

			return i;
	}

	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
	    return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		//reset bets, winnings,
		if (gamblerA != 0x0){
		    bets[gamblerA].amount = 0;
		    bets[gamblerA].outcome = 0;
		    bets[gamblerA].initialized = false;
			winnings[gamblerA] = 0;
		}

		if (gamblerB != 0x0){
		    bets[gamblerB].amount = 0;
		    bets[gamblerB].outcome = 0;
		    bets[gamblerB].initialized = false;
			winnings[gamblerB] = 0;
		}

		if (oracle != 0x0){
		    bets[oracle].amount = 0;
		    bets[oracle].outcome = 0;
		    bets[oracle].initialized = false;
			winnings[oracle] = 0;
		}

		gamblerA = 0x0;
		gamblerB = 0x0;
		oracle = 0x0;

	}

	/* Fallback function */
	function() payable {
		revert();
	}
}
