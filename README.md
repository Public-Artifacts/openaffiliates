# Open Affiliates

## Affiliate rewards for referring smart contract transactions

Open Affiliates is a decentralized referral system designed to incentivize community-aligned growth in the web3 ecosystem. By leveraging the principles of web1 referral and affiliate programs, Open Affiliates allows dApps to reward community members who bring in new users, fostering a decentralized and community-driven approach to user acquisition and engagement.

It contains:
1. **A Rewards Pool**: dApps can maintain a rewards pool, which can be funded with ETH or any ERC-20 token. This pool serves as the source of rewards for successful referrals.
2. **Optional `referrer` Parameter**: The incentivized contract functions, such as deposit or mint, have an optional `referrer` parameter. This allows transactions to specify who referred them, enabling the system to reward the right entities.
3. **Self-Registration for Referrers**: Open Affiliates provides a mechanism for any Ethereum address to stake a defined amount of a token to register as a referrer. This stake acts as a commitment and can be slashed by the contract owner if the referrer is found to misuse the system.
4. **Rewards Distribution**: Registered referrers earn claimable rewards from the rewards pool when transactions specify their address in the `referrer` parameter.

You can read more about the motivation and use cases [here](https://mirror.xyz/publicartifacts.eth/e36VlVOeVoEGLt5Nr2wWp3RqE7D_Wm_PorYF_Paur7w).

---

This repo contains a simple implementation example for an ERC-4626 vault that wants to incentivize deposits using Open Affiliates. The example demonstrates how to set up a rewards pool, allow for referrer registration, and automatically distribute rewards based on incoming transactions with the `referrer` parameter.

```solidity
// Example of setting up referrer registration and rewards pool

constructor(address _vault, address _rewardsToken, address _stakingToken, uint256 _requiredStakeAmount) {
    vault = IERC4626(_vault);
    rewardsToken = _rewardsToken;
    stakingToken = _stakingToken;
    requiredStakeAmount = _requiredStakeAmount;
}

function fundReferralPool(uint256 amount) external {
    IERC20(rewardsToken).transferFrom(msg.sender, address(this), amount);
    referralRewardsPool += amount;
}

function registerAsReferrer() external {
    IERC20(stakingToken).transferFrom(msg.sender, address(this), requiredStakeAmount);
    registeredReferrers[msg.sender] = true;
}

function unregisterAsReferrer() external {
    require(registeredReferrers[msg.sender], "Referrer not registered");
    registeredReferrers[msg.sender] = false;
    IERC20(stakingToken).transfer(msg.sender, requiredStakeAmount);
}

// Example of a transaction with an optional referrer parameter

function depositWithReferrer(uint256 amount, address referrer) external {
    vault.deposit(msg.sender, amount);
    uint256 reward = calculateReward(amount);
    referralRewardsPool -= reward;
    referrerRewards[referrer] += reward;
}

function calculateReward(uint256 amount, address referrer) internal view returns (uint256) {
    if (!registeredReferrers[referrer]) {
        return 0;
    }
    // Example: 1% reward
    return amount / 100;
}

// Example of self-registration for referrers
function registerAsReferrer() external {
    registeredReferrers[msg.sender] = true;
}

// Example of rewards claiming

function claimReward() external {
    require(registeredReferrers[msg.sender], "Referrer not registered");
    uint256 amount = referrerRewards[msg.sender];
    require(amount > 0, "No rewards to claim");
    referrerRewards[msg.sender] = 0;
    IERC20(rewardsToken).transfer(msg.sender, amount);
}
```

---

One challenge with such systems is the potential for abuse, especially Sybil attacks where one entity can act as both referrer and end user. dApps that reward temporary or reversible actions (like deposits) should be aware of potential abuse. However, for permanent actions like mints and purchases, this shouldn’t be an issue. Future implementations could incorporate additional safeguards to prevent rewards farming and other forms of abuse.

If this interests you, please reach out to us. Our DMs are open on [Twitter](https://twitter.com/publicartifacts).