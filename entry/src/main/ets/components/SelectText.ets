import { KeyStyle } from '../common/StyleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'

// 文字选择键盘
@Component
export struct SelectText {
  @Link inputStyle: KeyStyle
  @StorageLink("pinyin") pinyin: string = ""
  @StorageLink("isMoreText") isMoreText: boolean = false
  @StorageLink("isKeySet") isKeySet: boolean = false
  @StorageLink("themeMode") themeMode: string = 'light'
  @State isChinese: boolean = AppStorage.get<boolean>("isChinese") ?? false
  private scroller: Scroller = new Scroller();
  @State private candidateDeleteTimerId: number = -1
  @State private candidateDeleteDelayId: number = -1

  private startCandidateContinuousDelete(): void {
    if (this.candidateDeleteTimerId >= 0) {
      return
    }
    this.candidateDeleteTimerId = setInterval(() => {
      InputHandler.getInstance().deleteForward(1, this.pinyin.length > 0)
    }, 80)
  }

  private stopCandidateContinuousDelete(): void {
    if (this.candidateDeleteDelayId >= 0) {
      clearTimeout(this.candidateDeleteDelayId)
      this.candidateDeleteDelayId = -1
    }
    if (this.candidateDeleteTimerId >= 0) {
      clearInterval(this.candidateDeleteTimerId)
      this.candidateDeleteTimerId = -1
    }
  }

  build() {
    Column() {
      if (this.pinyin.length <= 0) {
        Row() {
          Stack() {
            // Image($rawfile('ic_keyboard.png'))
            //   .width(this.inputStyle.returnPicSize)
            //   .height(this.inputStyle.returnPicSize)
            //     //.fillColor(this.isKeySet ? '#0000FF' : '#333333')
            //   .onClick(() => {
            //     AppStorage.SetOrCreate('isKeySet', true);
            //   })
          }
          .width(this.inputStyle.downMenuWidth)
          .borderRadius(4)
          .height('100%')

          Blank()

          Stack() {
          }
          .width(this.inputStyle.downMenuWidth)
          .borderRadius(4)
          .height('100%')
        }
        .width('100%')
        .height(this.inputStyle.downMenuHeight)
        .padding(1)
        .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
        .borderWidth(0)
      } else {
        Flex({
          direction: FlexDirection.Row,
        }) {
          if (this.isMoreText) {
            Grid(this.scroller) {
              LazyForEach(InputHandler.getInstance().getDataSource(), (item: string, index: number) => {
                GridItem() {
                  Column() {
                    Text(item)
                      .fontSize(19)
                      .fontColor(FcitxTheme.textPrimary(this.themeMode))
                      .fontWeight(FontWeight.Regular)
                      .height('100%')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                  }
                  .onClick(() => {
                    AppStorage.setOrCreate('isMoreText', false);
                    InputHandler.getInstance().insertText(item, this.isChinese, true, index);
                  })
                  .height(this.inputStyle.chineseCandidateHeight)
                  .borderColor(FcitxTheme.subtleDivider(this.themeMode))
                  .borderWidth(0.2)
                }
              }, (item: string) => item)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
            .scrollBar(BarState.Off)
            .onScrollIndex((_) => {

            })
            .width('90%')
          }
          else {
            Grid() {
              LazyForEach(InputHandler.getInstance().getDataSource(), (item: string, index: number) => {
                GridItem() {
                  Column({ space: 1 }) {
                    Text(item)
                      .fontSize(19)
                      .fontColor(FcitxTheme.textPrimary(this.themeMode))
                      .fontWeight(FontWeight.Regular)
                      .textAlign(TextAlign.Center)
                  }
                  .onClick(() => {
                    //修复选择文字不对应问题
                    let indexTmp = 0
                    let allData = InputHandler.getInstance().getDataSource().getDataAll()
                    for (let i = 0; i < allData.length; i++) {
                      if (allData[i] == item) {
                        indexTmp = i
                      }
                    }
                    AppStorage.setOrCreate('isMoreText', false);
                    InputHandler.getInstance().insertText(item, this.isChinese, true, indexTmp);
                  })
                  .padding({ left: 10, right: 10 })
                }
              }, (item: string) => item)
            }
            .padding({ left: 10, right: 10 })
            .columnsGap('2%')
            .rowsGap('2%')
            .rowsTemplate('1fr')
            .scrollBar(BarState.Off)
            .onScrollIndex((_) => {

            })
            .width('90%')
          }

          Flex({
            direction: FlexDirection.Column,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceAround
          }) {

            if (this.isMoreText) {
              Stack() {
                Text("返回")
                  .fontSize(19)
                  .fontColor(FcitxTheme.textPrimary(this.themeMode))
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Center)
              }.onClick(() => {
                AppStorage.setOrCreate('isMoreText', false)
              })

              Stack() {
                Image($rawfile('arrow_up.svg'))
                  .width(18)
                  .height(18)
                  .fillColor(FcitxTheme.textPrimary(this.themeMode))
              }
              .onClick(() => {
                this.scroller.scrollPage({ next: false })
              })

              Stack() {
                Image($rawfile('arrow_down.svg'))
                  .width(18)
                  .height(18)
                  .fillColor(FcitxTheme.textPrimary(this.themeMode))
              }
              .onClick(() => {
                this.scroller.scrollPage({ next: true })
              })

              Stack() {
                Image($rawfile('delete.svg'))
                  .width(18)
                  .height(18)
                  .fillColor(FcitxTheme.textPrimary(this.themeMode))
              }
              .onClick(() => {
                InputHandler.getInstance().deleteForward(1, this.pinyin.length > 0);
              })
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.stopCandidateContinuousDelete()
                  this.candidateDeleteDelayId = setTimeout(() => {
                    this.startCandidateContinuousDelete()
                    this.candidateDeleteDelayId = -1
                  }, 280)
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.stopCandidateContinuousDelete()
                }
              })
            } else {
              Stack() {
                Image($r("app.media.next"))
                  .width(18)
                  .height(18)
                  .fillColor(FcitxTheme.textPrimary(this.themeMode))
              }.onClick(() => {
                AppStorage.setOrCreate('isMoreText', true)
              })
            }

          }
          .width(this.isMoreText ? '20%' : '10%')
          .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
        }
        .width('100%')
      }
    }
    .height(this.isMoreText ? this.inputStyle.keyboardHeight : 32)
    .width('100%')
    .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
    .borderWidth(0)
  }
}