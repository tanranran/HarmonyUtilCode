// 防抖使用参考：https://github.com/niksy/throttle-debounce
type DebounceOptions = {
  atBegin?: boolean;
}

/* eslint-disable no-undefined */

import {throttle, AnyRetFunc,ThrottleFuncInterface} from './throttle';

/**
 * Debounce execution of a function. Debouncing, unlike throttling,
 * guarantees that a function is only executed a single time, either at the
 * very beginning of a series of calls, or at the very end.
 *
 * @param {number} delay -               A zero-or-greater delay in milliseconds. For event callbacks, values around 100 or 250 (or even higher) are most useful.
 * @param {Function} callback -          A function to be executed after delay milliseconds. The `this` context and all arguments are passed through, as-is,
 *                                        to `callback` when the debounced-function is executed.
 * @param {object} [options] -           An object to configure options.
 * @param {boolean} [options.atBegin] -  Optional, defaults to false. If atBegin is false or unspecified, callback will only be executed `delay` milliseconds
 *                                        after the last debounced-function call. If atBegin is true, callback will be executed only at the first debounced-function call.
 *                                        (After the throttled-function has not been called for `delay` milliseconds, the internal counter is reset).
 *
 * @returns {Function} A new, debounced function.
 */
export function debounce<T extends  AnyRetFunc>(delay:number, callback:T, options?:DebounceOptions):ThrottleFuncInterface<T> {
  const { atBegin = false } = options || {};
  return throttle(delay, callback, { debounceMode: atBegin !== false });
}

/**
 * 防抖 (Debouncing)
 * 适用场景：
   搜索框实时搜索：用户在搜索框输入时，只有在用户停止输入一定时间后才发起搜索请求，避免对每个键盘输入都进行处理。
   窗口大小调整（resize）：只在用户完成窗口大小调整一段时间后，才进行相关的布局计算和更新，避免频繁调整造成的性能问题。
   表单验证：在用户停止输入后延迟执行验证逻辑，减少验证频率。
 * @param wait
 * @param options
 * @returns
 */
export function Debounce(wait: number, options?: DebounceOptions): MethodDecorator {
  return function (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    const debouncedMethod = debounce(wait, originalMethod, options);
    descriptor.value = debouncedMethod;
    return descriptor;
  };
}