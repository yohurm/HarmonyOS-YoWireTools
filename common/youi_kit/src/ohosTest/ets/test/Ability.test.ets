import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

export default function abilityTest() {
  describe('ActsAbilityTest', () => {
    // 定义测试套件。支持两个参数：套件名称与套件函数。
    beforeAll(() => {
      // 预设动作，在整个套件所有用例开始前仅执行一次。
      // 本 API 仅支持一个参数：预设动作函数。
    })
    beforeEach(() => {
      // 预设动作，在每个单元用例开始前执行。
      // 执行次数与 **it** 定义的用例数相同。
      // 本 API 仅支持一个参数：预设动作函数。
    })
    afterEach(() => {
      // 预设清理动作，在每个单元用例结束后执行。
      // 执行次数与 **it** 定义的用例数相同。
      // 本 API 仅支持一个参数：清理动作函数。
    })
    afterAll(() => {
      // 预设清理动作，在整个套件所有用例结束后执行。
      // 本 API 仅支持一个参数：清理动作函数。
    })
    it('assertContain', 0, () => {
      // 定义测试用例。本 API 支持三个参数：用例名、过滤参数、用例函数。
      hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
      let a = 'abc';
      let b = 'b';
      // 多种断言方法，用于声明期望的布尔条件。
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    })
  })
}