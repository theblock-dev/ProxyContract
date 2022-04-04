//SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {

    address public admin;
    address private _implementationAddress;

    constructor() {
        admin = msg.sender;
    }

    function updateImplAddress(address _implAddress) external {
        require(msg.sender == admin, "Only Admin");
        _implementationAddress = _implAddress;
    }

    receive() external payable {

    }

    fallback() external payable {
        require(_implementationAddress != address(0));
        address impl = _implementationAddress;

        assembly {
            let pointer := mload(0x40)
            calldatacopy(pointer, 0, calldatasize())
            let result := delegatecall(gas(), impl, pointer, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(pointer, 0, size)
            
            switch result
            case 0 {
                revert(pointer,size)}
            default{
                return(pointer, size)
            }            
        }
    }

}