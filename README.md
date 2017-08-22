# react-native-authorization [![Build](https://img.shields.io/badge/build-passing-brightgreen.svg?style=flat)](#)[![Platform](https://img.shields.io/badge/platform-ios_android-brightgreen.svg?style=flat)](#)[![npm](https://img.shields.io/npm/v/react-native-quicklook.svg)](https://www.npmjs.com/package/react-native-authorization)

## Content
* [Installation](#1)
* [Usage](#3)
* [API](#2)
* [Author](#4)
* [License](#5)


## <a id=1>Installation</a>

~~~
# step 1
npm install react-native-authorization 
# yarn add react-native-authorization

# step 2
react-native link react-native-authorization 
~~~

## <a id=3>Usage</a>

~~~
import Helper from 'react-native-authorization'

Helper.check(Helper.CAMERA).then((r)=>{
    console.log(r);
});
~~~

## <a id=2>API</a>

**Methods**

| Method Name| Arguments | Notes | iOS | android |
| --- | --- | --- | --- | --- |
| check | type | Returns a promise | ✔️ | ✔️ |
| multipleCheck | [type1,type2] | Returns a promise | ❌ | ✔️ |

**Check Type**

| Name | iOS | android |
| --- | --- | --- |
| CAMERA  | ✔️ | ✔️ |
| LIBRARY | ✔️ | ❌ |
| LOCATION | ✔️ | ✔️ |
| ALWAYSLOCATION | ✔️ | ❌ |
| USELOCATION | ✔️ | ❌ |
| MIKE | ✔️ | ❌ |
| CALENDAR | ❌ | ✔️ |
| CONTACTS | ❌ | ✔️ |
| MICROPHONE | ❌ | ✔️ |
| PHONE | ❌ | ✔️ |
| SENSORS | ❌ | ✔️ |
| SMS | ❌ | ✔️ |
| STORAGE | ❌ |✔️ | 

**Permission Result**

| Result | Type | iOS | android |
| --- | --- | --- | --- |
| `Authorized` | string | ✔️ | ❌ |
| `AuthorizedAlways` | string | ✔️ | ❌ |
| `AuthorizedWhenInUse` | string | ✔️ | ❌ |
| `Denied` | string | ✔️ | ❌ |
| `NotDetermined` | string | ✔️ | ❌ |
| `Restricted` | string | ✔️ | ❌ |
| `true` | boolean | ❌ | ✔️ |
| `false` | boolean | ❌ | ✔️ |


## <a id=4>Author</a>

Ruwei Li, liruwei0109@outlook.com

## <a id=5>License</a>

react-native-authorization is available under the ISC license. See the LICENSE file for more info.

