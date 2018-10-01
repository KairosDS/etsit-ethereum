pragma solidity ^0.4.19;

contract MyContract {
    string internal greetings = "Hello";
    string internal farewell = "Good Bye";

    function hello() external view returns (string) {
        return greetings;
    }

    function goodBye() external view returns (string) {
        return farewell;
    }

    function setHello(string _greetings) public {
        greetings = _greetings;
    }

    function setGoodBye(string _farewell) public {
        farewell = _farewell;
    }
}
