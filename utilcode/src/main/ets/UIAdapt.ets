import { window } from '@kit.ArkUI'
import { BusinessError } from '@ohos.base'

/**
 * @Author: ZhongRui ༄༅哟嚯྅ᯤ⁶ᴳ
 * @Date: 2024/5/16 22:41
 * @Description: ui适配工具类
 **/
export class UIAdapt {
  private static instance: UIAdapt
  private static readonly UI_DESIGN_WIDTH = 375
  private static readonly UI_DESIGN_HEIGHT = 1373.5
  private windowWidth: number = 0
  private windowHeight: number = 0
  private static readonly aspectRatioList = [0.73, 1.5]
  private static readonly scaleList = [2, 3]

  static get(): UIAdapt {
    if (!UIAdapt.instance) {
      UIAdapt.instance = new UIAdapt()
    }
    return UIAdapt.instance
  }


  private checkWidth() {
    if (this.windowWidth <= 0) {
      this.windowWidth = LocalStorage.getShared().get<number>("windowWidth") ?? 0
    }
  }

  private checkHeight() {
    if (this.windowHeight <= 0) {
      this.windowHeight = LocalStorage.getShared().get<number>("windowHeight") ?? 0
    }
  }


  toPx(uiSize: number, adaptFoldingScreen: boolean = true, uiDesignWidth: number = UIAdapt.UI_DESIGN_WIDTH,
    aspectRatio?: number, scale?: number): string {
    return this.toPxNumber(uiSize, adaptFoldingScreen, uiDesignWidth, aspectRatio, scale) + "px"
  }

  toPxNumber(uiSize: number, adaptFoldingScreen: boolean = true, uiDesignWidth: number = UIAdapt.UI_DESIGN_WIDTH,
    aspectRatio?: number, scale?: number): number {
    this.checkWidth()
    if (this.windowWidth <= 0) {
      return vp2px(uiSize)
    }
    let size = this.windowWidth * uiSize / uiDesignWidth
    if (adaptFoldingScreen) {
      this.checkHeight()
      if (this.windowHeight <= 0) {
        return vp2px(uiSize)
      }
      let widthHeightRatio = this.windowWidth / this.windowHeight

      if (aspectRatio != null && aspectRatio != undefined && aspectRatio > 0 && scale != null && scale != undefined &&
        scale > 0) {
        if (widthHeightRatio >= aspectRatio) {
          return (size / scale)
        }
        return size
      }
      for (let index = 0; index < UIAdapt.aspectRatioList.length; index++) {
        const element = UIAdapt.aspectRatioList[index];
        if (widthHeightRatio < element) {
          if (index == 0) {
            return size
          } else {
            return (size / UIAdapt.scaleList[index-1])
          }
        }
      }
    }
    return size
  }

  toPxForHeight(uiSize: number, uiDesignHeight: number = UIAdapt.UI_DESIGN_HEIGHT): string {
    this.checkHeight()
    if (this.windowHeight <= 0) {
      return uiSize + "vp"
    }
    let size = this.windowHeight * uiSize / uiDesignHeight
    return size + "px"
  }

  init() {
    window.getLastWindow(getContext(this), (err: BusinessError, data) => {
      if (err) {
        return
      }
      let properties = data.getWindowProperties()
      this.windowWidth = properties.windowRect.width
      this.windowHeight = properties.windowRect.height
    })
  }

  setWindowSize(width: number, height: number) {
    this.windowWidth = width;
    this.windowHeight = height;
  }

  getWindowWidth(): number {
    this.checkWidth()
    if (this.windowWidth <= 0) {
      return 0
    }
    return this.windowWidth
  }

  getWindowHeight(): number {
    this.checkHeight()
    if (this.windowHeight <= 0) {
      return 0
    }
    return this.windowHeight
  }
}

let UI = UIAdapt.get()

export { UI }