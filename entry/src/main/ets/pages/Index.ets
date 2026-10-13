/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// import { keySourceListData, numberSourceListData, symbolSourceListData, keySourceListType, sourceListType,
//   keyNineChinaType, keyNineChinaData, chineseSourceListData
// } from '../model/keyboardKeyData'


// import { keySourceListData, numberSourceListData, symbolSourceListData, keySourceListType, sourceListType,
//   keyNineChinaType, keyNineChinaData, chineseSourceListData
// } from ''
import { DownMenu } from '../components/DownMenu'
import { SelectText } from '../components/SelectText'
import { keyMenu } from '../components/KeyMenu'
import { NumberMenu } from '../components/NumberMenu'
import { SymbolMenu } from '../components/SymbolMenu'
import { ChineseKeyMenu } from '../components/ChineseKeyMenu'
import { PinYinView } from '../components/PinYinView'
import { KeySetView } from '../components/KeySetView'
import { EmojiMenu } from '../components/EmojiMenu'

import deviceInfo from '@ohos.deviceInfo'
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant'
import { InputHandler } from '../model/KeyboardController'
import { KeyStyle, StyleConfiguration } from '../common/StyleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'
import {
  chineseSourceListData,
  keySourceListData,
  keySourceListType,
  numberSourceListData,
  sourceListType, symbolSourceListData } from '../model/KeyboardKeyData'

let deviceType = deviceInfo.deviceType
let TAG: string = 'index->'

@Entry
@Component
struct Index {
  private chineseKeyList: keySourceListType[]= chineseSourceListData
  private keyList: keySourceListType[]= keySourceListData
  private numberList: sourceListType[]= numberSourceListData
  private symbolList: sourceListType[]= symbolSourceListData
  @State menuType: number= 3
  @StorageLink("pinyin") pinyin: string = ""

  @StorageLink("isMoreText") isMoreText: boolean = false
  @StorageLink('isChinese') isChinese: boolean =  true
  @StorageLink('isNineKey') isNineKey: boolean =  false
  @StorageLink("isKeySet") isKeySet: boolean = false
  @StorageLink('isLandscape') @Watch('change') isLandscape: boolean = false
  @StorageLink('isRkDevice') isRkDevice: boolean = false;
  @StorageLink('themeMode') themeMode: string = 'light'
  @StorageLink('inputStyle')  inputStyle: KeyStyle = StyleConfiguration.getInputStyle(this.isLandscape, this.isRkDevice, deviceType);
  @State private colorModeWatchTimer: number = -1

  aboutToAppear(): void {
    AppStorage.setOrCreate('isChinese', true)
    this.isChinese = true
    this.menuType = 3
    AppStorage.setOrCreate('themeMode', AppStorage.get<string>('themeMode') ?? 'light')
    AppStorage.setOrCreate('systemDarkMode', AppStorage.get<boolean>('systemDarkMode') ?? false)
    AppStorage.setOrCreate('isNineKey', false)
    AppStorage.setOrCreate('isNineKeyBack', false)
    this.syncSystemDarkMode()
    if (this.colorModeWatchTimer < 0) {
      this.colorModeWatchTimer = setInterval(() => {
        this.syncSystemDarkMode()
      }, 1200)
    }
    this.initRawDict()
  }

  aboutToDisappear(): void {
    if (this.colorModeWatchTimer >= 0) {
      clearInterval(this.colorModeWatchTimer)
      this.colorModeWatchTimer = -1
    }
  }

  onBackPress(): boolean{
    InputHandler.getInstance().addLog('onBackPress');
    InputHandler.getInstance().destroyPinyin();
    InputHandler.getInstance().hideKeyboardSelf();
    return true;
  }

  change() {
    AppStorage.set<KeyStyle>('inputStyle', StyleConfiguration.getInputStyle(this.isLandscape, this.isRkDevice, deviceType))
  }

  private initRawDict() {
    try {
      InputHandler.getInstance().addLog('getRawFd');
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      context.resourceManager.getRawFd("dict_pinyin.dat").then(value => {
        InputHandler.getInstance().initPinyin(value, context.filesDir);
      }).catch((error: BusinessError) => {
      });
    } catch (error) {
    }
  }

  private syncSystemDarkMode(): void {
    try {
      const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext
      const colorModeValue = Number(hostContext.config?.colorMode ?? -1)
      const isDark = colorModeValue === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      AppStorage.setOrCreate('systemDarkMode', isDark)
    } catch (_) {
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.isKeySet === true) {
          KeySetView({ inputStyle: $inputStyle })
        } else if (this.menuType === 4) {
          EmojiMenu({ menuType: $menuType, inputStyle: $inputStyle })
        } else {
          PinYinView({ inputStyle: $inputStyle, menuType: $menuType })
          if(this.menuType === 3) {
            SelectText({ inputStyle: $inputStyle })
          } else {
            DownMenu({ inputStyle: $inputStyle })
          }
          if (!this.isMoreText || this.pinyin.length <= 0) {
            Column() {
              if (this.menuType === 0) {
                keyMenu({ keyList: this.keyList, menuType: $menuType, inputStyle: $inputStyle })
              } else if (this.menuType === 1) {
                NumberMenu({ numberList: this.numberList, menuType: $menuType, inputStyle: $inputStyle })
              } else if (this.menuType === 2) {
                SymbolMenu({ symbolList: this.symbolList, menuType: $menuType, inputStyle: $inputStyle })
              } else {
                ChineseKeyMenu({ keyList: this.chineseKeyList, menuType: $menuType,
                  inputStyle: $inputStyle
                })
              }
            }.width('100%')
            .height(this.inputStyle.bodyHeight)
            .backgroundColor(FcitxTheme.panelBg(this.themeMode))
            .opacity(this.inputStyle.backgroundOpacity)
          }
        }

      }.width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
