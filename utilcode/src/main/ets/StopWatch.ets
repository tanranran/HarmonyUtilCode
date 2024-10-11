/**
 * 方法执行业务统计类
 * @author Tanranran
 * @date 2024/7/15 14:50
 * @description
 */
import { faceDetector } from '@kit.CoreVisionKit';

export class StopWatch {
  private startTime: number | null = null;
  private initTime: number | null = null;

  constructor() {
    this.initTime = Date.now();
    this.reset()
  }

  reset(): void {
    this.startTime = Date.now();
  }

  printElapsedTime(message: string, isReset: boolean = false) {
    const now = Date.now();
    let elapsed = now - (this.startTime ?? now)
    let allTime = now - (this.initTime ?? now)
    console.log(`${message}_耗时_${elapsed}_总耗时${allTime}`)
    if (isReset) {
      this.reset()
    }
  }
}
