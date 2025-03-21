// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**


   □□□□    □□    □□     □□□     □□□□  □□□    □□  □□       □□□□  □□□□□□□  □□□□□□□
 □□    □□  □□    □□   □□   □□    □□   □□□□   □□  □□        □□   □□       □□     
□□         □□    □□  □□     □□   □□   □□ □□  □□  □□        □□   □□□□□    □□□□□  
□□         □□□□□□□□  □□□□□□□□□   □□   □□  □□ □□  □□        □□   □□       □□     
 □□    □□  □□    □□  □□     □□   □□   □□   □□□□  □□        □□   □□       □□     
   □□□□    □□    □□  □□     □□  □□□□  □□    □□□  □□□□□□□  □□□□  □□       □□□□□□□


                                                                        by Matto
*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface i_ArtBlocks {
    function ownerOf(uint256 fullTokenId) external view returns (address);
}

/** 
 * @title Chainlife
 * @notice This is a customized ERC-721 contract for Chainlife. All tokens
 * created and controlled by this contract are licensed CC BY-NC 4.0.
 * @author Matto
 * @custom:security-contact [email protected] / @MonkMatto on Twitter
 */ 
contract Chainlife is ERC721Royalty, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using Strings for string;

  Counters.Counter public tokensMinted;
  string public baseURI;
  string public description;
  uint8 public mintStage;
  bool public scriptsLocked;
  address public paymentsAddress;
  uint96 public royaltyBPS;
  uint256 public mintFee;
  uint256 public shiftFee;
  uint16 public maxSupply = 4096;
  mapping(uint256 => string) public scriptData;
  mapping(uint256 => uint8) public preMintWithEnso;
  mapping(uint256 => uint8) public preMintWithFOCUS;
  mapping(uint256 => int256) public levelShiftOf;
  mapping(uint256 => string) public customRuleOf;
  mapping(uint256 => bytes32) private tokenEntropyOf;
  mapping(uint256 => address) private previousOwnerOf;
  mapping(uint256 => uint256) private transferCountOf;
  address private ABcontract = 0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270;

  constructor() ERC721("Chainlife", "CHNLF") {}

  /** 
   * CUSTOM EVENTS
   * @notice These events are emitted by functions 'SET_CUSTOM_RULE' and 
   * 'writeScriptData'.
   * @dev These will be monitored by the custom backend. They will trigger
   * updating the API with data stored in scriptData, as well as data returned
   * by the scriptInputsOf() function.
   *
   * CustomRule Event
   * @notice This is emitted whenever SET_CUSTOM_RULE is successfully called.
   * @dev indexed keyword is added for later searchability.
   * @param tokenId is the token that had a change to its CustomRule.
   * @param rule is the rule string that was written to chain.   
   * @param byAddress is the address that set the CustomRule (unless set by 
   * Matto on their behalf).
   */
  event CustomRule(
      uint256 indexed tokenId,
      string rule,
      address indexed byAddress
  );

  /**
   * ScriptData Event
   * @notice This is emitted whenever writeScriptData is successfully called.
   * @dev indexed keyword is added to scriptIndex for searchability.
   * @param scriptIndex is index in the mapping that is being updated.
   * @param oldScript is the data being replaced, potentially "".
   * @param newScript is the new data stored to chain.
   */  
  event ScriptData(
      uint256 indexed scriptIndex,
      string oldScript,
      string newScript
  );

  /**
   * ShiftLevel Event
   * @notice This is emitted whenever SHIFT_LEVEL is successfully called.
   * @dev indexed keyword is added for later searchability.
   * @param tokenId is the token that had a change to its level shift.
   * @param shift is the amount that the token is being shifted.
   * @param totalShift is the cumulative shift amount.
   * @param byAddress is the address that called SHIFT_LEVEL (unless set by 
   * Matto on their behalf).
   */  
  event ShiftLevel(
      uint256 indexed tokenId,
      int256 shift,
      int256 totalShift,
      address indexed byAddress
  );

  /**
   * MODIFIERS
   * @notice These are reusable code to control function execution.
   *
   * @notice callerIsUser modifier prohibits contracts.
   * @dev This modifier will cause transactions to fail if they come from a
   * contract because the transaction origin will not match the message sender.
   */
  modifier callerIsUser() {
      require(tx.origin == msg.sender);
      _;
  }

  /**
   * OVERRIDES
   * @notice These functions are declared as overrides because functions of the 
   * same name exist in imported contracts.
   * @dev 'super._transfer' calls the overridden function.
   *
   * @notice _baseURI is an internal function that returns a state value.
   * @dev This override is needed when using a custom baseURI.
   * @return baseURI, which is a state value.
   */
  function _baseURI()
      internal 
      view 
      override 
      returns (string memory) 
  {
      return baseURI;
  }

  /**
   * @notice _transfer override adds logic to track transfer counts as well as
   * the prior owner.
   * @dev This override updates mappings and then calls the overridden function.
   * @param  _from is the address the token is being sent from.
   * @param  _to is the address the token is being sent to.
   * @param  _tokenId is the token being transferred.
   */
  function _transfer(
      address _from,
      address _to,
      uint256 _tokenId
  ) 
      internal 
      virtual 
      override 
  {
      transferCountOf[_tokenId]++;
      previousOwnerOf[_tokenId] = _from;
      super._transfer(_from, _to, _tokenId);
  }

  /**
   * MINTING
   * @notice These are functions needed to mint tokens.
   * @dev various external functions call the same internal function (_minter)
   * if requirements are met.
   *
   * @notice PREMINT is the restricted access public mint function.
   * @dev This allows previous collectors of Art Blocks projects #34 and #181 to
   * mint at an earlier stage. Ownership is verified via the ArtBlocks contract
   * controlling these tokens. Art Blocks tokenIds are the
   * project number * 1 million, plus that project's token 'number.'
   * The preMintWith* mappings tracks tokens so they can only be used once.
   * The contract owner can bypass the perMintActive requirement.
   * MAINNET FOCUS tokenBase: 181000000 | GOERLI tokenBase: 94000000.
   * @param projectNumber is the Art Blocks project number of a Matto project,
   * either 34 or 181 are acceptable.
   * @param tokenNumber is the owned token from the project corresponding
   * to the projectNumber that is being used for the premint.
   */
  function PREMINT(
      uint256 projectNumber, 
      uint256 tokenNumber
  )
      external
      payable
      nonReentrant
      callerIsUser
  {
      require(mintStage == 1);
      require(projectNumber == 34 || projectNumber == 181);
      require(
          msg.sender ==
              i_ArtBlocks(ABcontract).ownerOf(
                  (projectNumber * 1000000) + tokenNumber
              )
      );
      if (projectNumber == 34) {
          require(
              preMintWithEnso[tokenNumber] == 0,
              "Enso already used."
          );
          preMintWithEnso[tokenNumber] = 1;
      } else {
          require(
              preMintWithFOCUS[tokenNumber] == 0,
              "FOCUS already used."
          );
          preMintWithFOCUS[tokenNumber] = 1;
      }
      _minter(msg.sender);
  }

  /**
   * @notice MINT is the regular access public mint function that mints to the
   * caller's address.
   * @dev Variation of a mint function that uses the msg.sender address as the
   * account to mint to. The contract owner can bypass the publicMintActive 
   * requirement.
   */
  function MINT() 
      external 
      payable 
      nonReentrant 
      callerIsUser 
  {
      require(mintStage == 2 || msg.sender == owner());
      _minter(msg.sender);
  }

  /**
   * @notice MINT_TO_ADDRESS is the regular access public mint function that 
   * mints to a specified address.
   * @dev Variation of a mint function that uses a submitted address as the
   * account to mint to. The contract owner can bypass the publicMintActive 
   * requirement.
   * @param to is the address to send the token to.
   */
  function MINT_TO_ADDRESS(
    address to
  )
      external
      payable
      nonReentrant
      callerIsUser
  {
      require(mintStage == 2 || msg.sender == owner());
      _minter(to);
  }

  /**
   * @notice _minter is the internal function that generates mints.
   * @dev Minting function called by all other public 'MINT' functions.
   * The contract owner can bypass the payment requirement.
   * @param _to is the address to send the token to.
   */
  function _minter(
      address _to
  ) 
      internal 
  {
      require(
          msg.value == mintFee || msg.sender == owner(),
          "Incorrect value."
      );
      require(
          tokensMinted.current() < maxSupply,
          "All minted."
      );
      uint256 tokenId = tokensMinted.current();
      tokensMinted.increment();
      _assignTokenData(tokenId);
      _safeMint(_to, tokenId);
  }

  /**
   * @notice _assignTokenData generates the token's entropy.
   * @dev This creates a hash that will be used as token entropy, created
   * from various data inputs. Even with concurrent mints in a single block,
   * each _tokenId will be unique, resulting in unique hashes.
   * @param _tokenId is the token that the data will get assigned to.
   */
  function _assignTokenData(
      uint256 _tokenId
  ) 
      internal 
  {
      tokenEntropyOf[_tokenId] = keccak256(
          abi.encodePacked(
              "Chainlife",
              _tokenId,
              block.number,
              block.timestamp,
              tx.gasprice
          )
      );
  }

  /**
   * CUSTOM
   * @notice These are custom functions for Chainlife.
   * 
   * @notice CUSTOM_RULE allows owners to set a rule on-chain. 
   * @dev This allows token owners to submit and record data on the blockchain.
   * The contract owner can also set these rules on the token owner's behalf.
   * Each Chainlife token has the ability to utilize custom rules, but only
   * after evolution. Chainlife tokens use the B/S notation for rules:
   *
   * B{number list}/S{number list}
   *
   * For example, the rulestring for Conway's Game of Life is B3/S23, meaning 
   * that any dead cell with 3 living neighbors will be born (B3), and any 
   * live cells with 2 or 3 neighbors will survive (S23). All other cells 
   * will die or remain dead.
   * @param tokenId is the token whose CustomRule is being updated.
   * @param rule is a string that gets stored as a state value. The input string
   * should not include any quotation marks.
   */
  function CUSTOM_RULE(
      uint256 tokenId, 
      string memory rule
  ) 
      external 
  {
      require(
          msg.sender == ownerOf(tokenId) || msg.sender == owner(),
          "Unauthorized."
      );
      emit CustomRule(tokenId, rule, ownerOf(tokenId));
      customRuleOf[tokenId] = rule;
  }

  /**
   * @notice RESET_RULE allows owners to remove a custom rule. 
   * @dev This replaces the customRuleOf[tokenId] data with an empty string.
   * When the generative script receives an empty string, it uses the rule
   * that was determined by the token hash at mint.
   * @param tokenId is the token whose custom rule is being reset.
   */
  function RESET_RULE(
      uint256 tokenId
  ) 
      external 
  {
      require(
          msg.sender == ownerOf(tokenId) || msg.sender == owner(),
          "Unauthorized."
      );
      emit CustomRule(tokenId, "", ownerOf(tokenId));
      customRuleOf[tokenId] = "";
  }

  /**
   * @notice SHIFT_LEVEL allows owners to adjust the level shift value that is 
   * stored on-chain. Level shifts are additive, eg. submitting a transaction 
   * with shift value of -5 will subtract 5 from the current level shift value. 
   * @dev This allows token owners to submit and record data on the blockchain.
   * The contract owner can also set these rules on the token owner's behalf.
   * Each Chainlife token tracks its level, which is determined by transfer
   * count and shift amount.
   * @param tokenId is the token whose shift amount is being updated.
   * @param shift is a signed integer that gets stored as a state value.
   */
  function SHIFT_LEVEL(
      uint256 tokenId, 
      int256 shift
  ) 
      external 
      payable
      nonReentrant
      callerIsUser      
  {
      require(
          msg.sender == ownerOf(tokenId) || msg.sender == owner(),
          "Unauthorized."
      );
      uint256 absShift = (shift < 0) ? uint256(-shift) : uint256(shift);
      require(
          msg.value == absShift * shiftFee || msg.sender == owner(),
          "Incorrect value."
      );
      int256 totalShift = levelShiftOf[tokenId] + shift;
      emit ShiftLevel(tokenId, shift, totalShift, ownerOf(tokenId));
      levelShiftOf[tokenId] = totalShift;
  }

  /**
   * @notice writeScriptData allows storage of the generative script on-chain.
   * @dev This will store the generative script needed to reproduce Chainlife
   * tokens, along with other information and instructions. Vanilla JavaScript
   * and p5.js v1.0.0 are other dependencies.
   * @param index identifies where the script data should be stored.
   * @param newScript is the new script data.
   */
  function writeScriptData(
      uint256 index, 
      string memory newScript
  )
      external
      onlyOwner
  {
      require(!scriptsLocked);
      emit ScriptData(index, scriptData[index], newScript);
      scriptData[index] = newScript;
  }

  /**
   * @notice scriptInputsOf returns the input data necessary for the generative
   * script to create/recreate a Chainlife token. 
   * @dev For any given token, this function returns all the on-chain data that
   * is needed to be inputted into the generative script to deterministically 
   * reproduce both the token's artwork and metadata.
   * @param tokenId is the token whose inputs will be returned.
   * @return scriptInputs are returned in JSON format.
   */
  function scriptInputsOf(
      uint256 tokenId
  )
      external
      view
      returns (string memory)
  {
      string memory entropyString = BytesToHexString.toHex(tokenEntropyOf[tokenId]);
      string memory sign = (levelShiftOf[tokenId] < 0) ? "-" : "";
      uint256 absLevelShift = (levelShiftOf[tokenId] < 0) ? uint256(-levelShiftOf[tokenId]) : uint256(levelShiftOf[tokenId]);
      return
          string(
              abi.encodePacked(
                  '{"token_id":"',
                  Strings.toString(tokenId),
                  '","token_entropy":"',
                  entropyString,
                  '","previous_owner":"',
                  Strings.toHexString(uint160(previousOwnerOf[tokenId]), 20),
                  '","current_owner":"',
                  Strings.toHexString(uint160(ownerOf(tokenId)), 20),
                  '","transfer_count":"',
                  Strings.toString(transferCountOf[tokenId]),
                  '","level_shift":"',
                  sign, Strings.toString(absLevelShift),                  
                  '","custom_rule":"',
                  customRuleOf[tokenId],
                  '"}'
              )
          );
  }

  /**
   * CONTROLS
   * @notice These are contract-level controls.
   * @dev all should use the onlyOwner modifier.
   *
   * @notice lockScripts freezes the scriptData storage.
   * @dev The project must be fully minted before this function is callable.
   */
  function lockScripts() 
      external 
      onlyOwner 
  {
      require(tokensMinted.current() == maxSupply);
      scriptsLocked = true;
  }

  /**
   * @notice lowerMaxSupply allows changes to the maximum iteration count,
   * a value that is checked against during mint.
   * @dev This function will only update the maxSupply variable if the 
   * submitted value is lower. maxSupply is used in the internal _minter 
   * function to cap the number of available tokens.
   * @param _maxSupply is the new maximum supply.
   */
  function lowerMaxSupply(
      uint16 _maxSupply
  ) 
      external 
      onlyOwner 
  {
      require(_maxSupply < maxSupply && _maxSupply >= tokensMinted.current());
      maxSupply = _maxSupply;
  }

  /**
   * @notice setMintStage sets the stage of the mint.
   * @dev This is used instead of public view booleans to save contract size.
   * @param _mintStage is the new stage for the mint: 0 for disabled, 1 for 
   * premint only, 2 for public mint.
   */
  function setMintStage(
    uint8 _mintStage
  ) 
      external 
      onlyOwner 
  {
      mintStage = _mintStage;
  }

  /**
   * @notice setRoyalties updates the royalty address and BPS for the project.
   * @dev This function allows changes to the payments address and secondary sale
   * royalty amount. After setting values, _setDefaultRoyalty is called in 
   * order to update the imported EIP-2981 contract functions.
   * @param _paymentsAddress is the new payments address.
   * @param _royaltyBPS is the new projet royalty amount, measured in 
   * base percentage points.
   */
  function setRoyalties(
      address _paymentsAddress, 
      uint96 _royaltyBPS
  )
      external
      onlyOwner
  {
      paymentsAddress = _paymentsAddress;
      royaltyBPS = _royaltyBPS;
      _setDefaultRoyalty(paymentsAddress, _royaltyBPS);
  }

  /**
   * @notice setMintFee sets the price per mint.
   * @dev This function allows changes to the payment amount that is required 
   * for minting.
   * @param _mintFee is the cost per mint in Wei.
   */
  function setMintFee(
      uint256 _mintFee
  ) 
      external 
      onlyOwner 
  {
      mintFee = _mintFee;
  }

  /**
   * @notice setShiftFee sets the price per level shift.
   * @dev This function allows changes to the payment amount that is required 
   * to shift a token's level.
   * @param _shiftFee is the cost per level shift in Wei.
   */
  function setShiftFee(
      uint256 _shiftFee
  ) 
      external 
      onlyOwner 
  {
      shiftFee = _shiftFee;
  }

  /**
   * @notice setDescription updates the on-chain description.
   * @dev This is separate from other update functions because the description
   * size may be large and thus expensive to update.
   * @param _description is the new description. Quotation marks are not needed.
   */
  function setDescription(
      string memory _description
  ) 
      external 
      onlyOwner 
  {
      description = _description;
  }

  /**
   * @notice setURI sets/updates the project's baseURI.
   * @dev baseURI is appended with tokenId and is returned in tokenURI calls.
   * @dev _newBaseURI is used instead of _baseURI because an override function
   * with that name already exists.
   * @param _newBaseURI is the API endpoint base for tokenURI calls.
   */
  function setURI(
      string memory _newBaseURI
  ) 
      external 
      onlyOwner 
  {
      baseURI = _newBaseURI;
  }

  /**
   * @notice withdraw is used to send mint and shift funds to the payments
   * address.
   * @dev Withdraw cannot be called if the payments addresses is not set. 
   * If a receiving address is a contract using callbacks, the withdraw function
   * could run out of gas. Update the receiving address if necessary.
   */
  function withdraw() 
      external 
      onlyOwner 
  {
      require(paymentsAddress != address(0));
      payable(paymentsAddress).transfer(address(this).balance);
  }
}

/**
 * The following library is licensed CC BY-SA 4.0.
 * @title BytesToHexString Library
 * @notice Provides a function for converting bytes into a hexidecimal string.
 * @author Mikhail Vladimirov (with edits by Matto)
 * @dev Code in this library is based on the thorough example and walkthrough
 * posted by Mikhail Vladimirov on https://stackoverflow.com/ using the 
 * CC BY-SA 4.0 license.
 */
library BytesToHexString {

  /**
   * @notice toHex takes bytes data and returns the data as a string.
   * @dev This is needed to convert the token entropy (bytes) into a string for
   * return in the scriptInputsOf function. This is the function that is called
   * first, and it calls toHex16 while processing the return.
   * @param _data is the bytes data to convert.
   * @return (string)
   */
  function toHex(bytes32 _data)
    internal
    pure
    returns (string memory) 
  {
    return string(
        abi.encodePacked(
            "0x",
            toHex16(bytes16(_data)),
            toHex16(bytes16(_data << 128))
        )
    );
  }

  /**
   * @notice toHex16 is a helper function of toHex.
   * @dev For an explanation of the operations, see Mikhail Vladimirov's 
   * walkthrough for converting bytes to string on https://stackoverflow.com/.
   * @param _input is a bytes16 data chunk.
   * @return output is a bytes32 data chunk.
   */
  function toHex16(bytes16 _input)
    internal
    pure
    returns (bytes32 output) 
  {
    output = bytes32(_input) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 |
      (bytes32(_input) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64;
    output = output & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 |
      (output & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32;
    output = output & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 |
      (output & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16;
    output = output & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 |
      (output & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8;
    output = (output & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 |
      (output & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8;
    output = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 +
      uint256(output) +
      (uint256(output) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &
      0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 7);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/ERC721Royalty.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../common/ERC2981.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev Extension of ERC721 with the ERC2981 NFT Royalty Standard, a standardized way to retrieve royalty payment
 * information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC721Royalty is ERC2981, ERC721 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally clears the royalty information for the token.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}