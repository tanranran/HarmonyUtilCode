import { pasteboard } from '@kit.BasicServicesKit'

/**
 * 剪切板工具类
 * @author Tanranran
 * @date 2024/6/6 17:05
 * @description
 */
export class ClipboardUtil {
  /**
   * 将文本内容写入剪贴板
   */
  static async setText(dataText: string): Promise<boolean> {
    let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, dataText);
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    try {
      await systemPasteboard.setData(pasteData)
      return true
    } catch (e) {
      console.error(e)
      return false
    }
  }

  /**
   * 读取剪贴板中文本
   */
  static getText(): pasteboard.PasteData | null {
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    try {
      return systemPasteboard.getDataSync()
    } catch (e) {
      console.error(e)
      return null
    }
  }

  /**
   * 剪贴板中是否有内容
   */
  static hasData(): boolean {
    try {
      return pasteboard.getSystemPasteboard().hasDataType(pasteboard.MIMETYPE_TEXT_PLAIN)
    } catch (e) {
      console.error(e)
      return false
    }
  }

  /**
   * 清空剪贴板
   */
  static clear() {
    try {
      pasteboard.getSystemPasteboard().clearDataSync()
      return true
    } catch (e) {
      console.error(e)
      return false
    }
  }
}
