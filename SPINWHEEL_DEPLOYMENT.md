# SpinWheel Contract Deployment Guide

## 🚀 Quick Deployment Commands

### Test the Contract
```bash
npm run foundry-test-spin-wheel
```

### Dry Run (Simulate Deployment)
```bash
npm run deploy-spin-wheel-dry
```

### Deploy to Polygon
```bash
npm run deploy-spin-wheel
```

## 📋 Prerequisites

1. **Environment Variables**
   ```bash
   export PRIVATE_KEY="your_deployer_private_key"
   export POLYGON_RPC_URL="your_polygon_rpc_url"
   ```

2. **Required Tokens on Deployer Account**
   - MATIC for gas fees
   - LINK tokens for VRF subscription funding (post-deployment)

## 📊 Deployment Configuration

### Polygon Network Settings
- **Verse Token**: `0x08c15fa26E519A78a666D19Ce5C646D588eF7415`
- **LINK Token**: `0xb0897686c545045aFc77CF20eC7A532E3120E0F1`
- **VRF Coordinator**: `0xAE975071Be8F8eE67addBC1A82488F1C24858067`
- **Key Hash**: `0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd` (30 gwei)
- **Spin Cost**: `1 VERSE` token per spin

## 🎯 Post-Deployment Steps

### 1. Fund VRF Subscription
```solidity
// The contract will create a new VRF subscription
// Fund it with LINK tokens using Chainlink VRF interface
// Minimum: ~10 LINK recommended for testing
```

### 2. Fund Contract for Payouts
```solidity
// Transfer VERSE tokens to contract for payouts
// Recommended: 1000+ VERSE for adequate payout reserves
// Use: contract.depositCredits() or direct transfer to contract
```

### 3. Optional: Enable Withdrawals
```solidity
// If you want users to withdraw unused credits
spinWheel.toggleWithdrawals(true);
```

### 4. Verify Contract (Automatic)
The deployment script includes `--verify` flag for automatic verification on PolygonScan.

## 📈 Expected Outcomes

### Win Probabilities
- **10x Payout**: 15% chance (1-15 range)
- **3x Payout**: 30% chance (16-45 range)  
- **1x Payout**: 30% chance (46-75 range)
- **0x Payout**: 25% chance (76-100 range)

### Gas Estimates
- **Deployment**: ~3-4M gas
- **Deposit**: ~50k gas
- **Spin**: ~150k gas
- **VRF Callback**: ~200k gas

## 🔧 Useful Commands

### Build Contract
```bash
forge build
```

### Run All Tests
```bash
npm run foundry-test-default
```

### Check Contract Size
```bash
npm run foundry-size
```

### Manual Verification (if needed)
```bash
forge verify-contract --chain-id=137 <CONTRACT_ADDRESS> SpinWheelVRF --watch
```

## 🎮 User Interface Functions

### User Functions
- `depositCredits(amount)` - Deposit VERSE for credits
- `spin()` - Spin using existing credits
- `depositAndSpin(amount)` - Deposit + spin in one transaction
- `withdrawCredits(amount)` - Withdraw unused credits (if enabled)

### Admin Functions
- `updateSpinCost(newCost)` - Update cost per spin
- `toggleWithdrawals(enabled)` - Enable/disable withdrawals
- `pauseContract()` / `unpauseContract()` - Emergency controls
- `withdrawTokens(token, amount)` - Emergency token recovery

## 🚨 Security Notes

- Withdrawals are **disabled by default**
- Contract is **pausable** for emergencies
- Only owner can modify spin costs and settings
- VRF provides **provably fair** randomness

## 📞 Support

For issues or questions:
1. Check test coverage: `npm run foundry-test-spin-wheel`
2. Review deployment logs
3. Verify contract state on PolygonScan
4. Check VRF subscription balance on Chainlink dashboard 