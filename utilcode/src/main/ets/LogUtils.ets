import { FaultLogger, hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 日志工具类
 * @author Tanranran
 * @date 2024/5/15 22:21
 *  //初始化日志工具类
 ZLog.init({
 tag: "UtilCode_LOG", //打印的标签，默认为： UtilCode_LOG
 domain: 0x0000, //输出日志所对应的业务领域,默认为0x0000
 close: false, //是否关闭log，不打印
 isHilog: true, //打印类型，默认为true是hilog打印 ，false为console
 showLogLocation: true, //默认不打印，只要在error下才会打印行数
 logSize: 8000//日志每次输出大小，最大1024字节
 })
 */
export class LogUtils {
  private static mTag: string = "UtilCode_LOG"
  private static mDomain?: number = 0x0000
  private static mClose?: boolean = false
  //默认是用hilog进行打印
  private static mHilog?: boolean = true
  //展示点击的位置
  private static mShowLogLocation?: boolean = true
  //打印的最大长度，默认是800
  private static mLogSize = 800

  /*
 * 日志输出级别
 * */
  static setDomain(domain: number) {
    LogUtils.mDomain = domain
  }

  /*
   * 初始化tag、domain等属性
   * */
  static init(object: LogOptions) {
    const tag: string | undefined = object.tag //日志输出Tag
    const domain: number | undefined = object.domain //日志输出级别
    const close: boolean | undefined = object.close //是否关闭日志
    const isHilog: boolean | undefined = object.isHilog //是否是hilog打印
    const showLogLocation: boolean | undefined = object.showLogLocation //是否展示日志位置
    const logSize: number | undefined = object.logSize //日志输出大小
    if (tag != undefined) {
      LogUtils.mTag = tag
    }
    if (domain != undefined) {
      LogUtils.mDomain = domain
    }
    if (close != undefined) {
      LogUtils.mClose = close
    }
    if (isHilog != undefined) {
      LogUtils.mHilog = isHilog
    }
    if (showLogLocation != undefined) {
      LogUtils.mShowLogLocation = showLogLocation
    }
    if (logSize != undefined) {
      LogUtils.mLogSize = logSize
    }
  }

  /**
   * 需要先调用isLoggable确认某个domain、tag和日志级别是否被禁止打印日志
   * @param level
   * @returns
   */
  static isLoggable(level: hilog.LogLevel): boolean {
    return hilog.isLoggable(LogUtils.mDomain, LogUtils.mTag, level)
  }

  /**
   * debug日志
   * @param message
   * @param tag
   */
  static debug(tag: string, message: string | object, printLocation: boolean = false) {
    LogUtils.logLevel(hilog.LogLevel.DEBUG, tag, message, printLocation)
  }

  /**
   * 可写入本地日志的日志【待实现】
   * @param message
   * @param tag
   */
  static logWrite(tag: string, message: string | object, printLocation: boolean = false) {
    LogUtils.logLevel(hilog.LogLevel.INFO, tag, message, printLocation)
  }

  /**
   * 异常日志
   * @param tag
   * @param message
   */
  static error(tag: string, message: string | object, printLocation: boolean = true) {
    LogUtils.logLevel(hilog.LogLevel.ERROR, tag, message, printLocation)
  }

  /*
   *统一输出日志
   * */
  private static logLevel(level: hilog.LogLevel, tag?: string, message: string | object = "",
    printLocation: boolean = true) {
    //如果关闭状态，则不打印日志
    if (LogUtils.mClose) {
      return
    }

    //未传递时
    if (tag == undefined) {
      tag = LogUtils.mTag
    }

    //最终的内容展示
    const content = LogUtils.getMessage(level, tag, message, printLocation)

    const len = content.length / LogUtils.mLogSize
    for (let i = 0; i < len; i++) {
      let con = content.substring(i * LogUtils.mLogSize, (i + 1) * LogUtils.mLogSize)
      if (i != 0) {
        con = "|" + con
      }
      //打印日志
      if (LogUtils.mHilog) {
        //使用hilog
        switch (level) {
          case hilog.LogLevel.INFO: //info
            hilog.info(LogUtils.mDomain, tag, con)
            break
          case hilog.LogLevel.WARN: //WARN
            hilog.warn(LogUtils.mDomain, tag, con)
            break
          case hilog.LogLevel.DEBUG: //DEBUG
            hilog.debug(LogUtils.mDomain, tag, con)
            break
          case hilog.LogLevel.ERROR: //ERROR
            hilog.error(LogUtils.mDomain, tag, con)
            break
          case hilog.LogLevel.FATAL: //FATAL
            hilog.fatal(LogUtils.mDomain, tag, con)
            break
        }
      } else {
        //使用console
        switch (level) {
          case hilog.LogLevel.INFO: //info
            console.info(con)
            break
          case hilog.LogLevel.WARN: //WARN
            console.warn(con)
            break
          case hilog.LogLevel.DEBUG: //DEBUG
            console.debug(con)
            break
          case hilog.LogLevel.ERROR: //ERROR
            console.error(con)
            break
          case hilog.LogLevel.FATAL: //FATAL
            console.log(con)
            break
        }
      }

    }
  }

  /**
   * 获取输出位置
   * */
  private static getMessage(level: hilog.LogLevel, tag: string = "", message: string | object,
    printLocation: boolean = false): string {
    let log = "┌───────" + tag + "────────────────────────────────────────────────────────────────────────────────"
    log = log.substring(0, log.length - tag.length) + "\n"

    try {
      if (LogUtils.mShowLogLocation && printLocation) {
        //展示位置
        const stackTrace = new Error().stack
        const traceArray = stackTrace!.split('\n')
        const trace = traceArray.filter(item => item !== null && item.length > 6).slice(-2).join('\n')
        log = log + "|" + trace
      }

      let type = typeof message
      if (type == "object") {
        //是对象
        message = LogUtils.getObjectToJson(message)
      } else if (type == "string") {
        //判断是否包含大括号
        const content: string = message + ""
        if (content.startsWith("{") && content.endsWith("}")) {
          //对象
          const obj: object = JSON.parse(message.toString())
          message = LogUtils.getObjectToJson(obj)
        } else {
          message = content
        }
      }
      log = log + "\n|    " + message
    } catch (e) {

    }
    log = log + "\n└───────────────────────────────────────────────────────────────────────────────────────"
    return log
  }

  /**
   * 对象转Json
   * @param message
   * @returns
   */
  private static getObjectToJson(message: string | object): string {
    const json = JSON.stringify(message, null)
    const endMessage = json.replace(/\n/g, "\n|    ")
    return endMessage
  }

  /**
   * 奔溃日志查询
   * @param error
   * @param value
   */
  queryFaultLogCallback(error: BusinessError, value: Array<FaultLogger.FaultLogInfo>) {
    if (error) {
      console.info('error is ' + error);
    } else {
      console.info("value length is " + value.length);
      let len: number = value.length;
      for (let i = 0; i < len; i++) {
        console.info("log: " + i);
        console.info("Log pid: " + value[i].pid);
        console.info("Log uid: " + value[i].uid);
        console.info("Log type: " + value[i].type);
        console.info("Log timestamp: " + value[i].timestamp);
        console.info("Log reason: " + value[i].reason);
        console.info("Log module: " + value[i].module);
        console.info("Log summary: " + value[i].summary);
        console.info("Log text: " + value[i].fullLog);
      }
    }
  }
}

/**
 * 初始化Log日志传递参数
 */
export class LogOptions {
  tag?: string
  domain?: number
  close?: boolean
  isHilog?: boolean
  showLogLocation?: boolean
  logSize?: number
}