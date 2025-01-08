// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library externalFunctions {

    
    // Function to convert a string to lowercase
    function toLowerCase(string memory _str) public pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        for (uint i = 0; i < strBytes.length; i++) {
            // If the character is an uppercase letter (ASCII between 65-90)
            if (strBytes[i] >= 0x41 && strBytes[i] <= 0x5A) {
                // Convert it to lowercase by adding 32 (ASCII difference between uppercase and lowercase)
                strBytes[i] = bytes1(uint8(strBytes[i]) + 32);
            }
        }
        return string(strBytes);
    }


}
