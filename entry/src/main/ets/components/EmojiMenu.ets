import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'
import { InputHandler } from '../model/KeyboardController'
import { EMOJI_CATEGORY_ORDER, EMOJI_COMPACT_DATA } from '../model/EmojiData'

@Component
export struct EmojiMenu {
  private static readonly RECENT_CATEGORY: string = 'emoji_recent'
  private static readonly RECENT_STORAGE_KEY: string = 'emojiRecentJson'
  private static readonly ACTIVE_CATEGORY_KEY: string = 'emojiActiveCategory'
  private static readonly RECENT_LIMIT: number = 40
  @Link inputStyle: KeyStyle
  @Link menuType: number
  @StorageLink('isChinese') isChinese: boolean = true
  @StorageLink('themeMode') themeMode: string = 'light'
  @State activeCategory: string = EmojiMenu.RECENT_CATEGORY
  @State recentList: string[] = []
  @State private deleteTimerId: number = -1
  @State private deleteDelayId: number = -1
  private emojiScroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const raw = AppStorage.get<string>(EmojiMenu.RECENT_STORAGE_KEY) ?? ''
    if (raw.length <= 0) {
      this.recentList = []
      return
    }
    try {
      const parsed = JSON.parse(raw) as string[]
      this.recentList = Array.isArray(parsed) ? parsed : []
    } catch (_) {
      this.recentList = []
    }

    const savedCategory = AppStorage.get<string>(EmojiMenu.ACTIVE_CATEGORY_KEY) ?? EmojiMenu.RECENT_CATEGORY
    if (this.allCategories().includes(savedCategory)) {
      this.activeCategory = savedCategory
    } else {
      this.activeCategory = EmojiMenu.RECENT_CATEGORY
    }
  }

  private allCategories(): string[] {
    return [EmojiMenu.RECENT_CATEGORY, ...EMOJI_CATEGORY_ORDER]
  }

  private categoryIcon(name: string): string {
    switch (name) {
      case 'emoji_recent':
        return '🕘'
      case 'emoji_smileys_emotion':
        return '😀'
      case 'emoji_people_body':
        return '👋'
      case 'emoji_animals_nature':
        return '🐶'
      case 'emoji_food_drink':
        return '🍔'
      case 'emoji_travel_places':
        return '🚗'
      case 'emoji_activities':
        return '⚽'
      case 'emoji_objects':
        return '💡'
      case 'emoji_symbols':
        return '❤️'
      case 'emoji_flags':
        return '🏳️'
      default:
        return '😀'
    }
  }

  private currentList(): string[] {
    if (this.activeCategory === EmojiMenu.RECENT_CATEGORY) {
      return this.recentList
    }
    return EMOJI_COMPACT_DATA[this.activeCategory] ?? []
  }

  private categoryBg(name: string): string {
    if (this.activeCategory === name) {
      return FcitxTheme.functionKeyBg(this.themeMode)
    }
    return this.themeMode === 'dark' ? '#18FFFFFF' : '#33FFFFFF'
  }

  private emojiKeyBg(): string {
    return this.themeMode === 'dark' ? '#22FFFFFF' : '#F7F9FC'
  }

  @Styles emojiPressedStyle() {
    .backgroundColor(this.themeMode === 'dark' ? '#38FFFFFF' : '#E9EEF7')
  }

  @Styles emojiNormalStyle() {
    .backgroundColor(this.emojiKeyBg())
  }

  @Styles categoryPressedStyle() {
    .backgroundColor(this.themeMode === 'dark' ? '#30FFFFFF' : '#E6ECF8')
  }

  private rememberEmoji(emoji: string): void {
    const next = [emoji, ...this.recentList.filter((item: string) => item !== emoji)]
    this.recentList = next.slice(0, EmojiMenu.RECENT_LIMIT)
    AppStorage.setOrCreate(EmojiMenu.RECENT_STORAGE_KEY, JSON.stringify(this.recentList))
  }

  private changeCategory(name: string): void {
    this.activeCategory = name
    AppStorage.setOrCreate(EmojiMenu.ACTIVE_CATEGORY_KEY, name)
  }

  private deleteOne(): void {
    InputHandler.getInstance().deleteForward(1, false)
  }

  private startContinuousDelete(): void {
    if (this.deleteTimerId >= 0) {
      return
    }
    this.deleteTimerId = setInterval(() => {
      this.deleteOne()
    }, 80)
  }

  private stopContinuousDelete(): void {
    if (this.deleteDelayId >= 0) {
      clearTimeout(this.deleteDelayId)
      this.deleteDelayId = -1
    }
    if (this.deleteTimerId >= 0) {
      clearInterval(this.deleteTimerId)
      this.deleteTimerId = -1
    }
  }

  build() {
    Column() {
      Row() {
        ForEach(this.allCategories(), (name: string) => {
          Stack() {
            Text(this.categoryIcon(name))
              .fontSize(20)
          }
          .width('7.6%')
          .height('100%')
          .borderRadius(8)
          .backgroundColor(this.categoryBg(name))
          .borderWidth(this.activeCategory === name ? 1 : 0.5)
          .borderColor(this.activeCategory === name ? FcitxTheme.textSecondary(this.themeMode) : FcitxTheme.subtleDivider(this.themeMode))
          .shadow({ radius: this.activeCategory === name ? 1 : 0, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
          .stateStyles({
            pressed: this.categoryPressedStyle
          })
          .onClick(() => {
            this.changeCategory(name)
          })
        }, (name: string) => name)

        Stack() {
          Row({ space: 4 }) {
            Text('⌫')
              .fontSize(17)
              .fontColor(FcitxTheme.textPrimary(this.themeMode))
            Text('删除')
              .fontSize(15)
              .fontColor(FcitxTheme.textPrimary(this.themeMode))
          }
        }
        .width('12%')
        .height('100%')
        .borderRadius(8)
        .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
        .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
        .onClick(() => {
          this.deleteOne()
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.stopContinuousDelete()
            this.deleteDelayId = setTimeout(() => {
              this.startContinuousDelete()
              this.deleteDelayId = -1
            }, 280)
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.stopContinuousDelete()
          }
        })

        Stack() {
          Row({ space: 4 }) {
            Text('←')
              .fontSize(17)
              .fontColor(FcitxTheme.textPrimary(this.themeMode))
            Text('返回')
              .fontSize(15)
              .fontColor(FcitxTheme.textPrimary(this.themeMode))
          }
        }
        .width('12%')
        .height('100%')
        .borderRadius(8)
        .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
        .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
        .onClick(() => {
          this.menuType = this.isChinese ? 3 : 0
        })
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .padding({ left: 4, right: 4, top: 2, bottom: 2 })
      .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
      .borderRadius(10)
      .margin({ left: 2, right: 2 })

      if (this.currentList().length <= 0) {
        Column() {
          Text('暂无最近使用')
            .fontSize(16)
            .fontColor(FcitxTheme.textSecondary(this.themeMode))
          Text('点击任意表情后会显示在这里')
            .fontSize(13)
            .fontColor(FcitxTheme.textSecondary(this.themeMode))
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Grid(this.emojiScroller) {
          ForEach(this.currentList(), (emoji: string) => {
            GridItem() {
              Stack() {
                Text(emoji)
                  .fontSize(24)
              }
              .width('100%')
              .height('100%')
              .borderRadius(10)
              .borderWidth(0.4)
              .borderColor(FcitxTheme.subtleDivider(this.themeMode))
              .shadow({ radius: 0.8, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
              .stateStyles({
                normal: this.emojiNormalStyle,
                pressed: this.emojiPressedStyle
              })
              .onClick(() => {
                this.rememberEmoji(emoji)
                // Emoji should always commit directly, not go through pinyin composing.
                InputHandler.getInstance().insertText(emoji, false)
              })
              .margin({ left: 2, right: 2, top: 1, bottom: 1 })
            }
          }, (emoji: string, index: number) => `${emoji}_${index}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(1)
        .columnsGap(1)
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 2, bottom: 1 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(FcitxTheme.panelBg(this.themeMode))
  }
}
