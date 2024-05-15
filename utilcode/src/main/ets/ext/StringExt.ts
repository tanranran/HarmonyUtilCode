/**
 * @author Tanranran
 * @date 2024/5/15 12:29
 * @description
 */

declare global {
  interface String {
    replaceAll(s1, s2): string;
  }
}

String.prototype.replaceAll = function(s1, s2) {
  return this.replace(new RegExp(s1, "gm"), s2);
}

export {};