import localUnitTest from './LocalUnit.test';
import uiTokenContractTest from './UiTokenContract.test';
import uiAccessibilityContractTest from './UiAccessibilityContract.test';
export default function testsuite() {
  localUnitTest();
  uiTokenContractTest();
  uiAccessibilityContractTest();
}