# Utils
.PHONY: rebuild
rebuild:
	@forge clean && forge build

### Deployment commands ###
# Anvil
.PHONY: deploy-diamond-anvil
deploy-diamond-anvil:
	@forge script script/Diamond.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-calculator-anvil
deploy-calculator-anvil:
	@forge script script/CalculatorFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-governance-anvil
deploy-governance-anvil:
	@forge script script/GovernanceFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-token-manager-anvil 
deploy-token-manager-anvil:
	@forge script script/TokenManagerFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-diamond-cut-anvil
deploy-diamond-cut-anvil:
	@forge script script/DiamondCutFacet.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)

.PHONY: deploy-wrapped-token-anvil
deploy-wrapped-token-anvil:
	@forge script script/WrappedToken.deploy.s.sol --rpc-url localhost:8545 --broadcast --private-key $(PK)
# Amoy
.PHONY: deploy-diamond-amoy
deploy-diamond-amoy:
	@forge script script/Diamond.deploy.s.sol --rpc-url https://rpc-amoy.polygon.technology	 --broadcast --private-key $(PK)

.PHONY: deploy-wrapped-token-amoy
deploy-wrapped-token-amoy:
	@forge script script/WrappedToken.deploy.s.sol --rpc-url https://rpc-amoy.polygon.technology --broadcast --private-key $(PK)

.PHONY: deploy-token-amoy
deploy-token-amoy:
	@forge script script/Token.deploy.s.sol --rpc-url https://rpc-amoy.polygon.technology --broadcast --private-key $(PK)

# Taiko
.PHONY: deploy-diamond-taiko
deploy-diamond-taiko:
	@forge script script/Diamond.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz	 --broadcast --private-key $(PK)	

.PHONY: deploy-calculator-taiko
deploy-calculator-taiko:
	@forge script script/CalculatorFacet.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

.PHONY: deploy-governance-taiko
deploy-governance-taiko:
	@forge script script/GovernanceFacet.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

.PHONY: deploy-token-manager-taiko 
deploy-token-manager-taiko:
	@forge script script/TokenManagerFacet.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

.PHONY: deploy-diamond-cut-taiko
deploy-diamond-cut-taiko:
	@forge script script/DiamondCutFacet.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

.PHONY: deploy-wrapped-token-taiko
deploy-wrapped-token-taiko:
	@forge script script/WrappedToken.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

.PHONY: deploy-token-taiko
deploy-token-taiko:
	@forge script script/Token.deploy.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)

### Interaction commands ###
# Anvil #
.PHONY: interact-calculator-anvil
interact-calculator-anvil:
	@forge script ./script/CalculatorFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)   

.PHONY: interact-governance-anvil
interact-governance-anvil:
	@forge script ./script/GovernanceFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)

.PHONY: interact-token-manager-anvil
interact-token-manager-anvil:
	@forge script ./script/TokenManagerFacet.interact.s.sol --broadcast --rpc-url localhost:8545 --private-key $(PK)	

# Taiko #
.PHONY: interact-calculator-taiko
interact-calculator-taiko:
	@forge script ./script/CalculatorFacet.interact.s.sol --broadcast --rpc-url https://rpc.hekla.taiko.xyz --private-key $(PK) 

.PHONY: interact-governance-taiko
interact-governance-taiko:
	@forge script ./script/GovernanceFacet.interact.s.sol --broadcast --rpc-url https://rpc.hekla.taiko.xyz --private-key $(PK)

.PHONY: interact-token-manager-taiko
interact-token-manager-taiko:
	@forge script ./script/TokenManagerFacet.interact.s.sol --broadcast --rpc-url https://rpc.hekla.taiko.xyz --private-key $(PK)

.PHONY: burn-diamond-taiko
burn-diamond-taiko:
	@forge script ./script/Diamond.burn.s.sol --broadcast --rpc-url https://rpc.hekla.taiko.xyz --private-key $(PK)

# Amoy #
.PHONY: interact-token-manager-amoy
interact-token-manager-amoy:
	@forge script ./script/TokenManagerFacet.burn.s.sol --broadcast --rpc-url https://rpc-amoy.polygon.technology --private-key $(PK)

.PHONY: interact-governance-amoy
interact-governance-amoy:
	@forge script ./script/GovernanceFacet.interact.s.sol --broadcast --rpc-url https://rpc-amoy.polygon.technology --private-key $(PK)

.PHONY: lock-diamond-amoy
lock-diamond-amoy:
	@forge script ./script/Diamond.lock.s.sol --broadcast --rpc-url https://rpc-amoy.polygon.technology --private-key $(PK)

# Utils
.PHONY: test
test:
	@forge test

.PHONY: build
build:
	@forge build

.PHONY: send-eth-diamond-anvil
send-eth-diamond-anvil:
	@cast send --value 1000000000000000 --rpc-url localhost:8545 --from $(FROM) $(DIAMOND)  --private-key $(PK) && anvil --unlock $(DIAMOND)

.PHONY: report
report:
	@forge coverage --report lcov && \
	 lcov --remove ./lcov.info -o ./lcov.info.pruned 'script' 'mocks' --rc derive_function_end_line=0 && \
	 genhtml -o coverage-report lcov.info.pruned --rc derive_function_end_line=0 && \
	 open coverage-report/index.html  

.PHONY: static-check
static-check:
	@slither .

.PHONY: formal-verification
formal-verification:
	@export CERTORAKEY=$(CERTORAKEY) && certoraRun ./test/formal-verification/conf/CalculatorFacet.conf

.PHONY: verify-amoy
verify-amoy:
	@forge script script/verify.interact.s.sol --rpc-url https://rpc-amoy.polygon.technology --broadcast --private-key $(PK)

.PHONY: verify-taiko
verify-taiko:
	@forge script script/verify.interact.s.sol --rpc-url https://rpc.hekla.taiko.xyz --broadcast --private-key $(PK)