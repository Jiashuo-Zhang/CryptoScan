//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;





error MintNotStarted();  

error MaxMints();

error SoldOut();

error Underpriced();

error NotWL();

error NotOwner();

error ZeroAddress();

error NotMintPassContract();

error NotAPhysicallyBackedToken();



/*

@0xSimon_

*/

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

import '@openzeppelin/contracts/access/Ownable.sol';

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import "operator-filter-registry/src/DefaultOperatorFilterer.sol";



contract Voka is DefaultOperatorFilterer, ERC721AQueryable, Ownable, ReentrancyGuard {

    using ECDSA for bytes32;



    ///@dev adjust these values

    uint256 public constant MAX_SUPPLY = 5;   

    uint256 private constant NUM_PHYSICALLY_BACKED_TOKENS = 5;

    uint256 private constant MAX_WHITELIST = 0; 



    mapping(uint256 => string) public batchNames;

    mapping(uint256 => uint256) public maxSupplies;

    uint256 public currentBatchNumber;

    uint256 public whitelistMintPrice;

    uint256 public whitelistMintUsdcPrice;

    address private signer;

    IERC721LIKE private mintPassContract;   

    address private constant USDC_ADDRESS_MAINNET =

        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    //usdc contract address on goerli 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;

    MintStatus public mintStatus = MintStatus.INACTIVE;

    enum MintStatus {

        INACTIVE,

        WHITELIST,

        HOLDER        

    } 



    bool private revealed;



    string public baseURI;

    string public notRevealedUri;

    string public uriSuffix = '.json';

 

    mapping(uint256 => bool) private isPhysicallyBackedLocked;



    constructor() ERC721A('Canvas to Code Physicals', 'VOKA') {

        setNotRevealedURI('https://nft.arties.org/vokaArt/notRevealed.json');

    }



    function contractURI() public view returns (string memory) {

        return "https://nft.arties.org/vokaArt/vokaContractMetadata.json";

    }



    /* MINTING */



    //supply check for non holder mint

    function supplyCheck(uint256 amount) internal view {

        if (amount + _nextTokenId() > maxSupplies[currentBatchNumber])

            revert SoldOut();



        //physically backed tokens are 0-4 so we need to add that to the max allowed whitelist supply

        if(amount + _nextTokenId() > (MAX_WHITELIST + NUM_PHYSICALLY_BACKED_TOKENS))

            revert SoldOut(); 

    }



     ///@param amount - the amount a user would like to mint

    ///@param max  - the max amount of mints we are allowing that user.

    ///@param signature the signature that we verify on-chain

    ///@notice max is safe to pass into function args since it's encoded into the signature that we are verifying

    ///@dev The whitelist mint function also serves as the WAITLIST mint function since we can add those signatures to the backend dynamically

    function whitelistMint(

        uint256 amount,

        uint256 max,

        bytes memory signature

    ) external payable {

        if (mintStatus != MintStatus.WHITELIST) revert MintNotStarted();

        supplyCheck(amount);



        if (msg.value == 0) {

            //Will Revert If It Doesen't Go Through

            transferUSDC(whitelistMintUsdcPrice * amount);

        } else {

            if (msg.value < amount * whitelistMintPrice) revert Underpriced();

        }

        // We Hash ['string','uint','address'] [batchName,maxAmount,signer]

        bytes32 hash = keccak256(

            abi.encodePacked(batchNames[currentBatchNumber], max, msg.sender)

        );

        if (hash.toEthSignedMessageHash().recover(signature) != signer)

            revert NotWL();

        if (_numberMinted(msg.sender) + amount > max) revert MaxMints();

        //_mint(msg.sender, amount);

    }



    function airdrop(address[] calldata accounts, uint256[] calldata amounts)

        external

        onlyOwner

    {

        uint256 supply = totalSupply();

        for (uint256 i; i < accounts.length; ++i) {

            if(amounts[i] + supply > (MAX_WHITELIST + NUM_PHYSICALLY_BACKED_TOKENS))

                revert SoldOut(); 

            

            unchecked {

                supply += amounts[i];

            }

            _mint(accounts[i], amounts[i]);

        }

    }



    function mint(uint256[] calldata tokenIds) external {

        uint256 amount = tokenIds.length;

        //NO NEED TO CHECK FOR MAX_SUPPLY since each mint pass get's you a voka.

        if (mintStatus != MintStatus.HOLDER) revert MintNotStarted();

        for (uint256 i; i < amount; ) {

            if (_msgSender() != mintPassContract.ownerOf(tokenIds[i]))

                revert NotOwner();

            //Will Revert From Mint Pass If The Token Is Already Used

            mintPassContract.useMintPassFromArtContract(tokenIds[i]);

            unchecked {

                ++i;

            }

        }

        //_mint(_msgSender(), amount);

    }



    function ownerMint(uint256[] calldata tokenIds) external onlyOwner {

        uint256 amount = tokenIds.length;

        for (uint256 i; i < amount; ) {

            if (_msgSender() != mintPassContract.ownerOf(tokenIds[i]))

                revert NotOwner();

            //Will Revert From Mint Pass If The Token Is Already Used

            mintPassContract.useMintPassFromArtContract(tokenIds[i]);

            unchecked {

                ++i;

            }

        }

        _mint(_msgSender(), amount);

    }



    function mintVokasFromMintPass(address to, uint256 amount) external {

        if (_msgSender() == address(0)) revert ZeroAddress();

        if (_msgSender() != address(mintPassContract))

            revert NotMintPassContract();

        //_mint(to, amount);

    }



    function lockPhysicalAssetFromTrade(uint256[] calldata tokenIds)

        public

        onlyOwner

    {

        for (uint256 i; i < tokenIds.length; ++i) {

            if (tokenIds[i] > (NUM_PHYSICALLY_BACKED_TOKENS - 1))

                revert NotAPhysicallyBackedToken();

            setPhysicallyBackedLockAt(tokenIds[i], true);

        }

    }



    function setPhysicallyBackedLockAt(uint256 index, bool status)

        public

        onlyOwner

    {

        require(index < NUM_PHYSICALLY_BACKED_TOKENS);

        isPhysicallyBackedLocked[index] = status;

    }



    function emergencyUnlockPhysicalAssetFromTrade(uint256[] calldata tokenIds)

        external

        onlyOwner

    {

        for (uint256 i; i < tokenIds.length; ++i) {

            //only tokenIds [0,1,2,3,4]

            if (tokenIds[i] > (NUM_PHYSICALLY_BACKED_TOKENS - 1))

                revert NotAPhysicallyBackedToken();

            //same as setPhysicallyBackedLockAt(tokenIds[i], false);

            delete isPhysicallyBackedLocked[tokenIds[i]];

        }

    }



    function _beforeTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual override(ERC721A) {

        //Tokens [0,1,2,3,4]

        if (startTokenId < NUM_PHYSICALLY_BACKED_TOKENS) {

            for (uint256 i; i < quantity; ) {

                if (isPhysicallyBackedLocked[startTokenId + i])

                    revert('Token is locked');

                unchecked {

                    ++i;

                }

            }

        }

    }

 

    //SETTERS

    function setCurrentBatchNumber(uint256 _newBatchNumber) external onlyOwner {

        currentBatchNumber = _newBatchNumber;

    }



    function setWhitelistMintPrice(uint256 _price) external onlyOwner {

        whitelistMintPrice = _price;

    }



    function setWhitelistMintUsdcPrice(uint256 _price) external onlyOwner {

        whitelistMintUsdcPrice = _price;

    }

    function setMaxSupplyAtIndex(uint256 index, uint256 val)

        external

        onlyOwner

    {              

        maxSupplies[index] = val;

    }



    function setBatchNamesAtIndex(uint256 index, string memory batchName)

        external

        onlyOwner

    {

        batchNames[index] = batchName;

    }



    function setSigner(address _signer) external onlyOwner {

        require(_signer != address(0));

        signer = _signer;

    }

    

    function switchReveal() external onlyOwner {

        revealed = !revealed;

    }



    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {

        notRevealedUri = _notRevealedURI;

    }



    function setBaseURI(string memory _newBaseURI) public onlyOwner {

        baseURI = _newBaseURI;

    }



    function setUriSuffix(string memory _newSuffix) external onlyOwner {

        uriSuffix = _newSuffix;

    }



    function setHolderMintOn() external onlyOwner {

        mintStatus = MintStatus.HOLDER;

    }



    function setWhitelistMintOn() external onlyOwner {

        mintStatus = MintStatus.WHITELIST;

    } 



    function setMintOff() external onlyOwner {

        mintStatus = MintStatus.INACTIVE;

    }



    function setMintPassContract(address _mintPassContract) external onlyOwner {

        mintPassContract = IERC721LIKE(_mintPassContract);

    }



    function transferToAndLock(

        address from,

        uint256 tokenId,

        address to

    ) external onlyOwner {

        transferFrom(from, to, tokenId);

        isPhysicallyBackedLocked[tokenId] = true;

    }



    function tokenURI(uint256 tokenId)

        public

        view

        override(IERC721A, ERC721A)

        returns (string memory)

    {

        if (revealed == false) {

            return notRevealedUri;

        }



        string memory currentBaseURI = baseURI;

        return

            bytes(currentBaseURI).length > 0

                ? string(

                    abi.encodePacked(

                        currentBaseURI,

                        _toString(tokenId),

                        uriSuffix

                    )

                )

                : '';

    }



    function withdraw() external onlyOwner nonReentrant {

        payable(msg.sender).transfer(address(this).balance);

        uint256 usdcBalance = MinimalERC20(USDC_ADDRESS_MAINNET).balanceOf(

            address(this)

        );

        if (usdcBalance > 0) {

            MinimalERC20(USDC_ADDRESS_MAINNET).transfer(

                msg.sender,

                usdcBalance

            );

        }

    }



    function transferUSDC(uint256 amount) internal {

        MinimalERC20(USDC_ADDRESS_MAINNET).transferFrom(

            msg.sender,

            address(this),

            amount

        );

    }



    function setApprovalForAll(address operator, bool approved) public override(IERC721A, ERC721A) onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }

    

    function approve(address operator, uint256 tokenId) public payable override(IERC721A, ERC721A) onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    function transferFrom(address from, address to, uint256 tokenId) public payable override(IERC721A, ERC721A) onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override(IERC721A, ERC721A) onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)

        public

        payable

        override(IERC721A, ERC721A)

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    



}



interface MinimalERC20 {

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);



    function balanceOf(address user) external view returns (uint256);



    function transfer(address to, uint256 amount) external returns (bool);

}



interface IERC721LIKE {

    function ownerOf(uint256 tokenId) external view returns (address);



    function useMintPassFromArtContract(uint256 tokenIds) external;

}