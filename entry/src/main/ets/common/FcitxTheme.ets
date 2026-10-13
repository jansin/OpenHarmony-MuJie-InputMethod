export interface EdgeBorderWidth {
  top: number
  left: number
  right: number
  bottom: number
}

export interface EdgeBorderColor {
  top: string
  left: string
  right: string
  bottom: string
}

export interface KeyBorderParam {
  width: number | EdgeBorderWidth
  color: string | EdgeBorderColor
}

export class FcitxTheme {
  static readonly PANEL_BG: string = '#D4D6DB'
  static readonly TOOLBAR_BG: string = '#FFFFFF'
  static readonly CANDIDATE_BG: string = '#E8EEF2'
  static readonly DIVIDER: string = '#D6DCE4'
  static readonly TEXT_PRIMARY: string = '#101418'
  static readonly TEXT_SECONDARY: string = '#64748B'
  static readonly TEXT_ON_ACCENT: string = '#FFFFFF'
  static readonly TRANSPARENT: string = '#00000000'

  static readonly LETTER_KEY_BG: string = '#FFFFFF'
  static readonly LETTER_KEY_PRESSED: string = '#E2E5EA'
  static readonly FUNC_KEY_BG: string = '#BAC1CC'
  static readonly FUNC_KEY_PRESSED: string = '#AAB2BF'
  static readonly ACCENT_KEY_BG: string = '#5DA99A'

  static readonly KEY_RADIUS: number = 9
  static readonly BOTTOM_KEY_RADIUS: number = 8
  static readonly KEY_TEXT_SIZE: number = 17
  static readonly FUNC_TEXT_SIZE: number = 15
  static readonly CAND_TEXT_SIZE: number = 16
  static readonly CAND_TEXT_SIZE_SMALL: number = 14
  static readonly NINE_HINT_TEXT_SIZE: number = 10
  static readonly ROW2_INSET: number = 8
  static readonly SHIFT_SIDE_KEY_WIDTH: number = 40
  static readonly SHIFT_ICON_SIZE: number = 18
  static readonly SHIFT_ACTIVE_BG: string = '#A8B4C4'
  static readonly ICON_SIZE: number = 18
  static readonly TOP_ICON_SIZE: number = 24
  static readonly KEY_MARGIN_H: number = 2
  static readonly KEY_MARGIN_V: number = 3
  static readonly KEY_ITEM_MARGIN_H: number = 3
  static readonly KEY_ITEM_MARGIN_V: number = 2
  static readonly KEY_ROW_HEIGHT: number = 48
  static readonly KEY_BOTTOM_ROW_HEIGHT: number = 42

  static letterBorder(): KeyBorderParam {
    return {
      width: { top: 0, left: 0.5, right: 0.5, bottom: 1.6 },
      color: { top: '#00000000', left: '#E2E5E9', right: '#E2E5E9', bottom: '#9CA3AF' }
    }
  }

  static letterPressedBorder(): KeyBorderParam {
    return {
      width: { top: 0, left: 0.5, right: 0.5, bottom: 1.6 },
      color: { top: '#00000000', left: '#D5D7DD', right: '#D5D7DD', bottom: '#9CA3AF' }
    }
  }

  static functionBorder(): KeyBorderParam {
    return {
      width: { top: 0, left: 0.5, right: 0.5, bottom: 1.2 },
      color: { top: '#00000000', left: '#A9B0BB', right: '#A9B0BB', bottom: '#98A1AE' }
    }
  }

  static isDark(mode?: string): boolean {
    const currentMode = mode ?? (AppStorage.get<string>('themeMode') ?? 'light')
    if (currentMode === 'dark') {
      return true
    }
    if (currentMode === 'system') {
      return AppStorage.get<boolean>('systemDarkMode') ?? false
    }
    return false
  }

  static panelBg(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#2B2F36' : '#D5D9E0'
  }

  static toolbarBg(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#2B2F36' : '#D5D9E0'
  }

  static textPrimary(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#F3F5F8' : '#1B1F24'
  }

  static textSecondary(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#B8C0CF' : '#8B95A1'
  }

  static letterKeyBg(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#4A5160' : '#FFFFFF'
  }

  static letterKeyPressed(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#5A6272' : '#E9EDF3'
  }

  static functionKeyBg(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#5A6272' : '#C6CCD6'
  }

  static functionKeyPressed(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#6A7385' : '#B4BCC8'
  }

  static shadowColor(mode?: string, elevated: boolean = false): string {
    if (FcitxTheme.isDark(mode)) {
      return elevated ? '#00000066' : '#00000040'
    }
    return elevated ? '#76787c' : '#00000014'
  }

  static subtleDivider(mode?: string): string {
    return FcitxTheme.isDark(mode) ? '#40FFFFFF' : '#33000000'
  }
}
