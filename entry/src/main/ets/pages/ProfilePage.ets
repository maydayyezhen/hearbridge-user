@Component
export struct ProfilePage {
  @Prop selectedGoal: string = 'Daily communication'
  @Prop selectedTheme: string = 'Ocean'
  @Prop notificationsEnabled: boolean = true
  @Prop vibrationEnabled: boolean = false
  onGoalChange: (goal: string) => void = () => {}
  onThemeChange: (theme: string) => void = () => {}
  onNotificationsChange: (value: boolean) => void = () => {}
  onVibrationChange: (value: boolean) => void = () => {}

  private readonly goals: string[] = ['Daily communication', 'Lip reading', 'Emotion expression']
  private readonly themes: string[] = ['Ocean', 'Mint', 'Sunset']

  build() {
    Column({ space: 18 }) {
      Text('Profile')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#203040')

      this.buildSectionTitle('Goal')
      Column({ space: 10 }) {
        ForEach(this.goals, (goal: string) => {
          this.buildSelector(goal, this.selectedGoal === goal, () => {
            this.onGoalChange(goal)
          })
        }, (goal: string) => goal)
      }
      .width('100%')

      this.buildSectionTitle('Theme')
      Column({ space: 10 }) {
        ForEach(this.themes, (theme: string) => {
          this.buildSelector(theme, this.selectedTheme === theme, () => {
            this.onThemeChange(theme)
          })
        }, (theme: string) => theme)
      }
      .width('100%')

      this.buildSectionTitle('Notifications')
      this.buildToggleRow('Daily reminder', this.notificationsEnabled, (value: boolean) => {
        this.onNotificationsChange(value)
      })

      this.buildSectionTitle('Vibration')
      this.buildToggleRow('Haptic feedback', this.vibrationEnabled, (value: boolean) => {
        this.onVibrationChange(value)
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 110 })
  }

  @Builder
  private buildSectionTitle(label: string) {
    Text(label)
      .width('100%')
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor('#203040')
  }

  @Builder
  private buildSelector(label: string, active: boolean, onClickAction: () => void) {
    Text(label)
      .width('100%')
      .fontSize(14)
      .fontColor(active ? '#FFFFFF' : '#203040')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(active ? '#246BFD' : '#FFFFFF')
      .borderRadius(18)
      .onClick(() => {
        onClickAction()
      })
  }

  @Builder
  private buildToggleRow(label: string, value: boolean, onChangeAction: (value: boolean) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#203040')

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor('#246BFD')
        .onChange((nextValue: boolean) => {
          onChangeAction(nextValue)
        })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
