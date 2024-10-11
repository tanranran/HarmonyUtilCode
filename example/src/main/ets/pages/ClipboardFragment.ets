import { ClipboardUtil } from '@android_x/utilcode';
import CommonItemTitle from '../bean/CommonItemTitle';
import { BaseFragmentComp } from '../components/BaseFragmentComp';
import CommonConst from '../const/CommonConst';

/**
 * @author Tanranran
 * @date 2024/6/6 17:17
 * @description
 */
@Component
@Preview
export struct ClipboardFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []
  @State title: string = ""

  async aboutToAppear(): Promise<void> {
    this.listData.push(new CommonItemTitle('剪切板中是否有数据', '', '', () => {
      console.log(ClipboardUtil.hasData() + "")
    }))
    this.listData.push(new CommonItemTitle('获取剪切板数据', '', '', () => {
      console.log(ClipboardUtil.getText()?.getPrimaryText())
    }))
    this.listData.push(new CommonItemTitle('剪切板写入数据', '', '', () => {
      ClipboardUtil.setText(Date.now() + "")
    }))
  }

  build() {
    BaseFragmentComp({ title: this.title, listData: this.listData })
  }
}

@Builder
export function PageBuilder() {
  ClipboardFragment()
}