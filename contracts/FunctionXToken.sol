pragma solidity ^0.4.11;
import "../zeppelin/contracts/token/MintableToken.sol";
import "../zeppelin/contracts/token/BurnableToken.sol";
import "../zeppelin/contracts/token/PausableToken.sol";
import '../zeppelin/contracts/math/SafeMath.sol';
import "./TokenRecipient.sol";


contract FunctionXToken is MintableToken, BurnableToken, PausableToken {

    string public constant name = "Function X";
    string public constant symbol = "Fx";
    uint8 public constant decimals = 18;


    function FunctionXToken() {

    }


    // --------------------------------------------------------

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        bool result = super.transferFrom(_from, _to, _value);
        return result;
    }

    mapping (address => bool) stopReceive;

    function setStopReceive(bool stop) {
        stopReceive[msg.sender] = stop;
    }

    function getStopReceive() constant public returns (bool) {
        return stopReceive[msg.sender];
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(!stopReceive[_to]);
        bool result = super.transfer(_to, _value);
        return result;
    }


    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        bool result = super.mint(_to, _amount);
        return result;
    }

    function burn(uint256 _value) public {
        super.burn(_value);
    }

    // --------------------------------------------------------

    function pause() onlyOwner whenNotPaused public {
        super.pause();
    }

    function unpause() onlyOwner whenPaused public {
        super.unpause();
    }

    function transferAndCall(address _recipient, uint256 _amount, bytes _data) {
        require(_recipient != address(0));
        require(_amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);

        require(TokenRecipient(_recipient).tokenFallback(msg.sender, _amount, _data));
        Transfer(msg.sender, _recipient, _amount);
    }

    function transferERCToken(address _tokenContractAddress, address _to, uint256 _amount) onlyOwner {
        require(ERC20(_tokenContractAddress).transfer(_to, _amount));
    }

}