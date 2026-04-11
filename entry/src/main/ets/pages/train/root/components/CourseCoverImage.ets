/**
 * 课程封面图组件。
 */

import { APP_RADIUS, APP_SHADOW } from '../../../../config/AppStyle'
@Component
export struct CourseCoverImage {
  @Prop coverUrl: string = ''
  @Prop coverSeed: number = 1
  @State currentUrl: string = ''

  aboutToAppear() {
    if (this.coverUrl.trim().length > 0) {
      this.currentUrl = this.coverUrl
    } else {
      this.currentUrl = ''
    }
  }

  build() {
    Image(this.currentUrl.length > 0 ? this.currentUrl : $r('app.media.startIcon'))
      .width(128)
      .height(76)
      .objectFit(ImageFit.Cover)
      .borderRadius(APP_RADIUS.md)
      .clip(true)
      .shadow(APP_SHADOW.soft)
      .onError(() => {
        this.currentUrl = ''
      })
  }
}
