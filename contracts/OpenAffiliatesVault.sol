pragma solidity ^0.8.21;

// Interface for ERC-4626
interface IERC4626 {
    function deposit(address to, uint256 amount) external;
    function withdraw(address from, uint256 amount) external;
}

// Interface for ERC-20
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract OpenAffiliatesVault {
    IERC4626 public vault;
    address public rewardsToken;
    address public stakingToken;
    uint256 public requiredStakeAmount;
    mapping(address => bool) public registeredReferrers;
    mapping(address => uint256) public referrerRewards;
    uint256 public referralRewardsPool;

    constructor(address _vault, address _rewardsToken, address _stakingToken, uint256 _requiredStakeAmount) {
        vault = IERC4626(_vault);
        rewardsToken = _rewardsToken;
        stakingToken = _stakingToken;
        requiredStakeAmount = _requiredStakeAmount;
    }

    function registerAsReferrer() external {
        IERC20(stakingToken).transferFrom(msg.sender, address(this), requiredStakeAmount);
        registeredReferrers[msg.sender] = true;
    }

    function deposit(uint256 amount) external {
        vault.deposit(msg.sender, amount);
    }

    function depositWithReferrer(uint256 amount, address referrer) external {
        require(registeredReferrers[referrer], "Referrer not registered");
        vault.deposit(msg.sender, amount);
        uint256 reward = calculateReward(amount);
        referralRewardsPool -= reward;
        referrerRewards[referrer] += reward;
    }

    function claimReward() external {
        uint256 amount = referrerRewards[msg.sender];
        require(amount > 0, "No rewards to claim");
        referrerRewards[msg.sender] = 0;
        IERC20(rewardsToken).transfer(msg.sender, amount);
    }

    function calculateReward(uint256 amount) internal pure returns (uint256) {
        // Example: 1% reward
        return amount / 100;
    }

    // Function to fund the referral rewards pool
    function fundReferralPool(uint256 amount) external {
        IERC20(rewardsToken).transferFrom(msg.sender, address(this), amount);
        referralRewardsPool += amount;
    }
}