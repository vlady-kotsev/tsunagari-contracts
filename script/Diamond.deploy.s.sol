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
import {DiamondLoupeFacet} from "../src/facets/DiamondLoupeFacet.sol";

contract DeployDiamond is Script {
    struct facetAddressesStruct {
        address diamondCutFacetAddress;
        address governanceFacetAddress;
        address tokenManagerFacetAddress;
        address diamondLoupeFacetAddress;
        address calculatorFacetAddress;
    }

    function run() external returns (Diamond) {
        return run(true);
    }

    // deployCalculator added for testing purposes
    function run(bool deployCalculatorFacet) public returns (Diamond) {
        uint256 cutsCount = deployCalculatorFacet ? 5 : 4;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](cutsCount);
        facetAddressesStruct memory fa = deployFacets(deployCalculatorFacet);

        // ## Add facets ##

        // Add Diamond Cut facet
        bytes4[] memory diamondCutFacetSelectors = getDiamondCutFacetSelectors();
        cuts[0] =
            IDiamondCut.FacetCut(fa.diamondCutFacetAddress, IDiamondCut.FacetCutAction.Add, diamondCutFacetSelectors);

        // Add Governance facet
        bytes4[] memory governanceFacetSelectors = getGovernanceFacetSelectors();
        cuts[1] =
            IDiamondCut.FacetCut(fa.governanceFacetAddress, IDiamondCut.FacetCutAction.Add, governanceFacetSelectors);

        // Add TokenManager facet
        bytes4[] memory tokenManagerFacetSelectors = getTokenManagerFacetSelectors();
        cuts[2] = IDiamondCut.FacetCut(
            fa.tokenManagerFacetAddress, IDiamondCut.FacetCutAction.Add, tokenManagerFacetSelectors
        );

        // Add Diamond Loupe facet
        bytes4[] memory diamondLoupeFacetSelectors = getDiamondLoupeFacetSelectors();
        cuts[3] = IDiamondCut.FacetCut(
            fa.diamondLoupeFacetAddress, IDiamondCut.FacetCutAction.Add, diamondLoupeFacetSelectors
        );

        if (deployCalculatorFacet) {
            // Add Calculator facet
            bytes4[] memory calculatorFacetSelectors = getCalculatorFacetSelectors();
            cuts[4] = IDiamondCut.FacetCut(
                fa.calculatorFacetAddress, IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors
            );
        }
        vm.startBroadcast();
        Diamond diamond = new Diamond(cuts);

        // ## Init facets ##

        // Calculator facet
        if (deployCalculatorFacet) {
            IDiamond(address(diamond)).initCalculator();
        }
        // Governance facet
        address[] memory addresses = readAddressesFromFile("./script/addresses.json", ".addresses");
        uint248 threshold = 1;
        IDiamond(address(diamond)).initGovernance(addresses, threshold);

        // TokenManager facet
        uint248 minBridgeableAmount = 1e18;
        address treasuryAddress = makeAddr("treasury");
        IDiamond(address(diamond)).initTokenManager(minBridgeableAmount, treasuryAddress);
        vm.stopBroadcast();

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

    function getDiamondCutFacetSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory facetSelectors = new bytes4[](1);
        facetSelectors[0] = DiamondCutFacet.diamondCut.selector;
        return facetSelectors;
    }

    function getGovernanceFacetSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory facetSelectors = new bytes4[](4);
        facetSelectors[0] = GovernanceFacet.getThreshold.selector;
        facetSelectors[1] = GovernanceFacet.setThreshold.selector;
        facetSelectors[2] = GovernanceFacet.addMember.selector;
        facetSelectors[3] = GovernanceFacet.initGovernance.selector;
        return facetSelectors;
    }

    function getTokenManagerFacetSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory facetSelectors = new bytes4[](12);
        facetSelectors[0] = TokenManagerFacet.lockTokens.selector;
        facetSelectors[1] = TokenManagerFacet.unlockTokens.selector;
        facetSelectors[2] = TokenManagerFacet.mintWrappedTokens.selector;
        facetSelectors[3] = TokenManagerFacet.burnWrappedToken.selector;
        facetSelectors[4] = TokenManagerFacet.getMinimumBridgeableAmount.selector;
        facetSelectors[5] = TokenManagerFacet.setMinimumBridgeableAmount.selector;
        facetSelectors[6] = TokenManagerFacet.initTokenManager.selector;
        facetSelectors[7] = TokenManagerFacet.addNewSupportedToken.selector;
        facetSelectors[8] = TokenManagerFacet.withdrawTokenFunds.selector;
        facetSelectors[9] = TokenManagerFacet.isTokenSupported.selector;
        facetSelectors[10] = TokenManagerFacet.getTreasuryAddress.selector;
        facetSelectors[11] = TokenManagerFacet.setTreasuryAddress.selector;
        return facetSelectors;
    }

    function getDiamondLoupeFacetSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory facetSelectors = new bytes4[](4);
        facetSelectors[0] = DiamondLoupeFacet.facets.selector;
        facetSelectors[1] = DiamondLoupeFacet.facetAddresses.selector;
        facetSelectors[2] = DiamondLoupeFacet.facetAddress.selector;
        facetSelectors[3] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        return facetSelectors;
    }

    function getCalculatorFacetSelectors() internal pure returns (bytes4[] memory) {
        bytes4[] memory facetSelectors = new bytes4[](4);
        facetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        facetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        facetSelectors[2] = CalculatorFacet.calculateFee.selector;
        facetSelectors[3] = CalculatorFacet.initCalculator.selector;
        return facetSelectors;
    }

    function deployFacets(bool deployCalculatorFacet) internal returns (facetAddressesStruct memory) {
        vm.startBroadcast();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        address diamondCutFacetAddress = address(diamondCutFacet);

        address calculatorFacetAddress;
        if (deployCalculatorFacet) {
            CalculatorFacet calculatorFacet = new CalculatorFacet();
            calculatorFacetAddress = address(calculatorFacet);
        }

        GovernanceFacet governanceFacet = new GovernanceFacet();
        address governanceFacetAddress = address(governanceFacet);

        TokenManagerFacet tokenManagerFacet = new TokenManagerFacet();
        address tokenManagerFacetAddress = address(tokenManagerFacet);

        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        address diamondLoupeFacetAddress = address(diamondLoupeFacet);

        vm.stopBroadcast();
        facetAddressesStruct memory fa = facetAddressesStruct(
            diamondCutFacetAddress,
            governanceFacetAddress,
            tokenManagerFacetAddress,
            diamondLoupeFacetAddress,
            calculatorFacetAddress
        );

        console.log("DiamondCutFacet deployed at ", diamondCutFacetAddress);
        console.log("GovernanceFacet deployed at ", governanceFacetAddress);
        console.log("TokenManagerFacet deployed at ", tokenManagerFacetAddress);
        console.log("DiamondLoupeFacet deployed at ", diamondLoupeFacetAddress);
        if (deployCalculatorFacet) {
            console.log("CalculatorFacet deployed at ", calculatorFacetAddress);
        }
        return fa;
    }
}
