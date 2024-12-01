// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract CarbonCoin is ERC20{
    address owner;
        constructor(string memory name, string memory symbol, uint256 totalSupply) ERC20(name, symbol) {
            owner = msg.sender;
            _mint(msg.sender, totalSupply);
            greenAction = GreenAction.Transportation;
    }
    enum GreenAction {Transportation, Beverage, Diet, Shopping, Exercise, Recycle}
    //交通、饮品、饮食、购物、运动；
    GreenAction public greenAction;
    struct Action{
        address payable  greenMaker;
        GreenAction name;
        uint256 rewards;
        uint256 carbonSaved;
        string reason;
        uint256 numberOfVerifyers;
        bool verified;
        bool rewarded;
    }
    struct person{

        Action[] actions;//干了哪些被验证的好事
        bool isVerifyer;//是不是验证者
        uint256 verifyNumber;//验证了多少次，用于发放奖励
    }
    mapping (address => person)accounts;//所有人的账号
    Action[] allActions;//所有环保行为
    address payable[]  verifyers;//验证者们

    function MyGreenAction(address account) public view returns (Action[] memory){
        return accounts[account].actions;
    }
    
    function addGreenAction(GreenAction act, uint256 carbonSaved, string memory reason) public returns(Action memory) {
        Action memory tmp;
        greenAction = act;
        tmp.name = greenAction;
        tmp.greenMaker = payable(msg.sender);
        tmp.rewards = 0;
        if(act == GreenAction.Transportation){
            tmp.rewards = carbonSaved*20;//乘搭公共交通，1kg减碳量获得20 CC
        }
        else if(act == GreenAction.Beverage){
            tmp.rewards = carbonSaved*25;//购买一次植物奶获得25 CC
        }
        else if(act == GreenAction.Diet){
            tmp.rewards = carbonSaved*50;//吃一次素食获得50 CC
        }
        else if(act == GreenAction.Shopping){
            tmp.rewards = carbonSaved*50;//参与一次环保购物获得50 CC
        }
        else if(act == GreenAction.Exercise){
            tmp.rewards = carbonSaved*10;//运动一公里获得10 CC
        }
        else if(act == GreenAction.Recycle){
            tmp.rewards = carbonSaved*5;//回收一个物品获得5 CC
        }
        tmp.carbonSaved = carbonSaved;
        tmp.reason = reason;
        tmp.verified = false;
        tmp.rewarded = false;
        allActions.push(tmp);
        return tmp;
    } //这个函数用来申请一次减碳行为

    function verify(address claimer)public returns(bool success){
        bool isVerifyer = false;
        for(uint256 i = 0; i < verifyers.length; ++i){
            if(verifyers[i] == msg.sender){
                isVerifyer = true;
                break;
            }
        }
        require(isVerifyer == true, "You are NOT a verifyer!!!");
        for(uint256 i = 0; i < allActions.length; ++i){
            if(allActions[i].greenMaker == claimer && allActions[i].verified == false){
                allActions[i].numberOfVerifyers++;
                accounts[msg.sender].verifyNumber++;
                if(allActions[i].numberOfVerifyers == 1){
                    allActions[i].verified = true;
                    accounts[claimer].actions.push(allActions[i]);
                }
            }
        }
        return true;
    }//这个函数用来验证一个用户(claimer)的所有行为

    function giveRewards() public returns(bool success){
        require(msg.sender == owner, "You are NOT allowed to use this function!!!");
        require(verifyers.length > 0, "no verifyer.");
        require(allActions.length > 0, "NO green action.");
        for(uint256 i = 0; i < verifyers.length; ++i){
            //transfer(test, accounts[verifyers[i]].verifyNumber*100);
            //_transfer(msg.sender, 0xe7de482d00B7ECCb8cAb7107217049048470A612, accounts[verifyers[i]].verifyNumber*100);
            _transfer(msg.sender, verifyers[i], accounts[verifyers[i]].verifyNumber*5);
            accounts[verifyers[i]].verifyNumber = 0;
        }

        for(uint256 i = 0; i < allActions.length; ++i){
            if(allActions[i].verified == true && allActions[i].rewarded == false){
                
                _transfer(msg.sender, allActions[i].greenMaker, allActions[i].rewards);
                //将第二个参数改成0xe7de482d00B7ECCb8cAb7107217049048470A612可以查看效果
                allActions[i].rewarded = true;
            }
        }
        return true;
    }

    function pointVerifyer(address payable to) public returns(bool success){
        require(msg.sender == owner, "You are NOT allowed to use this function!!!");
        require(accounts[to].isVerifyer == false, "You are already a verifyer.");
        verifyers.push(to);
        accounts[to].isVerifyer = true;
        return success;
    }

    function viewVerifyers() public view returns (address payable[] memory v){
        return verifyers;
    }
    // function viewPersonalDetails() public view returns(person memory){
    //     return accounts[msg.sender];
    // }
}