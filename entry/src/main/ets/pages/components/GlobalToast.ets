class ToastPalette {
  icon: Resource
  iconColor: string
  textColor: string
  backgroundColor: string
  borderColor: string
  shadowColor: string

  constructor(icon: Resource, iconColor: string, textColor: string, backgroundColor: string, borderColor: string,
    shadowColor: string) {
    this.icon = icon
    this.iconColor = iconColor
    this.textColor = textColor
    this.backgroundColor = backgroundColor
    this.borderColor = borderColor
    this.shadowColor = shadowColor
  }
}

@Component
export struct GlobalToast {
  @StorageLink('globalToastVisible') visible: boolean = false
  @StorageLink('globalToastText') text: string = ''
  @StorageLink('globalToastTone') tone: string = 'success'

  private getPalette(): ToastPalette {
    if (this.tone === 'error') {
      return new ToastPalette($r('sys.symbol.xmark_circle_fill'), '#FFFFFF', '#FFFFFF', '#D84B5B', '#E97A87',
        '#33A22739')
    }
    if (this.tone === 'warning') {
      return new ToastPalette($r('sys.symbol.exclamationmark_triangle_fill'), '#7A4B00', '#684200', '#FFF3D6',
        '#F7D28B', '#2E8A5A00')
    }
    if (this.tone === 'info') {
      return new ToastPalette($r('sys.symbol.info_circle_fill'), '#2E79F4', '#214C8F', '#EAF3FF', '#C9DEFF',
        '#1F2E79F4')
    }
    if (this.tone === 'hint') {
      return new ToastPalette($r('sys.symbol.arrowshape_turn_up_left_fill'), '#61758E', '#4F647E', '#F3F6FA',
        '#D8E0EA', '#1C15304B')
    }
    return new ToastPalette($r('sys.symbol.checkmark_circle_fill'), '#FFFFFF', '#FFFFFF', '#2BA471', '#56BB8B',
      '#33219A61')
  }

  build() {
    if (this.visible && this.text.length > 0) {
      Column() {
        Row({ space: 10 }) {
          SymbolGlyph(this.getPalette().icon)
            .fontSize(16)
            .fontColor([this.getPalette().iconColor])

          Text(this.text)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getPalette().textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(this.getPalette().backgroundColor)
        .border({ width: 1, color: this.getPalette().borderColor })
        .borderRadius(22)
        .shadow({ radius: 18, color: this.getPalette().shadowColor, offsetX: 0, offsetY: 10 })
        .constraintSize({ minWidth: 120 })
        .margin({ bottom: 94 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .hitTestBehavior(HitTestMode.None)
    }
  }
}
