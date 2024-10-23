/*
* Formal Verification of CalculatorFacet's calculateFee function
*/

using CalculatorFacet as calculator;

methods {
    function _.calculateFee(uint256 amount) external;
    function _.getFeePercentage() external => DISPATCHER(true);
}

definition MAX_UINT256() returns uint256 = 2^256 - 1;
definition ZERO_ADDRESS() returns address = 0;
definition TEN_THOUSAND() returns uint256 = 10000;
definition DEFAULT_FEE_PERCENTAGE() returns uint256 = 500;

persistent ghost mathint logsCount {
    init_state axiom logsCount == 0;
}

persistent ghost mathint calculateFeeCallCount {
    init_state axiom calculateFeeCallCount == 0;
}

// Hook for the calculateFee function event
hook LOG0(uint offset, uint length) uint v{
    logsCount = logsCount + 1;
}

// Rule to verify that the calculateFee function will never revert with valid parameters
rule calculateFeeNeverRevertsWithValidParams(uint256 amount) {
    env e;
    uint256 feePercentage = calculator.getFeePercentage(e);
    require amount != 0;
    
    require amount*feePercentage <= MAX_UINT256();
    require amount*feePercentage >= TEN_THOUSAND();

    calculator.calculateFee@withrevert(e, amount);
    calculateFeeCallCount = calculateFeeCallCount + 1;
    assert !lastReverted, "calculateFee should not revert with valid parameters"; 
}

// Invariant to verify that the calculateFee function emits events correctly
invariant calculateFeeEmitsEventCorrectly()
    calculateFeeCallCount == logsCount;

// Rule to verify that the calculateFee function reverts with zero amount
rule calculateFeeRevertsWithZeroAmount(uint256 amount){
    env e;
    require amount == 0;
    calculator.calculateFee@withrevert(e, amount);
    assert lastReverted;
}

// Rule to verify that the calculateFee function reverts with amount*feePercentage < 10_000
rule calculateFeeRevertsWithLessThanTenThousandAmount(uint256 amount){
    env e;
    uint256 feePercentage = calculator.getFeePercentage(e); 
    require amount == 1;
    require feePercentage == DEFAULT_FEE_PERCENTAGE();
    calculator.calculateFee@withrevert(e, amount);
    assert lastReverted;
}

// Rule to verify that the calculateFee function reverts with amount*feePercentage > max uint256
rule calculateFeeRevertsWithMoreThanMaxAmount(uint256 amount){
    env e;
    uint256 feePercentage = calculator.getFeePercentage(e); 
    require amount == MAX_UINT256();
    require feePercentage == 500;
    calculator.calculateFee@withrevert(e, amount);
    assert lastReverted;
}