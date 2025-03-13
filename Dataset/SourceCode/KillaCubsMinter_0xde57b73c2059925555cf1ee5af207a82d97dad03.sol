// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./SuperOwnable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

enum MintPhaseType {
    Claim,
    Redeem,
    Private,
    Holders,
    Public
}

struct MintPhase {
    MintPhaseType phaseType;
    uint32 start;
    uint32 end;
    address signer;
}

struct MintCounters {
    uint16 linked;
    uint16 batched;
    uint16 redeems;
    uint16 stakes;
}

struct Wallet {
    uint16 balance;
    uint16 stakes;
    uint16 linkedMints;
    uint16 batchedMints;
    uint16 allowlistMints;
    uint16 privateMints;
    uint16 holderMints;
    uint16 redeems;
}

interface IKillaPasses {
    function burn(uint256 typeId, address owner, uint256 n) external;
}

interface IKillaCubs {
    function mint(address owner, uint256[] calldata ids, bool staked) external;

    function mint(address owner, uint16 n, bool staked) external;

    function mintRedeemed(address owner, uint16 n, bool staked) external;

    function useAllowance(
        address sender,
        address main,
        uint256 n,
        bool holders,
        uint256 allowance
    ) external;

    function counters() external returns (MintCounters memory);

    function wallets(address) external returns (Wallet memory);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract KillaCubsMinter is SuperOwnable {
    using ECDSA for bytes32;
    uint16 constant MINTABLE_SUPPLY = 8888 - 3333 - 333;
    uint256 public mintPrice = 0.25 ether;
    uint256 public publicMaxPerWallet = 3;

    IKillaCubs public immutable cubs;
    IERC721 public immutable bears;
    IKillaPasses public immutable passes;
    IERC721 public immutable kilton;
    IERC721 public immutable labs;

    mapping(MintPhaseType => MintPhase) public mintPhases;

    error NotAllowed();
    error UnknownMintPhase();
    error MintPhaseNotStarted();
    error MintPhaseEnded();
    error NotEnoughEth();
    error Overflow();

    constructor(
        address cubsAddress,
        address bearsAddress,
        address passesAddress,
        address kiltonAddress,
        address labsAddress,
        address superOwner
    ) SuperOwnable(superOwner) {
        cubs = IKillaCubs(cubsAddress);
        bears = IERC721(bearsAddress);
        passes = IKillaPasses(passesAddress);
        kilton = IERC721(kiltonAddress);
        labs = IERC721(labsAddress);
    }

    function claim(uint256[] calldata ids, bool staked) public payable {
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            if (
                bears.ownerOf(id) != msg.sender &&
                kilton.ownerOf(id) != msg.sender &&
                labs.ownerOf(id) != msg.sender
            ) revert NotAllowed();
        }
        cubs.mint(msg.sender, ids, staked);
    }

    function redeem(
        uint16 n,
        bool staked
    ) external checkPhase(MintPhaseType.Redeem) {
        passes.burn(1, msg.sender, n);
        cubs.mintRedeemed(msg.sender, n, staked);
        if (cubs.counters().redeems > 333) revert Overflow();
    }

    function mintPrivate(
        uint16 n,
        MintPhaseType mintPhase,
        address mainWallet,
        uint256 allowance,
        bytes calldata signature,
        bool staked
    ) external payable checkPayment(n) checkSupply checkPhase(mintPhase) {
        cubs.mint(msg.sender, n, staked);

        cubs.useAllowance(
            msg.sender,
            mainWallet,
            n,
            mintPhase == MintPhaseType.Holders,
            allowance
        );

        MintPhase memory phase = mintPhases[mintPhase];
        if (
            phase.signer !=
            ECDSA
                .toEthSignedMessageHash(
                    abi.encodePacked(
                        msg.sender,
                        mainWallet,
                        mintPhase,
                        allowance
                    )
                )
                .recover(signature)
        ) revert NotAllowed();
    }

    function mint(
        uint16 n,
        bool staked
    )
        external
        payable
        checkPayment(n)
        checkPhase(MintPhaseType.Public)
        checkSupply
    {
        cubs.mint(msg.sender, n, staked);
        Wallet memory w = cubs.wallets(msg.sender);
        uint256 minted = w.batchedMints - (w.redeems + w.allowlistMints);
        if (minted > publicMaxPerWallet) revert Overflow();
    }

    // Admin
    function configureMintPhases(
        MintPhase[] calldata phases
    ) external onlyOwner {
        for (uint256 i = 0; i < phases.length; i++) {
            MintPhase memory phase = phases[i];
            mintPhases[phase.phaseType] = phase;
        }
    }

    function setMintPrice(uint256 price) external onlyOwner {
        mintPrice = price;
    }

    function setPublicMaxPerWallet(uint256 max) external onlyOwner {
        publicMaxPerWallet = max;
    }

    function withdraw(address to) external onlyOwner {
        if (to == address(0)) revert NotAllowed();
        payable(to).transfer(address(this).balance);
    }

    // Modifiers

    modifier checkPayment(uint256 n) {
        if (msg.value != n * mintPrice) {
            revert NotEnoughEth();
        }
        _;
    }

    modifier checkPhase(MintPhaseType mintPhase) {
        if (msg.sender != owner) {
            MintPhase storage phase = mintPhases[mintPhase];
            uint256 ts = block.timestamp;
            if (phase.start == 0) revert UnknownMintPhase();
            if (ts < phase.start) revert MintPhaseNotStarted();
            if (phase.end != 0 && ts > phase.end) revert MintPhaseEnded();
        }
        _;
    }

    modifier checkSupply() {
        _;
        MintCounters memory counters = cubs.counters();
        if (counters.batched - counters.redeems > MINTABLE_SUPPLY)
            revert Overflow();
    }
}