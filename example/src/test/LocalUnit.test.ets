import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('assertContain', 0, () => {
      let randomLength = 32
      let curLength = 0
      let head = 'hmos'
      let content = '96ed48954338486b8c417cc9b2b30496'
      if (content.length < randomLength) {
        content += getRandomString(randomLength - content.length)
      } else if (content.length > randomLength) {
        content = removeFromStarEnds(content, 0, content.length - randomLength)
      }
      let timeStampLetter = timeStampToLetter()
      curLength += head.length
      curLength += timeStampLetter.length
      let starCount = Math.floor(curLength / 2)
      let endCount = curLength - starCount
      content = removeFromStarEnds(content, starCount, endCount)
      let randomStr = head + content + timeStampLetter
      console.log(randomStr)
      console.log(randomStr.length + "")
    });
  });
}

function getRandomString(length: number): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  const charactersLength = characters.length;
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

/**
 * 从头部及尾部删除指定长度字符
 * @param str 要删除的字符串
 * @param headLength 头部删除长度
 * @param tailLength 尾部删除长度
 * @returns
 */
function removeFromStarEnds(str: string, headLength: number, tailLength: number): string {
  return str.substring(headLength, str.length - tailLength);
}

function timeStampToLetter() {
  let timeStamp: string = `${Date.now()}`
  let timeStampLetter = ''
  for (const char of timeStamp) {
    timeStampLetter += numberToLetter(parseInt(char), false)
  }
  return timeStampLetter
}

function numberToLetter(num: number, isUpperCase: boolean = true): string {
  const base = isUpperCase ? 65 : 97; // ASCII code for 'A' or 'a'
  return String.fromCharCode(base + num);
}