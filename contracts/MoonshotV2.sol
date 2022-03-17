/*

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗███████╗██╗  ██╗ ██████╗ ████████╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██╔════╝██║  ██║██╔═══██╗╚══██╔══╝
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║███████╗███████║██║   ██║   ██║   
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║   ██║   ██║   
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║███████║██║  ██║╚██████╔╝   ██║   
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝  v2

Moonshot is a deflationary, frictionless yield and liquidity protocol.

For every transaction, a fee of max. 10% is decucted and shared between holders, the liqduity pool and the dev/marketing wallet.
As the burn address participates as a holder, the supply is forever decreasing.

Started out at DEFI meme token, moonshot features MoonBoxes and MoonSea.

This contract features:
 - blacklisting for enhanced security
 - buy back mechanism
 - router and pair address are dynamic
 - rescue BNB sent by mistake
 - higher precision fees
 - fee can be setup per address

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

import "contracts/Context.sol";
import "contracts/IERC20.sol";
import "contracts/SafeMath.sol";
import "contracts/Ownable.sol";
import "contracts/IUniswapV2Factory.sol";
import "contracts/IUniswapV2Pair.sol";
import "contracts/IUniswapV2Router.sol";

contract MoonshotV2 is Context, IERC20, Ownable {
    using SafeMath for uint256;
  
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _specialFees;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromReward;
    mapping( address => bool) private _isBlackListed;
    mapping( address => bool) private _hasSpecialFee;

    address[] private _excludedFromReward;

    address payable public moonshotFundAddress = payable(0x000000000000000000000000000000000000dEaD);
    address payable public buyBackAddress = payable(0x000000000000000000000000000000000000dEaD);

    uint256 public numTokensToSell = 500000 * 10**6 * 10**9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    string private constant _name = "Moonshot";
    string private constant _symbol = "MSHOT";
    uint8 private constant _decimals = 9;
    
    uint256 public _taxFee = 400;
    uint256 private _prevTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 400;
    uint256 private _prevLiquidityFee = _liquidityFee;

    uint256 public _projectFee = 150;
    uint256 private _prevProjectFee = _projectFee;

    uint256 public _buyBackFee = 50;
    uint256 private _prevBuyBackFee = _buyBackFee;

    uint256 public _totalLiqFee = 0;
    uint256 private _prevTotalLiqFee = _totalLiqFee;

    uint256 private _tFeeTotal;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private inSwapAndLiquify;
    
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyMaxAmountEnabled = true;

    uint256 private constant MIN_BUY_AMOUNT = 0;
    uint256 private constant MAX_BUY_AMOUNT =  100000000 * (10 ** 18); // 100 million bnb
    uint256 public _buyBackMinAmount = MIN_BUY_AMOUNT;
    uint256 public _buyBackMaxAmount = MAX_BUY_AMOUNT;
    uint256 public _buyBackSize = 1500; // 15 %
    uint256 private _buyBackCooldownInterval = (1 hours);
    uint256 private _buyBackCooldownTimestamp = 0;

    uint256 private timeLock = 0;
        
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyMaxAmountEnabled(bool enabled, uint256 maxTokenIntoLiquidity);
    event SwapAndFundProject(uint256 amount);
    event SwapForBuyBack(uint256 amount);
    event SetPancakeRouterAddress(address newRouter, address pair);
    event SetPancakePairAddress(address newPair);
    event SetMoonshotFundAddress(address newAddress);
    event SetFees(uint256 newRewardFee, uint256 newLiquidityFee, uint256 newProjectFee, uint256 newBuyBackFee);
    event ExcludeFromReward(address account);
    event IncludeInReward(address account);
    event SetFee(address account, uint256 newFee, bool enabled);
    event AddToBlackList(address account);
    event RemoveFromBlackList(address account);
    event SetnumTokensToSell(uint256 amount);
    event RescueBNB(uint256 amount);
    event TimeLock(uint256 timestamp);
    event SetBuyBackConfiguration(uint256 amountMin, uint256 amountMax, uint256 cooldownInterval, uint256 buyBackSize);
    event SetBuyBackAddress(address newAddress);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        
        // BSC MainNet, Pancakeswap Router
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Ropsten, Uniswap Router
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        // BSC TestNet
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
       
        //exclude owner and this contract from fee
        _hasSpecialFee[ owner() ] = true;
        _hasSpecialFee[ address(this) ] = true;

        //exclude pair from receiving rewards
        _isExcludedFromReward[ uniswapV2Pair ] = true;
     
        _totalLiqFee = _liquidityFee.add(_projectFee).add(_buyBackFee);
        _prevTotalLiqFee = _totalLiqFee;

        timeLock = block.timestamp;
        _buyBackCooldownTimestamp = block.timestamp;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function isFeeForAddressEnabled(address account) external view returns (bool) {
        return _hasSpecialFee[ account ];
    }

    function getFeeForAddress(address account) external view returns (uint256) {
        return  _specialFees[ account ];
    }

    function setPancakeRouterAddress(address routerAddress) external onlyOwner() {
        require(address(uniswapV2Router) != routerAddress);
        IUniswapV2Router02 newRouter = IUniswapV2Router02( routerAddress );
        // test if pair exists and create if it does not exist
        address pair = IUniswapV2Factory(newRouter.factory()).getPair(address(this), newRouter.WETH());
        if (pair == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(newRouter.factory()).createPair(address(this), newRouter.WETH());
        }
        else {
            uniswapV2Pair = pair;
        }

        // approve new router to spend contract tokens
        _approve( address(this), routerAddress, MAX );

        // reset approval of old router
        _approve( address(this), address(uniswapV2Router), 0);

        // update state
        uniswapV2Router = IUniswapV2Router02(newRouter);

        emit SetPancakeRouterAddress(routerAddress, uniswapV2Pair);
    }

    function setPancakePairAddress(address newPair) external onlyOwner() {
        uniswapV2Pair = newPair;

        emit SetPancakePairAddress(uniswapV2Pair);
    }

    function setMoonshotFundAddress(address newAddress) external onlyOwner() {
        moonshotFundAddress = payable(newAddress);

        emit SetMoonshotFundAddress(moonshotFundAddress);
    }

   function setFees(uint256 newRewardFee, uint256 newLiquidityFee, uint256 newProjectFee, uint256 newBuyBackFee) external onlyOwner() {
        require( (newRewardFee.add(newLiquidityFee).add(newProjectFee)) <= 1000, "Total fees must be <= 1000" );
        
        _taxFee = newRewardFee;
        _liquidityFee = newLiquidityFee;
        _projectFee = newProjectFee;
        _buyBackFee = newBuyBackFee;
        _totalLiqFee = _liquidityFee.add(_projectFee).add(_buyBackFee);
        
        emit SetFees(newRewardFee, newLiquidityFee, newProjectFee, newBuyBackFee);
    }

    function setFee(address account, uint256 newFee, bool enabled) external onlyOwner {
        require( newFee <= 1000, "Total fee must be <= 1000" );

        _specialFees[ account ] = newFee;
        _hasSpecialFee[ account ] = enabled;
        emit SetFee(account, newFee, enabled);
    }

    function setBuyBackConfiguration(uint256 amountMin, uint256 amountMax, uint256 cooldownInterval, uint256 buyBackSize) external onlyOwner {
        require( amountMin > MIN_BUY_AMOUNT );
        require( amountMin <= _buyBackMaxAmount) ;
        require( amountMax > MIN_BUY_AMOUNT );
        require( amountMax <= MAX_BUY_AMOUNT );
        require( buyBackSize > 0 );
        require( buyBackSize <= (10 ** 4)) ;

        _buyBackMinAmount = amountMin;
        _buyBackMaxAmount = amountMax;
        _buyBackCooldownInterval = cooldownInterval;
        _buyBackCooldownTimestamp  = block.timestamp;
        _buyBackSize = buyBackSize;

        emit SetBuyBackConfiguration(amountMin, amountMax, cooldownInterval, buyBackSize);
    }

    function setBuyBackAddress(address newAddress) external onlyOwner() {
        buyBackAddress = payable(newAddress);

        emit SetBuyBackAddress(moonshotFundAddress);
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        require(_excludedFromReward.length < 100);
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);

        emit ExcludeFromReward(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account], "Account is already included");
        require(_excludedFromReward.length < 100);
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
                uint256 currentRate = _getRate();
                _rOwned[account] = _tOwned[account].mul(currentRate);
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();
                break;
            }
        }

        emit IncludeInReward(account);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function addToBlackList(address account) external onlyOwner {
        _isBlackListed[ account ] = true;

        emit AddToBlackList(account);
    }

    function removeFromBlackList(address account) external onlyOwner {
        _isBlackListed[ account ] = false;

        emit RemoveFromBlackList(account);
    }

    function isBlackListed(address account) external view returns(bool) {
        return _isBlackListed[ account ];
    }

    function setSwapAndLiquifyMaxAmountEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyMaxAmountEnabled = _enabled;

        emit SwapAndLiquifyMaxAmountEnabled(_enabled, numTokensToSell);
    }

    function setSwapAndLiquifyMaxAmount(uint256 amount) external onlyOwner {
        require( amount > 0 );
        numTokensToSell = amount;

        emit SetnumTokensToSell(amount);
    }

    // contract gains BNB over time
    function rescueBNB(uint256 amount) external onlyOwner {
        payable( msg.sender ).transfer(amount);

        emit RescueBNB(amount);
    }
 
    // remove at most 10% of the liquidity and put a time lock of 4 weeks
    function removeLiquidity(uint256 percentage) external onlyOwner lockTheSwap {

        require(timeLock <= block.timestamp, "Remove Liquidity is time locked.");
        require(percentage <= 1000, "Can only remove up to 10% of LP tokens");
        
        uint256 liquidity = IERC20(uniswapV2Pair).balanceOf(address(this));
        require( liquidity > 0, "LP token balance is 0");

        uint256 amount = liquidity.mul(percentage).div(10**4); // at most 10% 
        
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), amount);
        uniswapV2Router.removeLiquidityETHSupportingFeeOnTransferTokens(address(this), amount, 0, 0, msg.sender, block.timestamp.add(60) );

        // set a new timed lock
        timeLock = block.timestamp + (4 weeks);

        emit TimeLock(timeLock);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_rOwned[_excludedFromReward[i]] > rSupply || _tOwned[_excludedFromReward[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedFromReward[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedFromReward[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**4
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_totalLiqFee).div(
            10**4
        );
    }

    function saveAllFees() private {
        _prevTaxFee = _taxFee;
        _prevTotalLiqFee = _totalLiqFee;
        _prevProjectFee = _projectFee;
        _prevLiquidityFee = _liquidityFee;
        _prevBuyBackFee = _buyBackFee;
    }
  
    function setSpecialFee(address from, address to) private returns (bool) {
        
        uint256 totalFee = _taxFee.add(_liquidityFee).add(_projectFee).add(_buyBackFee);
        if( totalFee == 0 ) {
            return false; // don't take fee
        }

        // either one or both have a special fee, take the lowest
        address lowestFeeAccount = from;
        if( _hasSpecialFee[from] && _hasSpecialFee[to]) {
            lowestFeeAccount = ( _specialFees[from] > _specialFees[to] ? to : from );
        } else if ( _hasSpecialFee[to] ) {
            lowestFeeAccount = to;
        }

        // get the fee
        uint256 fee = _specialFees[ lowestFeeAccount ];
        
        // set fees
        _taxFee = fee.mul(_taxFee).div( totalFee );
        _liquidityFee = fee.mul(_liquidityFee).div( totalFee );
        _projectFee = fee.mul(_projectFee).div( totalFee );
        _buyBackFee = fee.mul(_buyBackFee).div( totalFee );

        _totalLiqFee = _liquidityFee.add(_projectFee).add(_buyBackFee);

        return ( _taxFee.add(_liquidityFee).add(_buyBackFee) ) > 0;
    }

    function restoreAllFees() private {
        _taxFee = _prevTaxFee;
        _totalLiqFee = _prevTotalLiqFee;
        _projectFee = _prevProjectFee;
        _liquidityFee = _prevLiquidityFee;
        _buyBackFee = _prevBuyBackFee;
    }
 
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) );
        require(spender != address(0) );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(from), "Transfer amount exceeds allowance");
        require(amount >= 0, "Transfer amount must be >= 0");
        require(!_isBlackListed[from], "From address is blacklisted");
        require(!_isBlackListed[to], "To address is blacklisted");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > numTokensToSell;
        bool takeFee = true;
        
        // save all the fees
        saveAllFees();

        // if the address has a special fee, use it
        if( _hasSpecialFee[from] || _hasSpecialFee[to] ) {
            takeFee = setSpecialFee(from,to);
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled &&
            _totalLiqFee > 0
        ) {
            if( swapAndLiquifyMaxAmountEnabled ) {
                contractTokenBalance = numTokensToSell;
            }
            
            swapAndLiquify(contractTokenBalance);
        }
        
        //transfer amount, it will deduct fee and reflect tokens
        _tokenTransfer(from,to,amount);

        // restore all the fees
        restoreAllFees();
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 forLiquidity = tAmount.mul(_liquidityFee).div(_totalLiqFee);
        uint256 forBuyBack = tAmount.mul(_buyBackFee).div(_totalLiqFee);
        uint256 forWallets = tAmount.sub(forLiquidity).sub(forBuyBack);
        
        if(forLiquidity > 0 && _liquidityFee > 0)
        {
            // sell half the tokens for BNB and add liquidity
            uint256 half = forLiquidity.div(2);
            uint256 otherHalf = forLiquidity.sub(half);
    
            uint256 initialBalance = address(this).balance;
            swapTokensForBNB(half);

            uint256 newBalance = address(this).balance.sub(initialBalance);
            addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
                
        if(forWallets > 0 && _projectFee > 0) 
        {
            // sell tokens for BNB and send to project fund
            uint256 initialBalance = address(this).balance;
            swapTokensForBNB(forWallets);

            uint256 newBalance = address(this).balance.sub(initialBalance);
            transferToAddressBNB(moonshotFundAddress, newBalance);

            emit SwapAndFundProject(newBalance);
        }

        if(forBuyBack >0 && _buyBackFee > 0) {

            uint256 buyBackAmount = address(this).balance.mul( _buyBackSize ).div( 10 ** 4);

            // if there is a max set on amount to buy back, cap the amount of bnb to spent
            if( buyBackAmount > _buyBackMaxAmount ) {
                buyBackAmount = _buyBackMaxAmount;
            }

            // buy if more than minimum amount of bnb to spent
            if( buyBackAmount > _buyBackMinAmount && _buyBackCooldownTimestamp < block.timestamp) {
                swapForBuyback(buyBackAmount);

                _buyBackCooldownTimestamp = block.timestamp + _buyBackCooldownInterval;
            }
        }

    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if( _allowances[ address(this)][address(uniswapV2Router)] < tokenAmount )
            _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapForBuyback(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            buyBackAddress,
            block.timestamp
        );

        emit SwapForBuyBack(amount);
    }

    function transferToAddressBNB(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {        
        if( _allowances[ address(this)][address(uniswapV2Router)] < tokenAmount )
            _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
   
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

     //to receive BNB from pancakeV2Router when swapping
    receive() external payable {}

}