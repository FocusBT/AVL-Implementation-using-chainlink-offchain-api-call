#  Hardhat Project

1) create .env file

2) add these in .env file:
  METAMASK_PRIVATE_KEY=""
  QUICKNODE_SEPHOLIA_KEY=""    // https://www.quicknode.com/endpoints
  SEPHOLIA_ETHERSCAN_API=""   //  https://etherscan.io/myapikey
  
3) npm i

4(i)  ) npx hardhat run --network sepholia  scripts/deploy.js   // it will deploy the transfer/transferFrom approached smart contract
4(ii) ) npx hardhat run --network sepholia  scripts/deploy2.js   // it will deploy the approve/increaseAllowance approached smart contract





 
 
