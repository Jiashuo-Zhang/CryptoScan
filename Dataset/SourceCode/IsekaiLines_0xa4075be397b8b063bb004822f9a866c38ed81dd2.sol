// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { ERC721AQueryable, ERC721A, IERC721A } from "erc721a/contracts/extensions/ERC721AQueryable.sol";
import { Ownable } from "solady/auth/Ownable.sol";
import { ECDSA } from "solady/utils/ECDSA.sol";
import { IIsekaiLines } from "./interfaces/IIsekaiLines.sol";

/*                                                                                 
                                     :7YGP?7??7!!^:.                                                
                                 .^~JBBBBBBGJ?YYYYYYJ?7~^                                           
                                 :?7JBBBBBBBBY7JJJJJYYYYJ                                           
                          .:~^::!!:7PBBBBBBBBB5!JJJJJJJY7                                           
                       .~?J???7~:?5~PBBBBBBBBBB5!YJJJJJY!                                           
                     ^?YJ?777?55PGBG5BBBBBBBBBBB5!YJJJJY~                                           
                  :7YY?777777?GBBBBBBBBBBBBBBBBBBY!YJJJY!                                           
                :7YY?7777??77JGBBBBBBBB5BBBBBBBBBBJ7YYYY7                                           
                 .~7?7777?GGGGBBBBBBBBBPJGBBBBBBBGP??????                                           
                    :!??77GBBBGGBBBBBBBBGJPGP5J?!!~:^^:^^:                                          
   ^^.                .!?75BBBB55GBBBBGP5J~!~~~!!77^^~^^^~:                                         
   :~7~                 .!PBBBBBGY5PY?7!~~!!77777777:^^^^^^                                         
     ^!7^                 7BBBGPY?~~~!!77777777777777^^~~^^.                                        
      .^7!:                :JJ7!~!!77777777777777777!~:..                                           
        .~7!:                !!777777777777777!~^:.                                                 
          :!77:              .!7777777777!^:^^^:                                                    
            :!7!:              ^777!~^:.    ^77~^                                                   
              ^!7!:             ..           ~7!~^                                                  
                ^!77:..                       ~7!~^                     .:^^~~^~~:.                 
                  ^~!YGP!.                     !7!~^              .~?PB#&&&&&&&&&&&#G5?^.           
                   ~?JYPBP!.                    !7!~^.         ^YB&&&&&##&&&&&&##BGBB#&&&P~.        
                    :!?JYYYY:                    !77~~:     .Y#&&&&####&&&&##BP5YYYYYYYG&&#G?.      
                      :~7???7?7!^.                ^~^:     Y&&&&&###&&&&####G55YYYYYYJYB#&&&&G~     
                         :!JBBB#BB5^                     .#&&&###&&&&####&&5Y5YYYYYJYP#&&&&&&&#?    
                          ?Y5PGPGGJY7                   ^#&&###&&&&###&&&&&P5YYYYYPB#&&&&&&&&&&B!   
                           :7?!~!777Y~                .5&&&&&&&&&##&&&&&&########&&&&&&&######&&G   
                              ..:^~!!?^             :5&&B5?!~^J##&&&&#####&&&&&&&&&&&#########&&#:  
                                      :          :?B&#5~.     7#######&&&&&&&&&&&&&&&&#######&&&#^  
                                            .~JG#&&&B^     .!B&&&&&&&&&&&&&&&&&&###########&&&&&#:  
                                       .^75B&&&&&##&#7.:^?G&&&&&&&&&&&&&&&&#####&&#######&&&&&&&P   
                                   .~YG#&&&&&&&##&&&&&&&&&&&&&&&&&&&&&######&&&&&&&&&&&&&&&#####^   
                                 !5#&&&&&&&&&##&&&&&&&&&&&&&&&&&#######&&&&&&&&&&&&&&&&#####&&&7    
                              .?B&&&&&&&&&###&&&&&&&&&&&&&&######&&&&&&&&&&&##BGGBB####&&&&&&#~     
                             ^#&&&&&&&&&###&&&&&&&&&&&&#####&&&&&&&&&&&&&#BP5YYYYYYG&&&&&&&#5:      
                            ^&&&&&&&&###&&&&&&&&&&&#####&&&&&&&&&&&&&###G5PP55555Y5#&&&&&#P~        
                            G&&&&&###&&#G5JJY5P#&###&&&&&&&&&&&&#######G5G5Y555Y5G#&&&&#P^          
                            #&&####&&BYJ?7!!!!!?#&&&&&&&&#BGGGB##&&&&&&GY5YYYY5GB###&#Y:            
                            G###&&&&PJ?777777!7G&&&&&&B5J777777Y#&&&&&&#G5PPGB#&&&#G7.              
                            ~&&&&&&P7?7777!!!JB&&&&&#Y?J?777777J&&&&&#####&&&&&#P7.                 
                             :B&&&&G?7!777J5B&&&&&##J?J7777777Y#&####&&&&&&#GJ^.                    
                               !G&&&&BGBB#&&&&&&##&#?77777?J5B&##&&&&&#B57^.                        
                                 :?PB#&&&&&&&&##&&&&#GPGGB#&&&&&#BPY7^.                             
                                    .^?5G##&&#&&&&&&&&&&&#G5Y7~^.                                   
                                         ..::^~~!!!~~^:..                                                                                                                                                                 
*/

contract IsekaiLines is IIsekaiLines, Ownable, ERC721AQueryable {
    using ECDSA for bytes32;

    /// @dev Bitmap array to track Isekai tokens that have participated.
    uint256[31] private _hasDrawn;

    address private _signer;
    string private _baseTokenURI;

    /// @dev Interface the Isekai Meta contract.
    IERC721A public constant ISEKAI = IERC721A(0x684E4ED51D350b4d76A3a07864dF572D24e6dC4c);

    DrawStates public drawState;

    constructor(
        address signer_,
        string memory baseTokenURI_
    ) ERC721A("Isekai Lines", "LINES") {
        _initializeOwner(msg.sender);
        _frontGas();
        _mint(msg.sender, 1);
        
        _signer = signer_;
        _baseTokenURI = baseTokenURI_;
    }

    /**
      @notice Function used to draw a line on the canvas.
      @param id Associated Isekai token identifier.
      @param signature Signed message digest.
      @dev To successfully add an artwork to the canvas, the caller must be in
      possession of the associated Isekai Meta token.
    */
    function drawLine(uint256 id, bytes calldata signature) external {
        if (drawState == DrawStates.DISABLED) revert InvalidState();
        if (ISEKAI.ownerOf(id) != msg.sender) revert NonOwner();
        if (!_verifySignature(id, msg.sender, signature)) revert SignerMismatch();

        uint256 idx = id / 256;
        uint256 offset = id % 256;
        uint256 bit = _hasDrawn[idx] >> offset & 1;

        if (bit != 1) revert HasDrawn();

        _hasDrawn[idx] = _hasDrawn[idx] & ~(1 << offset);

        emit LineDrawn(id, _nextTokenId());

        _mint(msg.sender, 1);
    }

    /**
      @notice Function used to check if Isekai `id` has drawn a line.
      @param id Unique Isekai Meta token identifier.
      @return Returns `true` if `id` has drawn a line, `false` otherwise.
    */
    function hasDrawn(uint256 id) external view returns (bool) {
        return _hasDrawn[id / 256] >> id % 256 & 1 == 0;
    }

    /**
      @notice Function used to view the current `_signer` value.
      @return Returns the current `_signer` value.
    */
    function signer() external view returns (address) {
        return _signer;
    }

    /**
      @notice Function used to set a new `_signer` value.
      @param newSigner Newly desired `_signer` value.
    */
    function setSigner(address newSigner) external onlyOwner {
        _signer = newSigner;
    }

    /**
      @notice Function used to set a new `drawState` value.
      @param newDrawState Newly desired `drawState` value.
    */
    function setDrawState(DrawStates newDrawState) external onlyOwner {
        drawState = newDrawState;
    }

    /**
      @notice Function used to set a new `_baseTokenURI` value.
      @param newBaseTokenURI Newly desired `_baseTokenURI` value.
    */
    function setBaseTokenURI(string calldata newBaseTokenURI) external onlyOwner {
        _baseTokenURI = newBaseTokenURI;
    }

    /**
      @dev Sets all bits in each index of `_hasDrawn` to 1. As the
      deployer, we front the gas cost associated with a zero to non-zero
      `SSTORE` operation.
    */
    function _frontGas() private {
        for (uint256 i = 0; i < _hasDrawn.length; ) {
            _hasDrawn[i] = type(uint256).max;
            unchecked { ++i; }
        }
    }

    function _verifySignature(
        uint256 id,
        address account,
        bytes calldata signature
    ) private view returns (bool) {
        return _signer == keccak256(abi.encodePacked(account, id, 'CANVAS'))
            .toEthSignedMessageHash()
            .recover(signature);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

}