export function LifecycleEvent(target: any, propertyKey: string | any) {
  let value: any;
  const getter = () => value;
  const setter = function (newValue: any) {
    value = newValue;
  };
  Object.defineProperty(target, propertyKey, {
    get: getter,
    set: setter,
    enumerable: true,
    configurable: true,
  });

  if (target.rerender) {
    if (target.aboutToAppear) {
      let oldFunction = target.aboutToAppear
      function appear() {
        oldFunction.call(this)
        target[propertyKey].aboutToAppear()
      }
      target.aboutToAppear = appear
    } else {
      target.aboutToAppear = () => {
        target[propertyKey].aboutToAppear()
      }
    }

    if (target.onPageShow) {
      let oldFunction = target.onPageShow
      function pageShow() {
        target[propertyKey].onPageShow()
        oldFunction.call(this)
      }

      target.onPageShow = pageShow
    } else {
      target.onPageShow = () => {
        target[propertyKey].onPageShow()
      }
    }

    if (target.onPageHide) {
      let oldFunction = target.onPageHide

      function pageHide() {
        target[propertyKey].onPageHide()
        oldFunction.call(this)
      }

      target.onPageHide = pageHide
    } else {
      target.onPageHide = () => {
        target[propertyKey].onPageHide()
      }
    }

    if (target.aboutToDisappear) {
      let oldFunction = target.aboutToDisappear
      function disappear() {
        target[propertyKey].aboutToDisappear()
        target[propertyKey].release()
        oldFunction.call(disappear.prototype.caller)
      }
      target.aboutToDisappear = disappear
    } else {
      target.aboutToDisappear = () => {
        target[propertyKey].aboutToDisappear()
        target[propertyKey].release()
      }
    }
  }
}
