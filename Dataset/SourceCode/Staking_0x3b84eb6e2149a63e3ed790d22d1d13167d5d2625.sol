{{

  "language": "Solidity",

  "sources": {

    "contracts/Staking.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.9;\n\ninterface FounderCards {\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    function balanceOf(address account) external view returns (uint256);\n\n    function getIDsByOwner(address owner) external view returns (uint256[] memory);\n}\n\ninterface IERC20 {\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    function decimals() external view returns (uint8);\n}\n\ninterface OldStaking {\n    function get_staker(uint256 foundercard, uint256 deposit_index) external view returns(address);\n}\n\nstruct Deposit {\n    uint256 tokens;\n    uint256 stakers;\n    uint256 timestamp;\n}\n\ncontract Staking {\n    IERC20 token;\n    FounderCards founder_cards;\n    OldStaking old_staking;\n    mapping(uint256 => uint256) next_withdrawable_deposit_by_foundercard;\n    mapping(bytes32 => address) staker_by_foundercard_and_deposit;\n    uint256 public stakers = 0;\n    mapping(uint256 => Deposit) public deposits_by_index;\n    uint256 public deposit_count = 2;\n    address public contract_owner;\n\n    address constant UNSTAKE_ADDRESS = 0x0123456789012345678901234567890123456789;\n\n    constructor(address address_token, address address_founder_cards, address address_old_staking, uint256 old_stakers) {\n        founder_cards = FounderCards(address_founder_cards);\n        token = IERC20(address_token);\n        contract_owner = msg.sender;\n        old_staking = OldStaking(address_old_staking);\n        stakers = old_stakers;\n        deposits_by_index[0] = Deposit(0, 0, 0);\n        deposits_by_index[1] = Deposit(0, 0, 0);\n    }\n\n    function transfer_ownership(address new_owner) public {\n        require(msg.sender == contract_owner, \"You are not the owner\");\n        contract_owner = new_owner;\n    }\n\n    function deposit(uint256 amount) public {\n        require(msg.sender == contract_owner, \"You are not the owner\");\n        token.transferFrom(msg.sender, address(this), amount);\n        deposits_by_index[deposit_count] = Deposit(amount, stakers, block.timestamp);\n        deposit_count++;\n    }\n\n    function stake(uint256 foundercard) public {\n        require(msg.sender == founder_cards.ownerOf(foundercard), \"You are not the owner of this Founder's card!\");\n        if(!was_staked(foundercard, deposit_count)) {\n            stakers++;\n        }\n        set_staker(foundercard, msg.sender);\n    }\n\n    function stake_all() public {\n        uint256[] memory ids = founder_cards.getIDsByOwner(msg.sender);\n        for(uint256 i = 0; i < ids.length; i++) {\n            stake(ids[i]);\n        }\n    }\n\n    function unstake(uint256 foundercard) public {\n        address staker = get_staker(foundercard, deposit_count);\n        address owner = founder_cards.ownerOf(foundercard);\n        require(staker != address(0), \"This Founder's card is not staked.\");\n        require(staker != owner, \"The staker of this founder's card still owns it.\");\n        set_staker(foundercard, UNSTAKE_ADDRESS);\n        stakers--;\n    }\n\n    function withdraw(uint256 foundercard) public {\n        require(msg.sender == founder_cards.ownerOf(foundercard), \"You are not the owner of this Founder's card!\");\n        uint256 balance = get_balance(foundercard);\n        next_withdrawable_deposit_by_foundercard[foundercard] = deposit_count;\n        token.transfer(msg.sender, balance);\n    }\n\n    function withdraw_all() public {\n        uint256[] memory owned_founder_cards = founder_cards.getIDsByOwner(msg.sender);\n        uint256 total_balance = 0;\n        for(uint256 i = 0; i < owned_founder_cards.length; i++) {\n            uint256 foundercard = owned_founder_cards[i];\n            total_balance += get_balance(foundercard);\n            next_withdrawable_deposit_by_foundercard[foundercard] = deposit_count;\n        }\n        token.transfer(msg.sender, total_balance);\n    }\n\n    function get_staker_entry(uint256 foundercard, uint256 deposit_index) private view returns(address) {\n        bytes32 index = sha256(abi.encodePacked(foundercard, deposit_index));\n        return staker_by_foundercard_and_deposit[index];\n    }\n\n    function set_staker(uint256 foundercard, address staker) private {\n        bytes32 index = sha256(abi.encodePacked(foundercard, deposit_count));\n        staker_by_foundercard_and_deposit[index] = staker;\n    }\n\n    function was_staked(uint256 foundercard, uint256 deposit_index) public view returns(bool) {\n        address staker = get_staker(foundercard, deposit_index);\n        return staker != address(0);\n    }\n\n    function get_staker(uint256 foundercard, uint256 deposit_index) public view returns(address) {\n        deposit_index++;\n        do {\n            deposit_index--;\n            address staker = get_staker_entry(foundercard, deposit_index);\n\n            if(staker == address(0) && deposit_index == 1) {\n                staker = old_staking.get_staker(foundercard, 1);\n            }\n\n            if(staker == address(0) && (deposit_index == 0)) {\n                staker = old_staking.get_staker(foundercard, 0);\n            }\n            \n            if(staker == address(0)) {\n                continue;\n            }\n\n            if(staker == UNSTAKE_ADDRESS) {\n                return address(0);\n            }\n            return staker;\n        } while(deposit_index > 0);\n        return address(0);\n    }\n\n    function get_balance(uint256 foundercard) public view returns(uint256) {\n        uint256 balance = 0;\n        for(uint256 i = next_withdrawable_deposit_by_foundercard[foundercard]; i < deposit_count; i++) {\n            Deposit memory deposit_i = deposits_by_index[i];\n            if(was_staked(foundercard, i)) {\n                balance += deposit_i.stakers == 0 ? 0 : deposit_i.tokens / deposit_i.stakers;\n            }\n        }\n        return balance;\n    }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "libraries": {}

  }

}}