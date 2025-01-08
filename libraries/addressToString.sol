// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library externalFunctions {

    // Utility function to convert address to string for output
    function _addressToString(address _addr) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(_addr);
        bytes memory hexBytes = "0123456789abcdef";
        bytes memory stringRep = new bytes(42);

        stringRep[0] = '0';
        stringRep[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            stringRep[2 + i * 2] = hexBytes[uint8(addressBytes[i] >> 4)];
            stringRep[3 + i * 2] = hexBytes[uint8(addressBytes[i] & 0x0f)];
        }

        return string(stringRep);
    }


}
