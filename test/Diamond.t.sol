// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DeployDiamondCutFacet} from "../script/DiamondCutFacet.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";
import {GovernanceFacet} from "../src/facets/GovernanceFacet.sol";
import {DeployGovernanceFacet} from "../script/GovernanceFacet.deploy.s.sol";

contract DiamondTest is Test, Script, SignatureGenerator {
    Diamond diamond;
    DiamondCutFacet diamondCutFacet;

    function setUp() public {
        DeployDiamondCutFacet ddcf = new DeployDiamondCutFacet();
        diamondCutFacet = ddcf.run();
    }

    function testDiamondConstructor() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](2);
        bytes4[] memory diamondCutFacetSelectors = new bytes4[](1);
        diamondCutFacetSelectors[0] = DiamondCutFacet.diamondCut.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, diamondCutFacetSelectors);

        DeployGovernanceFacet dgf = new DeployGovernanceFacet();
        GovernanceFacet governanceFacet = dgf.run();

        bytes4[] memory governanceFacetSelectors = new bytes4[](4);
        governanceFacetSelectors[0] = GovernanceFacet.getThreshold.selector;
        governanceFacetSelectors[1] = GovernanceFacet.setThreshold.selector;
        governanceFacetSelectors[2] = GovernanceFacet.addMember.selector;
        governanceFacetSelectors[3] = GovernanceFacet.initGovernance.selector;
        cuts[1] =
            IDiamondCut.FacetCut(address(governanceFacet), IDiamondCut.FacetCutAction.Add, governanceFacetSelectors);

        diamond = new Diamond(cuts);
        IDiamond iDiamond = IDiamond(address(diamond));

        address[] memory addresses = readAddressesFromFile("./script/addresses.json", ".addresses");
        uint248 threshold = 1;
        iDiamond.initGovernance(addresses, threshold);
        initSignatureGenerator(threshold);

        messageWithNonce = getUniqueSignature(1);
        cuts[0] =
            IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Remove, diamondCutFacetSelectors);
        delete cuts[1];
        iDiamond.diamondCut(cuts, address(0), new bytes(0), messageWithNonce, signatures);
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
