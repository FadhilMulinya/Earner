// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library randomNumber {


    //Function generate Random Number
    function getRandomNumber() public view  returns(uint256){

        //Generating random NUmber using Pseudo Attrbutes

        uint256 diff = uint256(keccak256(abi.encodePacked(msg.sender)));

        uint256 diff2 = uint256(keccak256(abi.encodePacked(blockhash(block.number -1))));

        uint256 diff3 = uint256(keccak256(abi.encodePacked(tx.gasprice)));

        uint256 finalDiff = uint256(keccak256(abi.encodePacked(
             diff,
             diff2,
             diff3,
             block.timestamp,
             block.prevrandao,
             msg.sender,
             tx.gasprice,
             block.coinbase,
             msg.data,
             tx.origin,
             blockhash(block.number -( 256 - 199))
             )));

        uint256 random = uint256(
            keccak256(
              abi.encodePacked(
                diff,
                diff2,
                diff3,
                finalDiff,
                msg.sender
                
            )
            )
        );
        return random % 4 ;
    }

}
