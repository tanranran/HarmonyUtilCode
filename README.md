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
ohpm install @android/utilCode
```

## 📦使用

### 1.在项目中引入插件

```
import { DeviceUtils } from '@android/utilCode'
```

类按需引入,项目需要使用那个就引入

#### 1.1 DeviceUtils的方法

``` typescript
import { DeviceUtils } from '@android/utilCode'
```

* getDeviceId 获取设备id>32为随机码[卸载APP后依旧不变]

``` typescript
    console.log(await DeviceUtils.getDeviceId());
```

#### 1.2 CharUtils的方法

``` typescript
import { CharUtils } from '@android/utilCode'
```

* isBlankChar 是否空白符 空白符包括空格、制表符、全角空格和不间断空格
* isAscii 检查字符是否位于ASCII范围内（0~127）
* isEmoji 判断是否为emoji表情符

#### 1.3 StringUtils的方法

后期会增加扩展方法，使用会更简单

``` typescript
import { StringUtils } from '@ranran/utilCode'
```

* isBlank 判断字符串是否为空白符(空白符包括空格、制表符、全角空格和不间断空格)true为空，否则false
* isNotBlank 判断字符串是否为非空白符(空白符包括空格、制表符、全角空格和不间断空格)true为非空，否则false
* isEmpty 判断字符串是否为空
* toString 字符串转string，主要用于保证空安全
* replaceAll 字符串全部替换为指定字符串

#### 1.4 ObjectUtils的方法

后期会增加扩展方法，使用会更简单

``` typescript
import { ObjectUtils } from '@android/utilCode'
```

* isString 判断属性是否是string类型类型
* isNull 判断属性是否为空
* isEmpty 判断属性内容是否为空【Object | String | Number | Boolean | null | undefined | Array | Map...】
* equal 判断两个传入的数值或者是字符串是否相等
* notEqual 判断两个传入的数值或者是字符串是否不相等
* deepCopy 深拷贝对象

#### 1.5 AssetStore的方法

基于 @ohos.security.asset 的封装。可以保证『重装/删除应用而不丢失数据』。

``` typescript
import { AssetStore } from '@android/utilCode'
```

* set 增
* remove 删
* update 改
* get 查
