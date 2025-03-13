// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";



interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}



interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);



    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}



interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);



    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);



    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;



    event Mint(address indexed sender, uint amount0, uint amount1);

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    event Swap(

        address indexed sender,

        uint amount0In,

        uint amount1In,

        uint amount0Out,

        uint amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);



    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;



    function initialize(address, address) external;

}



library MerkleProof {

    /**

     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree

     * defined by `root`. For this, a `proof` must be provided, containing

     * sibling hashes on the branch from the leaf to the root of the tree. Each

     * pair of leaves and each pair of pre-images are assumed to be sorted.

     */

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        return processProof(proof, leaf) == root;

    }



    /**

     * @dev Calldata version of {verify}

     *

     * _Available since v4.7._

     */

    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        return processProofCalldata(proof, leaf) == root;

    }



    /**

     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up

     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt

     * hash matches the root of the tree. When processing the proof, the pairs

     * of leafs & pre-images are assumed to be sorted.

     *

     * _Available since v4.4._

     */

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Calldata version of {processProof}

     *

     * _Available since v4.7._

     */

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by

     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerify(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProof(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Calldata version of {multiProofVerify}

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerifyCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProofCalldata(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction

     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another

     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false

     * respectively.

     *

     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree

     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the

     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).

     *

     * _Available since v4.7._

     */

    function processMultiProof(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            unchecked {

                return hashes[totalHashes - 1];

            }

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    /**

     * @dev Calldata version of {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function processMultiProofCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            unchecked {

                return hashes[totalHashes - 1];

            }

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {

        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);

    }



    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        /// @solidity memory-safe-assembly

        assembly {

            mstore(0x00, a)

            mstore(0x20, b)

            value := keccak256(0x00, 0x40)

        }

    }

}



contract Redimere is ERC20, Ownable {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;



    mapping(address => bool) _excludeFromFee;

    IUniswapV2Router02 public immutable router;

    address public immutable pair;



    mapping(address => bool) blacklists;



    uint public fee = 500;

    bool public _burnFees = false;

    uint public liquidityFee = 8000;

    uint liquifyAbove;

    bool inSwapAndLiquify;

    address public treasury;

    uint public maxTransfer;

    bool public claimStarted = false;

    uint public totalClaimAmount;

    uint public totalClaimedAmount = 0;

    bytes32 merkleRoot;

    uint public claimAmount;

    mapping(address => bool) public didClaim;

    

    modifier lockTheSwap {

        inSwapAndLiquify = true;

        _;

        inSwapAndLiquify = false;

    }



    constructor() ERC20("Redimere", "GRIFT") {

        uint tSupply = 420690000000000 * 10 ** decimals();

        maxTransfer = tSupply * 2 / 100; // 2% of supply

        totalClaimAmount = tSupply / 10; // 10% airdrop

        claimAmount = totalClaimAmount / 1000; // 1000 slots



        _mint(owner(), tSupply - totalClaimAmount);

        _mint(address(this), totalClaimAmount);



        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());



        treasury = owner();

        liquifyAbove = totalSupply() * 5 / 10000; // liquify when contract holds more than 0.05% of the supply



        _excludeFromFee[owner()] = true;

        _excludeFromFee[address(this)] = true;

    }



    function name() public view virtual override returns (string memory) {

        return _name;

    }



    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _transfer(owner, to, amount);

        return true;

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, amount);

        return true;

    }



    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) public virtual override returns (bool) {

        address spender = _msgSender();

        _spendAllowance(from, spender, amount);

        _transfer(from, to, amount);

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) override public virtual returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, allowance(owner, spender) + addedValue);

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) override public virtual returns (bool) {

        address owner = _msgSender();

        uint256 currentAllowance = allowance(owner, spender);

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(owner, spender, currentAllowance - subtractedValue);

        }



        return true;

    }



    function _transfer(

        address from,

        address to,

        uint256 amount

    ) override internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(from, to, amount);



        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");



        uint _availableTokens = availableTokens();

        if (_availableTokens > liquifyAbove && from != pair && !inSwapAndLiquify) {

            swapAndLiquify(_availableTokens);

        }



        _balances[from] = fromBalance - amount;



        if (_excludeFromFee[from] || _excludeFromFee[to]) {

            _balances[to] += amount;

            emit Transfer(from, to, amount);

        } else {

            uint _fee = amount * fee / 10000;

            uint _liquidityFee = _fee * liquidityFee / 10000;

            uint _taxFee = _fee - _liquidityFee;



            if (_burnFees) {

                _balances[to] += amount - _taxFee;

                _balances[treasury] += _taxFee;

                _burn(to, _liquidityFee);

                emit Transfer(from, to, amount - _taxFee);

                emit Transfer(from, treasury, _taxFee);

            } else {

                _balances[to] += amount - _fee;

                _balances[treasury] += _taxFee;

                _balances[address(this)] += _liquidityFee;

                emit Transfer(from, to, amount - _fee);

                emit Transfer(from, treasury, _taxFee);

                emit Transfer(from, address(this), _liquidityFee);

            }

        }



        _afterTokenTransfer(from, to, amount);

    }



    function swapAndLiquify(uint tokenAmount) private lockTheSwap {

        uint half = tokenAmount / 2;

        uint otherHalf = tokenAmount - half;

        uint initialBalance = address(this).balance;

        

        swapTokensForETH(half);



        uint newBalance = address(this).balance - initialBalance;



        addLiquidity(otherHalf, newBalance);

    }



    function swapTokensForETH(uint256 tokenAmount) private {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = router.WETH();



        // make the swap

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0, // accept any amount of ETH

            path,

            address(this),

            block.timestamp

        );

    }



    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios

        _approve(address(this), address(router), tokenAmount);



        // add the liquidity

        router.addLiquidityETH{value: ethAmount}(

            address(this),

            tokenAmount,

            0, // slippage is unavoidable

            0, // slippage is unavoidable

            address(0),

            block.timestamp

        );

    }



    function availableTokens() public view returns (uint) {

        return balanceOf(address(this)) - totalClaimAmount + totalClaimedAmount;

    }



    function blacklist(address[] calldata _addresses, bool _isBlacklisted) external onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {

            blacklists[_addresses[i]] = _isBlacklisted;

        }

    }



    function setFee(uint _fee) external onlyOwner {

        require(_fee <= 1500, "max fee is 15%");

        fee = _fee;

    }



    function setLiquidityFee(uint _fee) external onlyOwner {

        require(_fee <= 10000, "max liquidity fee is 100% of the fees");

        liquidityFee = _fee;

    }



    function burnFees(bool doBurnFees) external onlyOwner {

        _burnFees = doBurnFees;

    }



    function startClaim(bool _isStarted) external onlyOwner {

        claimStarted = _isStarted;

    }



    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {

        merkleRoot = _merkleRoot;

    }



    function setMaxTransfer(uint _maxTransfer) external onlyOwner {

        maxTransfer = _maxTransfer;

    }



    function isWhitelisted(address _address, bytes32[] calldata merkleProof) public view returns (bool) {

        bytes32 node = keccak256(abi.encodePacked(_address));

        return MerkleProof.verifyCalldata(merkleProof, merkleRoot, node);

    }



    function claim(bytes32[] calldata merkleProof) external {

        require(claimStarted, "not started yet");

        require(!didClaim[msg.sender], "already claimed");

        require(totalClaimedAmount < totalClaimAmount, "minted out");

        require(isWhitelisted(msg.sender, merkleProof), "your address cannot claim");



        didClaim[msg.sender] = true;

        totalClaimedAmount += claimAmount;



        _approve(address(this), msg.sender, claimAmount);

        require(transferFrom(address(this), msg.sender, claimAmount));

    }



    function _mint(address account, uint256 amount) override internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        unchecked {

            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.

            _balances[account] += amount;

        }

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }



    function _burn(address account, uint256 amount) override internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        uint256 accountBalance = _balances[account];

        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {

            _balances[account] = accountBalance - amount;

            // Overflow not possible: amount <= accountBalance <= totalSupply.

            _totalSupply -= amount;

        }



        emit Transfer(account, address(0), amount);



        _afterTokenTransfer(account, address(0), amount);

    }



    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) override internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function _spendAllowance(

        address owner,

        address spender,

        uint256 amount

    ) override internal virtual {

        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance != type(uint256).max) {

            require(currentAllowance >= amount, "ERC20: insufficient allowance");

            unchecked {

                _approve(owner, spender, currentAllowance - amount);

            }

        }

    }



    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) override internal virtual {

        require(!blacklists[from] && !blacklists[to], "blacklisted");

        require(amount <= maxTransfer || (from == owner() || to == owner() || from == address(this) || to == address(this)), "cannot exceed max transfer amount");

    }



    function _afterTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) override internal virtual {}



    receive() external payable {

        require(msg.sender == address(router));

    }

}