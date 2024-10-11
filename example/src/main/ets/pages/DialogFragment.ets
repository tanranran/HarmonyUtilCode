import { BaseCustomDialog, PromptActionUtils } from '@android_x/utilcode'
/**
 * @author Tanranran
 * @date 2024/8/5 18:49
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import { BaseFragmentComp } from '../components/BaseFragmentComp'

@Component
@Preview
export struct DialogFragment {
  @State listData: Array<CommonItemTitle> = []
  customerDialog?: CustomerDialog

  aboutToAppear() {
    this.listData.push(new CommonItemTitle('弹起自定义弹框', '', '', () => {
      this.customerDialog = new CustomerDialog()
      this.customerDialog?.show()
    }))

    this.listData.push(new CommonItemTitle('弹起自定义弹框', '', '', () => {
      this.customerDialog?.close()
    }))
  }

  build() {
    BaseFragmentComp({ listData: this.listData })
  }
}

export class CustomerDialog extends BaseCustomDialog {
  progress: number = 0

  show() {
    super.show(wrapBuilder(CustomerDialogBuilder), this)
    let intervalId = setInterval(() => {
      this.progress += 5;
      if (this.progress >= 100) {
        this.progress = 100;
        clearInterval(intervalId)
      }
      this.updateProgress(this.progress)
    }, 1000);
  }

  updateProgress(progress: number) {
    this.progress = progress
    this.update(this)
  }
}

@Component
export struct CustomerDialogComponent {
  @Prop options: CustomerDialog

  build() {
    Column({ space: '10vp' }) {
      Stack() {
        Progress({ value: this.options.progress, total: 100, type: ProgressType.Ring })
          .width('100%')
          .height('100%')
          .color(Color.White)
          .backgroundColor('#33ffffff')
          .style({
            strokeWidth: 3,
            enableSmoothEffect: true,
          })

        Text(`${this.options.progress}%`)
          .width('100%')
          .height('100%')
          .fontSize(13)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .width(50)
      .height(50)
      .margin({
        top: 20
      })

      Text('正在处理中')
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({
          top: 15
        })
        .fontSize(12)

      Text('请不要退出哦')
        .fontColor('#80FFFFFF')
        .textAlign(TextAlign.Center)
        .margin({
          top: 10,
          bottom: 20
        })
        .fontSize(12)
    }
    .width(150)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#CC000000')
    .borderRadius(10)
  }
}

@Builder
function CustomerDialogBuilder(options: object) {
  CustomerDialogComponent({ options: options as CustomerDialog })
}

@Builder
export function PageBuilder() {
  DialogFragment()
}