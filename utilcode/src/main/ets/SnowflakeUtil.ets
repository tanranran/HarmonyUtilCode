/**
 * @author Tanranran
 * @date 2024/5/31 13:22
 * @description
 * // 实例化Snowflake，假设我们使用workerId为1，datacenterId为2
 const snowflake = new MySnowflakeUtil(1, 2);
 // 生成下一个ID
 console.log(snowflake.nextId().toString()); // 输出类似于：1784466839682822144的字符串形式ID

 // 可以连续生成多个ID来观察序列号的变化
 for (let i = 0; i < 5; i++) {
 console.log(snowflake.nextId().toString());
 }
 */
export class SnowflakeUtil {
  private readonly epoch: bigint = BigInt('1288834974657');
  private readonly workerIdBits: number = 5;
  private readonly datacenterIdBits: number = 5;
  private readonly maxWorkerId: bigint = (BigInt(1) << BigInt(this.workerIdBits)) - BigInt(1);
  private readonly maxDatacenterId: bigint = (BigInt(1) << BigInt(this.datacenterIdBits)) - BigInt(1);
  private readonly sequenceBits: number = 12;
  private readonly workerIdShift: number = this.sequenceBits;
  private readonly datacenterIdShift: number = this.sequenceBits + this.workerIdBits;
  private readonly timestampLeftShift: number = this.sequenceBits + this.workerIdBits + this.datacenterIdBits;
  private readonly sequenceMask: bigint = (BigInt(1) << BigInt(this.sequenceBits)) - BigInt(1);
  private workerId: bigint;
  private datacenterId: bigint;
  private sequence: bigint = BigInt(0);
  private lastTimestamp: bigint = -BigInt(1);

  constructor(workerId: number, datacenterId: number) {
    if (workerId > Number(this.maxWorkerId) || workerId < 0) {
      throw new Error(`worker Id can't be greater than ${this.maxWorkerId} or less than 0`);
    }
    if (datacenterId > Number(this.maxDatacenterId) || datacenterId < 0) {
      throw new Error(`datacenter Id can't be greater than ${this.maxDatacenterId} or less than 0`);
    }
    this.workerId = BigInt(workerId);
    this.datacenterId = BigInt(datacenterId);
  }

  nextId(): bigint {
    let timestamp = this.timeGen();

    if (timestamp < this.lastTimestamp) {
      throw new Error(`Clock moved backwards. Refusing to generate id for ${this.lastTimestamp - timestamp} milliseconds`);
    }

    if (this.lastTimestamp === timestamp) {
      this.sequence = (this.sequence + BigInt(1)) & this.sequenceMask;
      if (this.sequence === BigInt(0)) {
        timestamp = this.tilNextMillis(this.lastTimestamp);
      }
    } else {
      this.sequence = BigInt(0);
    }

    this.lastTimestamp = timestamp;

    return ((BigInt(timestamp) - this.epoch) << BigInt(this.timestampLeftShift))
      | (BigInt(this.datacenterId) << BigInt(this.datacenterIdShift))
      | (BigInt(this.workerId) << BigInt(this.workerIdShift))
      | BigInt(this.sequence);
  }

  tilNextMillis(lastTimestamp: bigint): bigint {
    let timestamp = this.timeGen();
    while (timestamp <= lastTimestamp) {
      timestamp = this.timeGen();
    }
    return timestamp;
  }

  timeGen(): bigint {
    return BigInt(Date.now());
  }
}