// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error CarbonTrader_NotOwner();
error CarbonTrader_paramError();
error CarbonTrader_TransferFailed();

contract CarbonTrader{
    // storage quota of address
    mapping (address => uint256) private s_addressToAllowances;
    mapping (address => uint256) private s_forzenAllowances;
    mapping (string => trade) private s_trade;
    mapping (address => uint256) private s_auctionAmount;

    struct trade {
        address seller;      // seller address
        uint256 sellAmount;  // carbon amount for selling
        uint256 startTimeStamp;  // selling start time stamp
        uint256 endTimeStamp;   //selling end time stamp 
        uint256 miniumimBidAmount;  // min number of selling
        uint256 initPriceOfUnit;  // starting price per unit
        // buyer information
        mapping (address => uint256) deposits;
        mapping (address => string) bidInfos;
        mapping (address => string) bidSecrets;
    }

    address private immutable i_owner;
    IERC20 private immutable i_usdtToken;

    constructor (address usdtTokenAddress) {
        i_owner = msg.sender;
        i_usdtToken = IERC20(usdtTokenAddress);
    }

    //modifier check sender is  owner or not
    modifier onlyOwner() {
        if (msg.sender != i_owner){
            revert CarbonTrader_NotOwner();
        }
        _;
    }

    
    function issueAllowance(address user, uint256 amount) public onlyOwner{
        s_addressToAllowances[user] += amount;
    }

    function getAllownance (address user) public view returns(uint256) {
        return s_addressToAllowances[user];
    }

    function freezeAllowance (address user, uint256 freezedAmount) public onlyOwner {
        s_addressToAllowances[user] -= freezedAmount;
        s_forzenAllowances[user] += freezedAmount;
    }

    function unfreeze (address user, uint256 freezedAmount) public onlyOwner{
        s_addressToAllowances[user] += freezedAmount;
        s_forzenAllowances[user] -= freezedAmount;   
    }

    function getForzenAllowance (address user) public view returns (uint256){
        return s_forzenAllowances[user];
    }

    function destoryAllowance (address user, uint256 destoryAmount) public onlyOwner {
        s_addressToAllowances[user] -= destoryAmount;
    }

    function destoryAllowance(address user) public onlyOwner {
        s_addressToAllowances[user] = 0;
        s_forzenAllowances[user] = 0;
    }

    function startTrade (
        string memory tradeID,
        uint256 amount,
        uint256 startTimeStamp,
        uint256 endTimeStamp,
        uint256 miniumimBidAmount,
        uint256 initPriceOfUnit
    ) public {
        if (amount <= 0 || 
        startTimeStamp <= endTimeStamp || 
        miniumimBidAmount <= 0 || 
        initPriceOfUnit <= 0 || 
        miniumimBidAmount > amount
        ) revert CarbonTrader_paramError();

        trade storage newTrade = s_trade[tradeID];
        newTrade.seller = msg.sender;
        newTrade.sellAmount = amount;
        newTrade.startTimeStamp = startTimeStamp;
        newTrade.endTimeStamp = endTimeStamp;
        newTrade.miniumimBidAmount = miniumimBidAmount;

        s_addressToAllowances[msg.sender] -= amount;
        s_forzenAllowances[msg.sender] += amount;
    }

    function getTrade (string memory tradeID) public view returns (address, uint256, uint256, uint256, uint256, uint256) {
        trade storage curTrade = s_trade[tradeID];
        return (
            curTrade.seller,
            curTrade.sellAmount,
            curTrade.startTimeStamp,
            curTrade.endTimeStamp,
            curTrade.miniumimBidAmount,
            curTrade.initPriceOfUnit
        );
    }

    function deposit(string memory tradeID, uint256 amount, string memory info) public {
        trade storage curTrade = s_trade[tradeID];

        bool success = i_usdtToken.transferFrom(msg.sender, address(this), amount);
        if (!success) revert CarbonTrader_TransferFailed();

        curTrade.deposits[msg.sender] = amount;
        setBidInfo(tradeID, info);
    }

    function refundDeposit(string memory tradeID) public {
        trade storage curTrade = s_trade[tradeID];
        uint256 depositAmount = curTrade.deposits[msg.sender];
        curTrade.deposits[msg.sender] = 0;

        bool success = i_usdtToken.transfer(msg.sender, depositAmount);
        if (!success) {
            curTrade.deposits[msg.sender] = depositAmount;
        revert CarbonTrader_TransferFailed();
        }
    }

    function setBidInfo (string memory tradeID, string memory info) public {
        trade storage curTrade = s_trade[tradeID];
        curTrade.bidInfos[msg.sender] = info;
    }

    function setBidSecret(string memory tradeID, string memory secret) public {
        trade storage curTrade = s_trade[tradeID];
        curTrade.bidSecrets[msg.sender] = secret;
    }

    function getBidInfo(string memory tradeID) public view returns (string memory) {
        trade storage curTrade = s_trade[tradeID];
        return curTrade.bidInfos[msg.sender];
    } 

    function finalizeAuctionAndTransferCarbon(
        string memory tradeID,
        uint256 allowanceAmount,
        uint256 addtionalAmountToPay
    ) public {
        // 获取保证金
        uint256 depositAmount = s_trade[tradeID].deposits[msg.sender];
        s_trade[tradeID].deposits[msg.sender] = 0;

        //保证金和补交的钱给卖家
        address seller = s_trade[tradeID].seller;
        s_auctionAmount[seller] += depositAmount + addtionalAmountToPay;
        
        //扣去卖家的 碳额度
        s_forzenAllowances[seller] = 0;

        //增加买家的 碳额度
        s_addressToAllowances[msg.sender] += allowanceAmount;

        bool success = i_usdtToken.transferFrom(msg.sender, address(this), addtionalAmountToPay);
        if (!success) revert CarbonTrader_TransferFailed();
    }

    function withdrawAuctionAmount() public {
        uint256 auctionAmount = s_auctionAmount[msg.sender];
        s_auctionAmount[msg.sender] = 0;
        
        bool success = i_usdtToken.transfer(msg.sender, auctionAmount);
        if (!success) {
            s_auctionAmount[msg.sender] = auctionAmount;
            revert CarbonTrader_TransferFailed();
        }
    }
} 