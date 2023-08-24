// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import { Vm } from "forge-std/Vm.sol";
import { Test } from "forge-std/Test.sol";
import { PortalRegistry } from "../src/PortalRegistry.sol";
import { AbstractPortal } from "../src/interface/AbstractPortal.sol";
import { CorrectModule } from "../src/example/CorrectModule.sol";
import { AttestationPayload, Portal } from "../src/types/Structs.sol";
// solhint-disable-next-line max-line-length
import { IERC165Upgradeable } from "openzeppelin-contracts-upgradeable/contracts/utils/introspection/IERC165Upgradeable.sol";

contract PortalRegistryTest is Test {
  address public user = makeAddr("user");
  PortalRegistry public portalRegistry;
  string public expectedName = "Name";
  string public expectedDescription = "Description";
  ValidPortal public validPortal = new ValidPortal();
  InvalidPortal public invalidPortal = new InvalidPortal();

  event Initialized(uint8 version);
  event PortalRegistered(string name, string description, address moduleAddress);

  function setUp() public {
    portalRegistry = new PortalRegistry();
  }

  function test_alreadyInitialized() public {
    vm.expectRevert("Initializable: contract is already initialized");
    portalRegistry.initialize();
  }

  function test_updateModuleRegistry() public {
    PortalRegistry testPortalRegistry = new PortalRegistry();

    vm.prank(address(0));
    testPortalRegistry.updateModuleRegistry(address(1));
    address moduleRegistry = testPortalRegistry.moduleRegistry();
    assertEq(moduleRegistry, address(1));
  }

  function test_updateModuleRegistry_InvalidParameter() public {
    PortalRegistry testPortalRegistry = new PortalRegistry();

    vm.expectRevert(PortalRegistry.ModuleRegistryInvalid.selector);
    vm.prank(address(0));
    testPortalRegistry.updateModuleRegistry(address(0));
  }

  function test_updateAttestationRegistry() public {
    PortalRegistry testPortalRegistry = new PortalRegistry();

    vm.prank(address(0));
    testPortalRegistry.updateAttestationRegistry(address(1));
    address attestationRegistry = testPortalRegistry.attestationRegistry();
    assertEq(attestationRegistry, address(1));
  }

  function test_updateAttestationRegistry_InvalidParameter() public {
    PortalRegistry testPortalRegistry = new PortalRegistry();

    vm.expectRevert(PortalRegistry.AttestationRegistryInvalid.selector);
    vm.prank(address(0));
    testPortalRegistry.updateAttestationRegistry(address(0));
  }

  function test_register() public {
    vm.expectEmit();
    emit PortalRegistered(expectedName, expectedDescription, address(validPortal));
    portalRegistry.register(address(validPortal), expectedName, expectedDescription);

    uint256 portalCount = portalRegistry.getPortalsCount();
    assertEq(portalCount, 1);

    Portal memory portal = portalRegistry.getPortalByAddress(address(validPortal));
    assertEq(portal.name, expectedName);
    assertEq(portal.description, expectedDescription);
    assertEq(portal.modules.length, 2);
  }

  function test_register_PortalAlreadyExists() public {
    portalRegistry.register(address(validPortal), expectedName, expectedDescription);
    vm.expectRevert(PortalRegistry.PortalAlreadyExists.selector);
    portalRegistry.register(address(validPortal), expectedName, expectedDescription);
  }

  function test_register_PortalAddressInvalid() public {
    vm.expectRevert(PortalRegistry.PortalAddressInvalid.selector);
    portalRegistry.register(address(0), expectedName, expectedDescription);

    vm.expectRevert(PortalRegistry.PortalAddressInvalid.selector);
    portalRegistry.register(user, expectedName, expectedDescription);
  }

  function test_register_PortalNameMissing() public {
    vm.expectRevert(PortalRegistry.PortalNameMissing.selector);
    portalRegistry.register(address(validPortal), "", expectedDescription);
  }

  function test_register_PortalDescriptionMissing() public {
    vm.expectRevert(PortalRegistry.PortalDescriptionMissing.selector);
    portalRegistry.register(address(validPortal), expectedName, "");
  }

  function test_register_PortalInvalid() public {
    vm.expectRevert(PortalRegistry.PortalInvalid.selector);
    portalRegistry.register(address(invalidPortal), expectedName, expectedDescription);
  }

  function test_deployDefaultPortal() public {
    CorrectModule correctModule = new CorrectModule();
    address[] memory modules = new address[](1);
    modules[0] = address(correctModule);
    portalRegistry.deployDefaultPortal(modules, expectedName, expectedDescription);
  }

  function test_getPortals_PortalNotRegistered() public {
    vm.expectRevert(PortalRegistry.PortalNotRegistered.selector);
    portalRegistry.getPortalByAddress(address(validPortal));
  }

  function test_isRegistered() public {
    assertEq(portalRegistry.isRegistered(address(validPortal)), false);
    portalRegistry.register(address(validPortal), expectedName, expectedDescription);
    assertEq(portalRegistry.isRegistered(address(validPortal)), true);
  }
}

contract ValidPortal is AbstractPortal, IERC165Upgradeable {
  function test() public {}

  function attest(
    AttestationPayload memory /*attestationPayload*/,
    bytes[] memory /*validationPayload*/
  ) external payable override {}

  function getModules() external pure override returns (address[] memory) {
    address[] memory modules = new address[](2);
    modules[0] = address(0);
    modules[1] = address(1);
    return modules;
  }

  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    return interfaceID == type(AbstractPortal).interfaceId || interfaceID == type(IERC165Upgradeable).interfaceId;
  }
}

contract InvalidPortal {
  function test() public {}
}
