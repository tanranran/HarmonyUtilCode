## 📚简介

`HarmonyUtilCode`是一个功能丰富且易用的**OpenHarmony/HarmonyOS工具库**，通过诸多实用工具类的使用，旨在帮助开发者快速、便捷地完成各类开发任务。
这些封装的工具涵盖了字符串、数字、集合、JSON等一系列操作，
可以满足各种不同的开发需求。本人为Android开发,故封装思路借鉴Android的工具类Blankj/AndroidUtilCode ，同时扩展了HarmonyOS的UI组件。

## 🛠️包含组件

一个OpenHarmony/HarmonyOS基础工具类，组成各种Util工具类

### 基础类组件

* #### 设备相关 DeviceUtils

```
getDeviceId              : 获取设备唯一识别码【卸载APP后依旧有效】
```

## 📦安装

### 🍊ohpm

执行安装命令

```
ohpm install @ranran/utilCode
```

## 📦使用

### 1.在项目中引入插件

```
import { DeviceUtils } from '@ranran/utilCode'
```

类按需引入,项目需要使用那个就引入

#### 1.1 DeviceUtils的方法

``` typescript
import { DeviceUtils } from '@ranran/utilCode'
```

* getDeviceId 获取设备id>32为随机码[卸载APP后依旧不变]

``` typescript
    console.log(await DeviceUtils.getDeviceId());
```
