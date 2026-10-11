import localUnitTest from './LocalUnit.test';
import homeSessionTargetTest from './HomeSessionTarget.test';

export default function testsuite() {
  localUnitTest();
  homeSessionTargetTest();
}