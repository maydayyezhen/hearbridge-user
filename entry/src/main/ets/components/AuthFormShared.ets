/**
 * AuthFormShared 文件，负责登录 / 注册页共享壳、输入框与提示文案样式。
 */

@Builder
function BuildEmptyAuthContent(): void {
}

/**
 * 判断当前提示文案是否需要以内联提示形式展示。
 */
export function shouldShowAuthInlineTip(tip?: string, defaultTip?: string): boolean {
  const normalizedTip = tip ?? ''
  const normalizedDefaultTip = defaultTip ?? ''
  return normalizedTip.length > 0 && normalizedTip !== normalizedDefaultTip
}

/**
 * 计算认证页提示文案颜色。
 */
export function getAuthInlineTipColor(tip?: string): string {
  const normalizedTip = tip ?? ''
  if (normalizedTip.indexOf('成功') >= 0) {
    return '#2BA471'
  }
  if (normalizedTip.indexOf('正在') >= 0 || normalizedTip.indexOf('已') === 0) {
    return '#7A8CA7'
  }
  return '#E5484D'
}

@Builder
/**
 * 构建认证页通用输入框。
 */
export function BuildAuthInputField(label: string, placeholder: string, value: string,
  onChange: (value: string) => void, isPassword: boolean = false) {
  Column({ space: 7 }) {
    Text(label)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor('#3F5672')

    TextInput({ text: value, placeholder })
      .width('100%')
      .height(52)
      .fontSize(16)
      .fontColor('#1D2F45')
      .type(isPassword ? InputType.Password : InputType.Normal)
      .backgroundColor('#F8FBFF')
      .borderRadius(16)
      .border({ width: 1, color: '#C8D8EA' })
      .padding({ left: 15, right: 15 })
      .placeholderFont({ size: 15 })
      .placeholderColor('#778CA7')
      .onChange(onChange)
  }
  .width('100%')
  .alignItems(HorizontalAlign.Start)
}

@Builder
/**
 * 构建认证页内联提示文案。
 */
export function BuildAuthInlineTip(tip: string, defaultTip: string) {
  if (shouldShowAuthInlineTip(tip, defaultTip)) {
    Text(tip ?? '')
      .width('100%')
      .fontSize(12)
      .lineHeight(18)
      .fontColor(getAuthInlineTipColor(tip))
      .textAlign(TextAlign.Start)
      .margin({ top: -4 })
  }
}

@Component
export struct AuthFormScaffold {
  /** 是否使用可滚动表单容器。 */
  @Prop useScroll: boolean = false
  /** 底部协议提示文案。 */
  @Prop footerText: string = '登录即代表同意《用户协议》与《隐私条款》'
  /** 左右内边距。 */
  @Prop horizontalPadding: number = 22
  /** 顶部内边距。 */
  @Prop topPadding: number = 28
  /** 底部内边距。 */
  @Prop bottomPadding: number = 18

  /** 页面主体构建器。 */
  @BuilderParam content: () => void = BuildEmptyAuthContent

  @Builder
  private buildFooterText(): void {
    if ((this.footerText ?? '').length > 0) {
      Text(this.footerText)
        .width('100%')
        .fontSize(12)
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .fontColor('#7C8FA6')
    }
  }

  build() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#F8FBFF', 0], ['#F2F7FF', 0.42], ['#FFFFFF', 1]]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      if (this.useScroll) {
        Scroll() {
          Column({ space: 0 }) {
            this.content()

            if ((this.footerText ?? '').length > 0) {
              Column() {
                this.buildFooterText()
              }
              .width('100%')
              .margin({ top: 20 })
            }
          }
          .width('100%')
          .padding({
            left: this.horizontalPadding,
            right: this.horizontalPadding,
            top: this.topPadding,
            bottom: this.bottomPadding
          })
          .constraintSize({ minHeight: '100%' })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Column() {
            this.content()
          }
          .width('100%')

          Blank()
            .layoutWeight(1)

          this.buildFooterText()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .padding({
          left: this.horizontalPadding,
          right: this.horizontalPadding,
          top: this.topPadding,
          bottom: this.bottomPadding
        })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
