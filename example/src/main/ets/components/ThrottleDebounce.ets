import { debounce, Debounce, throttle, Throttle } from '@android_x/utilcode';


/**
 * 限流和防抖函数使用例子
 * @author Tanranran
 * @date 2024/3/20 15:55
 * @description
 * 限流 (Throttling) 点击防抖用这个
 * 适用场景：
   滚动事件处理：在滚动时按固定时间间隔处理事件，比如无限滚动加载内容。
   监控浏览器的滚动位置：定期检查滚动位置来决定是否显示或隐藏页面上的元素。
   游戏控制：限制用户操作的频率，如每秒只能发射一次子弹。

 * 防抖 (Debouncing)
 * 适用场景：
   搜索框实时搜索：用户在搜索框输入时，只有在用户停止输入一定时间后才发起搜索请求，避免对每个键盘输入都进行处理。
   窗口大小调整（resize）：只在用户完成窗口大小调整一段时间后，才进行相关的布局计算和更新，避免频繁调整造成的性能问题。
   表单验证：在用户停止输入后延迟执行验证逻辑，减少验证频率。
 */
@Entry
@Component
struct ThrottleDebounce {
  @State message: string = 'Hello World';

  @Debounce(3000)
  debounceClick1(msg: string) {
    console.log("debounceClick1 " + msg)
  }

  debounceClick2(msg: string) {
    console.log("handleClick2 " + msg)
  }

  private debounceClick22 = debounce(2000, this.debounceClick2)

  @Throttle(3000)
  throttleClick1(msg: string) {
    console.log("throttleClick1 " + msg)
  }

  throttleClick2(msg: string) {
    console.log("throttleClick2 " + msg)
  }

  private throttleClick22 = throttle(2000, this.throttleClick2)

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .onClick(() => {
        this.debounceClick1('Debounce Decorator')
        this.debounceClick22('debounce Function')

        this.throttleClick1('Throttle Decorator')
        this.throttleClick22('throttle Function')
      })
    }
    .height('100%')
  }
}
