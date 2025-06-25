import { common, ConfigurationConstant } from '@kit.AbilityKit'

export const ColorModeKey = 'hc-color-mode'

class Theme {
  initTheme() {
    // 持久化颜色主题，默认值亮色模式
    PersistentStorage.persistProp<ConfigurationConstant.ColorMode>(ColorModeKey,
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
    // 取出现在应用存储的颜色主题模式
    const colorMode = AppStorage.get<ConfigurationConstant.ColorMode>(ColorModeKey)
    // 设置应用颜色主题模式
    this.setTheme(colorMode!)
  }

  setTheme(mode: ConfigurationConstant.ColorMode) {
    AppStorage.set<ConfigurationConstant.ColorMode>(ColorModeKey, mode)
    const ctx = AppStorage.get<Context>('context')
    ctx?.getApplicationContext().setColorMode(mode)
    // config.colorMode 只有 COLOR_MODE_DARK 和 COLOR_MODE_LIGHT , 也就是可以判断是否是暗色
    AppStorage.setOrCreate('isDark',
      (ctx as common.UIAbilityContext).config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  // 跟随系统
  notSet() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  // 暗色
  setDark() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  // 亮色
  setLight() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }
}

export const theme = new Theme()