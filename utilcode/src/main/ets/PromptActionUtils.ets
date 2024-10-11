import { ComponentContent, promptAction, window } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * @author Tanranran
 * @date 2024/8/5 18:46
 * @description
 */
export class PromptActionUtils {
  private static instance: PromptActionUtils
  private promptActionInfoList: PromptActionInfo[] = new Array<PromptActionInfo>()

  private constructor() {
  }


  static getInstance(): PromptActionUtils {
    if (!PromptActionUtils.instance) {
      PromptActionUtils.instance = new PromptActionUtils()
    }
    return PromptActionUtils.instance
  }

  openCustomDialog<T extends BaseCustomDialog>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions) {
    window.getLastWindow(getContext()).then((result: window.Window) => {
      const uiContext: UIContext = result.getUIContext()
      const promptAction = uiContext.getPromptAction()
      let componentContent = new ComponentContent(uiContext, contentView, args)

      let dialogOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom,
        autoCancel: options?.autoCancel || true,
        maskColor: options?.maskColor,
        onWillDismiss: (action: DismissDialogAction) => {
          if (options?.onWillDismiss) {
            options.onWillDismiss(action)
          } else {
            if (action.reason == DismissReason.TOUCH_OUTSIDE || action.reason == DismissReason.PRESS_BACK) {
              action.dismiss()
            }
          }
        },
        onDidAppear: () => {
          if (options?.onDidAppear) {
            options.onDidAppear()
          }

        },
        onDidDisappear: () => {
          PromptActionUtils.removePromptActionInfo()
          if (options?.onDidDisappear) {
            options.onDidDisappear()
          }
        },
        onWillDisappear: () => {
          if (options?.onWillDisappear) {
            options.onWillDisappear()
          }
        }
      }
      promptAction.openCustomDialog(componentContent, dialogOptions)
      PromptActionUtils.addPromptActionInfo(componentContent, args)

    }).catch((error: BusinessError) => {
      console.error('openCustomDialog', `error=${error.message}`)
    })
  }

  updateCustomDialog<T extends BaseCustomDialog>(args: T) {
    let promptActionInfo: PromptActionInfo | undefined =
      PromptActionUtils.getInstance().getPromptActionInfoByDialogId(args.dialogId)
    if (promptActionInfo) {
      promptActionInfo.dialogContent.update(args)
    }
  }


  closeCustomDialog(dialogId?: string) {
    window.getLastWindow(getContext()).then((result: window.Window) => {
      const uiContext: UIContext = result.getUIContext()
      const promptAction = uiContext.getPromptAction()
      let info: PromptActionInfo | undefined = undefined
      if (dialogId) {
        info = PromptActionUtils.getInstance().getPromptActionInfoByDialogId(dialogId)
      } else {
        info = PromptActionUtils.getInstance().getCurrentPromptActionInfo()
      }
      if (info) {
        promptAction.closeCustomDialog(info.dialogContent)
      } else {
        console.error('closeCustomDialog', 'info is null')
      }
    })
  }

  getCurrentPromptActionInfo(): PromptActionInfo {
    return PromptActionUtils.getInstance().promptActionInfoList[0]
  }

  getPromptActionInfoByDialogId(dialogId: string): PromptActionInfo | undefined {
    let infoList: PromptActionInfo[] = PromptActionUtils.getInstance().promptActionInfoList
    let promptActionInfo = infoList.find((item) =>
    dialogId == item.dialogId)
    return promptActionInfo
  }


  private static addPromptActionInfo(dialogContent: ComponentContent<object>,
    args: object) {
    let infoList = PromptActionUtils.getInstance().promptActionInfoList
    let info: PromptActionInfo = {
      dialogId: (args as BaseCustomDialog).dialogId,
      dialogContent: dialogContent,
      args: args
    }
    infoList.unshift(info)
  }

  private static removePromptActionInfo() {
    let infoList = PromptActionUtils.getInstance().promptActionInfoList
    infoList.shift()
  }
}


@Observed
export class BaseCustomDialog {
  dialogId: string = ''
  dialogOptions?: promptAction.BaseDialogOptions

  constructor() {
    this.dialogId = util.generateRandomUUID()
  }

  show<T extends BaseCustomDialog>(builder: WrappedBuilder<BaseCustomDialog[]>, args: T) {
    PromptActionUtils.getInstance().openCustomDialog<BaseCustomDialog>(builder, args,
      args?.dialogOptions ? this?.dialogOptions : {
        alignment: DialogAlignment.Center,
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          dismissDialogAction.dismiss()
        }
      })
  }

  update<T extends BaseCustomDialog>(options: T) {
    PromptActionUtils.getInstance().updateCustomDialog<BaseCustomDialog>(options)
  }

  close() {
    PromptActionUtils.getInstance().closeCustomDialog(this.dialogId)
  }
}


export interface PromptActionInfo {
  dialogId: string
  dialogContent: ComponentContent<object>
  args: object
}
