/**
 * 训练流程大纲面板。
 */
import { TrainingContentItem } from '../../../../domain/static/train/TrainingContentModels'
import { CourseTrainingItemList } from '../../../../components/CourseTrainingItemList'

@Component
export struct TrainOutlinePanel {
  @Prop courseName: string = ''
  @Prop courseCode: string = ''
  @Prop progressText: string = '0/0'
  @Prop panelOffsetX: number = 360
  @Prop items: TrainingContentItem[] = []
  @Prop completedItemIds: number[] = []
  @Prop currentIndex: number = 0
  @Prop isCourseFavorited: boolean = false
  onClose: () => void = () => {}
  onItemClick: (itemId: number, completed: boolean) => void = (_itemId: number, _completed: boolean) => {}
  onCourseFavoriteToggle: (courseCode: string) => void = (_courseCode: string) => {}

  @Builder
  private buildOutlineAnchorButton() {
    Button() {
      Column({ space: 2 }) {
        SymbolGlyph($r('sys.symbol.square_grid_2x2'))
          .fontSize(18)
          .fontColor(['#7E8FA8'])

        Text(this.progressText)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5F718B')
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width(56)
    .height(46)
    .stateEffect(false)
    .backgroundColor('#FFFFFF')
    .borderRadius(0)
    .onClick(() => {
      this.onClose()
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onClose()
        })

      Column({ space: 12 }) {
        Row() {
          Text('训练清单')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          Blank()

          Text(this.progressText)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
            .padding({ left: 9, right: 9, top: 4, bottom: 4 })
            .backgroundColor('#EEF5FF')
            .borderRadius(9)
        }
        .width('100%')

        if (this.courseName.length > 0) {
          Row({ space: 8 }) {
            Text(`课程：${this.courseName}`)
              .layoutWeight(1)
              .fontSize(12)
              .fontColor('#6F8098')
              .maxLines(1)

            Button() {
              Row({ space: 4 }) {
                SymbolGlyph(this.isCourseFavorited ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
                  .fontSize(13)
                  .fontColor([this.isCourseFavorited ? '#2E79F4' : '#8EA0BA'])

                Text(this.isCourseFavorited ? '已收藏' : '收藏课程')
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isCourseFavorited ? '#2E79F4' : '#6F8098')
              }
              .alignItems(VerticalAlign.Center)
            }
            .height(26)
            .padding({ left: 8, right: 8 })
            .backgroundColor('#EEF5FF')
            .borderRadius(13)
            .stateEffect(false)
            .onClick(() => {
              this.onCourseFavoriteToggle(this.courseCode)
            })
          }
          .width('100%')
        }

        Scroll() {
          Column({ space: 0 }) {
            CourseTrainingItemList({
              items: this.items,
              completedItemIds: this.completedItemIds,
              currentIndex: this.currentIndex,
              showHeader: false,
              isCard: false,
              rowHeight: 56,
              rowHorizontalPadding: 12,
              rowSpacing: 10,
              onItemIdClick: (itemId: number, completed: boolean) => {
                this.onItemClick(itemId, completed)
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ minHeight: '100%' })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 2, right: 2, top: 4, bottom: 0 })
        .scrollBar(BarState.Off)
      }
      .width('78%')
      .height('100%')
      .padding({ left: 18, right: 18, top: 22, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 18, topRight: 0, bottomLeft: 18, bottomRight: 0 })
      .border({ width: { left: 1, right: 0, top: 0, bottom: 0 }, color: '#E7EEF8' })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .shadow({ radius: 22, color: '#301B2A44', offsetX: -8, offsetY: 0 })
      .translate({ x: this.panelOffsetX, y: 0 })

      Column() {
        this.buildOutlineAnchorButton()
      }
      .width(56)
      .height(46)
      .padding({ right: 16, bottom: 6 })
      .position({ right: 16, bottom: 6 })
      .translate({ x: this.panelOffsetX, y: 0 })
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 1 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .zIndex(1002)
  }
}
