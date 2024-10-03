// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {GovernanceFacet} from "../src/facets/GovernanceFacet.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {TokenManagerFacet} from "../src/facets/TokenManagerFacet.sol";
import {WrappedToken} from "../src/WrappedToken.sol";

contract DeployDiamond is Script {
    function run() external returns (Diamond) {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](4);

        vm.startBroadcast();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        CalculatorFacet calculatorFacet = new CalculatorFacet();
        GovernanceFacet governanceFacet = new GovernanceFacet();
        TokenManagerFacet tokenManagerFacet = new TokenManagerFacet();
        vm.stopBroadcast();

        console.log("DiamondCutFacet deployed at ", address(diamondCutFacet));
        console.log("CalculatorFacet deployed at ", address(calculatorFacet));
        console.log("GovernanceFacet deployed at ", address(governanceFacet));
        console.log("TokenManagerFacet deployed at ", address(tokenManagerFacet));

        // ## Add facets ##

        // Add Diamond Cut facet
        bytes4[] memory diamondCutFacetSelectors = new bytes4[](1);
        diamondCutFacetSelectors[0] = DiamondCutFacet.diamondCut.selector;

        cuts[0] =
            IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, diamondCutFacetSelectors);

        // Add Calculator facet
        bytes4[] memory calculatorFacetSelectors = new bytes4[](4);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        calculatorFacetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        calculatorFacetSelectors[2] = CalculatorFacet.calculateFee.selector;
        calculatorFacetSelectors[3] = CalculatorFacet.initCalculator.selector;
        cuts[1] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        // Add Governance facet
        bytes4[] memory governanceFacetSelectors = new bytes4[](4);
        governanceFacetSelectors[0] = GovernanceFacet.getThreshold.selector;
        governanceFacetSelectors[1] = GovernanceFacet.setThreshold.selector;
        governanceFacetSelectors[2] = GovernanceFacet.addMember.selector;
        governanceFacetSelectors[3] = GovernanceFacet.initGovernance.selector;
        cuts[2] =
            IDiamondCut.FacetCut(address(governanceFacet), IDiamondCut.FacetCutAction.Add, governanceFacetSelectors);

        // Add TokenManager facet
        bytes4[] memory tokenManagerFacetSelectors = new bytes4[](7);
        tokenManagerFacetSelectors[0] = TokenManagerFacet.lockTokens.selector;
        tokenManagerFacetSelectors[1] = TokenManagerFacet.unlockTokens.selector;
        tokenManagerFacetSelectors[2] = TokenManagerFacet.mintWrappedTokens.selector;
        tokenManagerFacetSelectors[3] = TokenManagerFacet.burnWrappedToken.selector;
        tokenManagerFacetSelectors[4] = TokenManagerFacet.getMinimumBridgeableAmount.selector;
        tokenManagerFacetSelectors[5] = TokenManagerFacet.setMinimumBridgeableAmount.selector;
        tokenManagerFacetSelectors[6] = TokenManagerFacet.initTokenManager.selector;
        cuts[3] =
            IDiamondCut.FacetCut(address(tokenManagerFacet), IDiamondCut.FacetCutAction.Add, tokenManagerFacetSelectors);

        vm.startBroadcast();
        Diamond diamond = new Diamond(cuts);

        // ## Init facets ##

        // Calculator facet
        IDiamond(address(diamond)).initCalculator();

        // Governance facet
        address[] memory addresses = readAddressesFromFile("./script/addresses.json", ".addresses");
        uint256 threshold = 1;

        IDiamond(address(diamond)).initGovernance(addresses, threshold);

        // TokenManager facet
        uint256 minBridgeableAmount = 1e18;
        address treasuryAddress = makeAddr("treasury");
        IDiamond(address(diamond)).initTokenManager(minBridgeableAmount, treasuryAddress);

        // ## Deploy Wrapped token ##
        WrappedToken wrappedToken = new WrappedToken(address(diamond), "MyToken", "MTK");
        vm.stopBroadcast();

        console.log("Wrapped token deployed at: ", address(wrappedToken));

        console.log("Facets initialized");
        console.log("Diamond deployed at ", address(diamond));
        return diamond;
    }

    function readAddressesFromFile(string memory filePath, string memory key)
        internal
        view
        returns (address[] memory)
    {
        string memory fileData = vm.readFile(filePath);
        return vm.parseJsonAddressArray(fileData, key);
    }
}
