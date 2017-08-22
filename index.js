import {
  NativeModules,
  Platform,
} from 'react-native';

const helper = Platform.OS=='android'?NativeModules.PermissionHelper:NativeModules.AuthorizationsHelper

module.exports = helper;
