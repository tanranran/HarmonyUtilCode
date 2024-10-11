/**
 * @author Tanranran
 * @date 2024/5/13 22:52
 * @description
 */
@Observed
export default class CommonItemTitle {
  pageName?: string
  title: string
  content?: string
  callback?: () => void
  visible: boolean = true; // 是否可见

  constructor(title: string, content: string, pageName?: string, callback?: () => void) {
    this.title = title
    this.content = content
    this.pageName = pageName
    this.callback = callback
  }
}
