/**
 * @author Tanranran
 * @date 2024/5/13 22:52
 * @description
 */
export default class CommonItemTitle {
  pageName?: string
  title: string
  content?: string

  constructor(title: string, content: string, pageName?: string) {
    this.title = title
    this.content = content
    this.pageName = pageName
  }
}
