/**
 * @author Tanranran
 * @date 2024/5/15 23:32
 * @description
 */
@Component
export struct BaseFragmentComp {
  @BuilderParam content: () => void
  @Prop title: string = ''
  build() {
    NavDestination() {
      List() {
        this.content()
      }
      .divider({ strokeWidth: '1px', color: $r('sys.color.ohos_id_divider_color') })
      .height('100%')
      .width("100%")
      .listDirection(Axis.Vertical)
    }.backgroundColor('#F5F5F5')
  }
}
