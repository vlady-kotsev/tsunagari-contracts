# Utils
.PHONY: rebuild
rebuild:
	forge clean && forge build

# Deployment commands
.PHONY: deploy-diamond-anvil
deploy-diamond-anvil:
	forge script script/Diamond.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-calculator-anvil
deploy-calculator-anvil:
	forge script script/CalculatorFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-governance-anvil
deploy-governance-anvil:
	forge script script/GovernanceFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-token-manager-anvil 
deploy-token-manager-anvil:
	forge script script/TokenManagerFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

# Interaction commands
.PHONY: interact-calculator-anvil
interact-calculator-anvil:
	forge script ./script/CalculatorFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)   

.PHONY: interact-diamond-cut-anvil 
interact-diamond-cut-anvil:
	forge script ./script/DiamondCut.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)   	

.PHONY: interact-governance-anvil
interact-governance-anvil:
	forge script ./script/GovernanceFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)

.PHONY: interact-token-manager-anvil
interact-token-manager-anvil:
	forge script ./script/TokenManagerFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)	

.PHONY: mint-wrapped-token-anvil
mint-wrapped-token-anvil:
	forge script ./script/WrappedToken.mint.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)	