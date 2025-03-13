# Case Study

This file studies several defective cases reported by CryptoScan. For more defective contracts, please refer to ``./Dataset1/``and ``./Dataset2/``.

## Case 1

**Contract: https://etherscan.io/address/0x25692da406889bf4db93f921063d9bc952bd01d0**

**Defect: Signature Front-Running**

**Impact: Allow unauthorized attackers to mint NFTs.**

**Defective Functions：**

```solidity
function recoverSigner(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
{
    bytes32 messageDigest = keccak256(
        abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
    return ECDSA.recover(messageDigest, signature);
}
function getNFT(
    uint256 _mintNum,
    bytes32 hash,
    bytes memory signature
) public payable callerIsUser {
    uint256 supply = totalSupply();
    uint256 cost = getCost();
    uint256 allowedToMint = getAllowedTokens();

    require(allowlistSaleActive || publicSaleActive, "not ready for sale");
    require(supply + _mintNum <= maxSupply, "Supply Limit Reached");
    require(
        recoverSigner(hash, signature) == signerAddress,
        "User not allowed to mint tokens"
    );
    require(!signatureUsed[signature], "Signature has already been used.");
    require(
        allowedToMint >= _mintNum,
        "Can't mint more than allowed amount"
    );
    require(msg.value >= cost * _mintNum, "Not Enough Tokens");

    if (allowlistSaleActive) {
        _safeMint(msg.sender, _mintNum);
        AllowlistTokens[msg.sender] += _mintNum;
    } else if (publicSaleActive) {
        _safeMint(msg.sender, _mintNum);
        PublicSaleTokens[msg.sender] += _mintNum;
    }
    signatureUsed[signature] = true;
}
```

**Description:**

The expected behavior of this function is to allow users to mint an NFT by submitting a signature issued by "signerAddress". It uses the signature verification to enforce suchaccess control policy. However, in the `getNFT` function, the signature is vulnerable to being front-run by an attacker. By intercepting signatures from pending transactions and initiating a new transaction, the attacker can preemptively use the signature to mint the NFT. Furthermore, once the attacker successfully uses the signature and obtains the NFT, the signature will be marked as used. This prevents the original holder of the signature from using it to acquire the NFT again.

Similar defects can also be found in the following cases:

* https://etherscan.io/address/0xa82f049efc4c0af4f441c1c157d071441b2a49ca#code
* https://etherscan.io/address/0x626acf48a59d5dee6e4e7eb07386ad2851bcb5ce#code
* https://etherscan.io/address/0x48fe8692397772ecc0ab8f021159ccb26434da44#code

## Case 2

**Contract: https://etherscan.io/address/0xdd5a649fc076886dfd4b9ad6acfc9b5eb882e83c#code**

**Defect:  Single Contract Signature Replay**

**Impact: Allow attackers to make unauthorized/repeated accesss to sensitive operations.**

**Defective Functions：**

```solidity
function mint_approved( vData memory info, uint256 number_of_items_requested, uint16 _batchNumber) external {
    require(verify(info), "Unauthorised Minting");
    _discountedClaimedPerWallet[msg.sender] += 1;
    require( _discountedClaimedPerWallet[msg.sender] <= 1, "Number exceeds limit per address");
    _mint(number_of_items_requested,msg.sender);
}
function verify(vData memory info) public view returns (bool) {
    bytes memory cat = abi.encode(info.from,info.start,info.end,info.eth_price,info.dust_price,info.max_mint,info.mint_free);
    bytes32 hash = keccak256(cat);
    bytes32 sigR; bytes32 sigS; uint8 sigV;
    bytes memory signature = info.signature;
    assembly { sigR := mload(add(signature, 0x20))
        sigS := mload(add(signature, 0x40))
        sigV := byte(0, mload(add(signature,0x60)))}
    bytes32 data = keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    address signer =ecrecover(data,sigV,sigR, sigS);
    return signer == owner;
}
```

**Description:**

NBAxNFT is an on-chain project officially launched by the National Basketball Association (NBA).
In April 2022, the project planned to airdrop non-fungible tokens (NFT) rewards to a group of whitelisted users. It issues each whitelisted user a valid signature and implements the signature verification logic in the airdrop contract (*0xdd5a649fc076886dfd4b9ad6acfc9b5eb882e83c*) to ensure that only whitelisted users can mint the NFTs.
As shown above, whitelisted users call the `mint_approved` function with a valid signature encoded in the `info` parameter to mint their reward NFTs. The function first calls the `verify` function to verify the signature (line 2) and then mints the token to the `msg.sender` (line 5). However, the contract's signature verification has an SSR defect, i.e., it does not prevent the same signature from being used multiple times. As a result, after observing the signatures submitted by whitelisted users, anyone, even those not on the whitelist, can use the replayed signature to pass the signature verification and mint reward NFTs for free. This defect resulted in the unexpected minting of thousands of NFTs, causing substantial financial losses.

## Case 3

**Contract: https://etherscan.io/address/0xb6cadfb7d4d900f8152954a58bff03901a57c2e2#code**

**Defect:  Weak Randomness from Hashing Chain Attributes**

**Impact: Allow attackers to manipulate the randomness for profit.**

**Defective Functions：**

```solidity
function airdrop()
private
view
returns(bool)
{
    uint256 seed = uint256(keccak256(abi.encodePacked((block.timestamp).add(block.difficulty).add((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add(block.gaslimit).add((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add(block.number))));
    if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
        return(true);
    else
        return(false);
}

    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
    private
    {
        // if player is new to round
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        // early round eth limiter
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }

        // if eth left is greater than min eth allowed (sorry no pocket lint)
        if (_eth > 1000000000)
        {
            // mint the new keys
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);

            // if they bought at least 1 whole key
            if (_keys >= 1000000000000000000)
            {
                updateTimer(_keys, _rID);

                // set new leaders
                if (round_[_rID].plyr != _pID)
                    round_[_rID].plyr = _pID;
                if (round_[_rID].team != _team)
                    round_[_rID].team = _team;

                // set the new leader bool to true
                _eventData_.compressedData = _eventData_.compressedData + 100;
            }

            // manage airdrops
            if (_eth >= 100000000000000000)
            {
                airDropTracker_++;
                if (airdrop() == true)
                {
                    // gib muni
                    uint256 _prize;
                    if (_eth >= 10000000000000000000)
                    {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(75)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        // adjust airDropPot
                        airDropPot_ = (airDropPot_).sub(_prize);

                        // let event know a tier 3 prize was won
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(50)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        // adjust airDropPot
                        airDropPot_ = (airDropPot_).sub(_prize);

                        // let event know a tier 2 prize was won
                        _eventData_.compressedData += 200000000000000000000000000000000;
                    } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(25)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        // adjust airDropPot
                        airDropPot_ = (airDropPot_).sub(_prize);

                        // let event know a tier 3 prize was won
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    }
                    // set airdrop happened bool to true
                    _eventData_.compressedData += 10000000000000000000000000000000;
                    // let event know how much was won
                    _eventData_.compressedData += _prize * 1000000000000000000000000000000000;

                    // reset air drop tracker
                    airDropTracker_ = 0;
                }
            }

            // store the air drop tracker number (number of buys since last airdrop)
            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);

            // update player
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            // update round
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);

            // distribute eth
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);

            // call end tx function to fire end tx event.
            endTx(_pID, _team, _eth, _keys, _eventData_);
        }
    }
```

**Description:**

This contract implements a game called FoMo3K. During the game, the function airdrop() is called to determine whether the game ends and how rewards are distributed. However, the aridrop function contains the weak randomness from hasing chain attributes defect, which allows attackers to manipulate this random number for profit.



## Case 4

**Contract: 0xfa2dbc4eb68ca6e20be05c8a3d0a6ebeaedc169d**

**Defect:  Cross-Contract Signature Replay**

**Impact: Allow Cross Contract Signature Replay Attack**

**Defective Functions：**

```solidity
    //
    // Verify Approval Digital Signature
    //
    function verifySenderApproved(
        bool isCurator,
        bool oneFree,
        bytes memory signature
    ) private view {
        bytes32 hashedInsideContract = keccak256(
            abi.encodePacked(msg.sender, isCurator, oneFree)
        );
        bytes32 messageDigest = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                hashedInsideContract
            )
        );
        address recovered = ECDSA.recover(messageDigest, signature);
        if (recovered != hugApprovalSigner) revert InvalidApproval();
    }
    
        function mintHUG(
        uint256 count,
        bytes memory signature,
        bool isCurator,
        bool oneFree
    ) public payable {
        unchecked {
            // Verify Minting is Enabled
            if (!mintEnabled) revert MintNotEnabled();

            // Verify Max Mints Not Exceeded
            uint256 mintsUsedCount = _numberMinted(msg.sender);
            uint256 mintsMax = isCurator ? maxMintsCurators : maxMints;
            if ((mintsUsedCount + count) > mintsMax) revert MaxMintsExceeded();

            // Check Total Supply
            if ((totalSupply() + count) > mintMaxSupply)
                revert MintCapacityExceeded();

            // Verify Sufficient ETH
            uint256 ethRequired = calculateEthRequired(
                oneFree,
                mintsUsedCount,
                count
            );
            if (msg.value < ethRequired) revert InsufficientFunds();

            // Verify Digital Signature
            verifySenderApproved(isCurator, oneFree, signature);
            // Mint!
            _safeMint(msg.sender, count);
        }
    }
```

**Description:**

The signature verification logic in this contract has the cross-contract signature replay defect. Specifically, the signed message does not include the current contract's address, allowing the signature to be replayed across different contracts. Notably, we found another contract (https://etherscan.io/tx/0x065f6d5d9b4be74d2d26753761aff3a51ae94dc867f6eb006336b784ca44ba84) on Ethereum that has an identical bytecode to this contract. As a result, signatures for these two contracts are interchangeable, potentially leading to real-world cross-contract signature replay attacks.
