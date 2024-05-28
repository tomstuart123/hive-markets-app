// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConditionalTokensWrapper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OutcomeResolution.sol";


contract MarketMaker {
    IERC20 public collateralToken;
    ConditionalTokensWrapper public conditionalTokens;
    OutcomeResolution public outcomeResolution;

    struct Market {
        string title;
        string question;
        string source;
        uint256 endTime;
        bool resolved;
        uint256 yesCount;
        uint256 noCount;
        mapping(address => uint256) liquidity;
    }

    mapping(uint256 => Market) public markets;
    uint256 public marketCount;

    event MarketCreated(uint256 indexed marketId, string title, string question, uint256 endTime);
    event LiquidityAdded(uint256 indexed marketId, address indexed provider, uint256 amount);

    constructor(address _collateralToken, address _conditionalTokensWrapper, address _outcomeResolution) {
        collateralToken = IERC20(_collateralToken);
        conditionalTokens = ConditionalTokensWrapper(_conditionalTokensWrapper);
        outcomeResolution = OutcomeResolution(_outcomeResolution);
    }

    function createMarket(string memory _title, string memory _question, string memory _source, uint256 _endTime) public {
        marketCount++;
        Market storage market = markets[marketCount];
        market.title = _title;
        market.question = _question;
        market.source = _source;
        market.endTime = _endTime;

        emit MarketCreated(marketCount, _title, _question, _endTime);
    }

    function addLiquidity(uint256 _marketId, uint256 _amount) public {
        Market storage market = markets[_marketId];
        require(collateralToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        market.liquidity[msg.sender] += _amount;
        emit LiquidityAdded(_marketId, msg.sender, _amount);
    }

    function getMarket(uint256 _marketId) public view returns (
        string memory title,
        string memory question,
        string memory source,
        uint256 endTime,
        bool resolved,
        uint256 yesCount,
        uint256 noCount
    ) {
        Market storage market = markets[_marketId];
        return (
            market.title,
            market.question,
            market.source,
            market.endTime,
            market.resolved,
            market.yesCount,
            market.noCount
        );
    }

    function getMarketLiquidity(uint256 _marketId, address _provider) public view returns (uint256) {
        return markets[_marketId].liquidity[_provider];
    }
}
