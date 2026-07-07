import localUnitTest from './LocalUnit.test';
import nearLinkAdvParserTest from './NearLinkAdvParser.test';

export default function testsuite() {
  localUnitTest();
  nearLinkAdvParserTest();
}
