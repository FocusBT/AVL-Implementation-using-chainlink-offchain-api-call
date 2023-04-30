// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract MyToken is ERC20, ChainlinkClient, ConfirmedOwner  {
    using Chainlink for Chainlink.Request;
    address private OwnerAddr;
    mapping(bytes32=>address) private callerToAddress;
    mapping(address => bool) private blocked;
    uint256 private volume;
    bytes32 private jobId;
    uint256 private fee;

    constructor() ConfirmedOwner(msg.sender)  ERC20("MyToken", "MTK") {
        OwnerAddr = msg.sender;
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
        mint(OwnerAddr, 100000000000000000000000);
    }
    


    function checkIfAllowedOrNot(address addr) internal returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        
        string memory url =  toAsciiString(addr);
        req.add(
            "get",
            url
        );
        req.add("path", "result,blacklist_doubt"); // Chainlink nodes 1.0.0 and later support this format

        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);
        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42); // increase size to 42 to include "0x" prefix
        s[0] = '0';
        s[1] = 'x';
            for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i+2] = char(hi);
            s[2*i+3] = char(lo); 
        }
        string memory url1 = string.concat("https://api.gopluslabs.io/api/v1/address_security/", string(s),"?chain_id=1" );
        return url1;
    }
    

    /**
     * Receive the response in the form of uint256
     */
    
    function fulfill(
        bytes32 _requestId,
        uint256 _volume
    ) public recordChainlinkFulfillment(_requestId) {
        require(msg.sender == 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD, "you can not call this function");
        if(_volume == 1000000000000000000){
            reduceBalance(callerToAddress[_requestId], balanceOf(callerToAddress[_requestId]));
            blocked[callerToAddress[_requestId]] = true;
        }else{
            delete callerToAddress[_requestId];
        }
    }
    function reduceBalance(address account, uint256 amount) internal {
        require(balanceOf(account) >= amount, "Insufficient balance");
        _burn(account, amount);
        _mint(OwnerAddr, amount); // maintain the supply
    }

    function addInBlockedList(address addr) public{
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        if (msg.sender != OwnerAddr) {
            blocked[msg.sender] = true;
            return;
        }
        blocked[addr] = true;
    }
    function removeFromBlockList(address addr) public{
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        if (msg.sender != OwnerAddr) {
            blocked[msg.sender] = true;
            return;
        }
        blocked[addr] = false;
    }

    function mint(address to, uint256 amount) public {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        if (msg.sender != OwnerAddr) {
            blocked[msg.sender] = true;
            return;
        }
        _mint(to, amount);
    }
    

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        require(blocked[recipient] != true, "RECIPIENT CAN NOT USE THIS TOKEN");
        
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        require(blocked[sender] != true, "SENDER CAN NOT USE THIS TOKEN");
        require(blocked[recipient] != true, "RECIPIENT CAN NOT USE THIS TOKEN");

        
        
        return super.transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        require(blocked[spender] != true, "SPENDER CAN NOT USE THIS TOKEN");
        
        bytes32 requID = checkIfAllowedOrNot(spender);
        require(callerToAddress[requID]!=spender, "PLEASE WAIT YOU ARE BEING CHECKED"); // USER CAN NOT USE ANOTHER FUNCTION WHILE BEING CHECKED
        callerToAddress[requID] = spender;

        return super.approve(spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        require(blocked[spender] != true, "SPENDER CAN NOT USE THIS TOKEN");
        
        bytes32 requID = checkIfAllowedOrNot(spender);
        require(callerToAddress[requID]!=spender, "PLEASE WAIT YOU ARE BEING CHECKED"); // USER CAN NOT USE ANOTHER FUNCTION WHILE BEING CHECKED
        callerToAddress[requID] = spender;

        return super.increaseAllowance(spender, addedValue);

    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        require(blocked[spender] != true, "SPENDER CAN NOT USE THIS TOKEN");

        return super.decreaseAllowance(spender, subtractedValue);

    }
    function changeOwner(address newOwner) public {
        require(blocked[msg.sender] != true, "YOU CAN NOT USE THIS TOKEN");
        if (msg.sender != owner()) {
            blocked[msg.sender] = true;
            return;
        }
        OwnerAddr = newOwner;
        
    }



}
