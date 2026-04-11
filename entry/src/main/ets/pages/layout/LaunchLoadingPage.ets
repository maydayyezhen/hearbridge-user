/**
 * LaunchLoadingPage 页面文件，负责页面展示与交互承接。
 */

@Component
export struct LaunchLoadingPage {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.loadingcover'))
          .width('100%')
          .height('92%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .clip(false)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column({ space: 14 }) {
        LoadingProgress()
          .width(30)
          .height(30)
          .color('#FFFFFF')

        Text('听桥')
          .fontSize(60)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .fontFamily('HarmonyOS Sans')

        Text('HearBridge')
          .fontSize(23)
          .fontWeight(FontWeight.Regular)
          .fontColor('#FFFFFF')
          .letterSpacing(1.4)
          .fontFamily('HarmonyOS Sans')

        Text('口语与手语训练平台')
          .fontSize(23)
          .fontWeight(FontWeight.Regular)
          .fontColor('#E7F0FF')
          .fontFamily('HarmonyOS Sans')
      }
      .width('100%')
      .padding({ left: 32, right: 32, bottom: 308 })
      .alignItems(HorizontalAlign.Center)
      .translate({ x: 0, y: -40 })

      Column() {
        Text('— 让表达被听见 —')
          .fontSize(22)
          .fontWeight(FontWeight.Regular)
          .fontColor('#888888')
          .fontFamily('HarmonyOS Sans')
          .letterSpacing(1.5)
      }
      .width('100%')
      .padding({ left: 32, right: 32, bottom: 20 })
      .alignItems(HorizontalAlign.Center)
      .position({ left: 0, bottom: 0 })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@Builder
/** BuildLaunchRoute。 */
export function BuildLaunchRoute() {
  LaunchLoadingPage()
}
