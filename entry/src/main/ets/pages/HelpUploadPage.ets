import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import dataSharePredicates from '@ohos.data.dataSharePredicates'
import { readToken } from '../api/AuthStorage'

@Component
export struct HelpUploadPage {
  @Prop apiBaseUrl: string = ''
  onBack: () => void = () => {}

  @State imageUri: string = ''
  @State imageName: string = 'upload.jpg'
  @State resultText: string = '未开始'
  @State isPicking: boolean = false
  @State isUploading: boolean = false

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private normalizeUri(uri: string): string {
    return uri.split('#')[0].split('?')[0]
  }

  private getFileName(uri: string): string {
    const cleanUri = this.normalizeUri(uri)
    const lastSlash = cleanUri.lastIndexOf('/')
    return lastSlash >= 0 ? cleanUri.substring(lastSlash + 1) : 'image.jpg'
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button('<')
          .width(36)
          .height(36)
          .fontSize(16)
          .fontColor('#2E79F4')
          .backgroundColor('#EAF2FF')
          .borderRadius(18)
          .onClick(() => {
            this.onBack()
          })

        Text('帮助与反馈')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
      }
      .width('100%')

      Button(this.isPicking ? '选择中...' : '选择图片')
        .width('100%')
        .height(44)
        .enabled(!this.isPicking && !this.isUploading)
        .onClick(() => {
          this.pickImage()
        })

      Button(this.isUploading ? '上传中...' : '上传图片')
        .width('100%')
        .height(44)
        .enabled(this.imageUri.length > 0 && !this.isPicking && !this.isUploading)
        .onClick(() => {
          this.uploadImage()
        })

      if (this.imageUri.length > 0) {
        Image(this.imageUri)
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(16)
      }

      Text(this.resultText)
        .width('100%')
        .fontSize(13)
        .fontColor('#344054')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#F5F7FB')
  }

  private async pickImage() {
    if (this.isPicking) {
      return
    }
    this.isPicking = true
    this.resultText = '正在打开图片选择器...'
    try {
      let photoPicker = new photoAccessHelper.PhotoViewPicker()
      let pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      pickerOptions.maxSelectNumber = 1
      const result = await photoPicker.select(pickerOptions) as photoAccessHelper.PhotoSelectResult
      if (result.photoUris.length < 1) {
        this.resultText = '未选择图片'
        return
      }

      this.imageUri = this.normalizeUri(result.photoUris[0])
      this.imageName = this.getFileName(this.imageUri)
      this.resultText = `已选择: ${this.imageName}`
    } catch (error) {
      this.resultText = `选择失败: ${JSON.stringify(error)}`
    } finally {
      this.isPicking = false
    }
  }

  private async uploadImage() {
    if (this.isUploading || this.imageUri.length === 0) {
      return
    }
    this.isUploading = true
    this.resultText = '正在读取图片...'

    const requestInstance = http.createHttp()
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.resultText = '缺少 token'
        return
      }

      const imageData = await this.readImageData(this.getAbilityContext() as common.UIAbilityContext, this.imageUri)
      if (imageData.byteLength === 0) {
        this.resultText = '读取图片数据失败'
        return
      }
      this.resultText = '正在上传图片...'
      const response = await requestInstance.request(
        `${this.normalizeBaseUrl(this.apiBaseUrl)}/app/file/upload/binary`,
        {
          method: http.RequestMethod.POST,
          expectDataType: http.HttpDataType.STRING,
          usingCache: false,
          connectTimeout: 10000,
          readTimeout: 10000,
          header: {
            token,
            Accept: 'application/json',
            'Content-Type': 'application/octet-stream',
            'X-Filename': this.imageName
          },
          extraData: imageData
        }
      )

      const rawBody = typeof response.result === 'string' ? response.result : JSON.stringify(response.result)
      this.resultText = `HTTP ${response.responseCode}\n${rawBody}`
    } catch (error) {
      this.resultText = `上传失败: ${JSON.stringify(error)}`
    } finally {
      requestInstance.destroy()
      this.isUploading = false
    }
  }

  private async readImageData(context: common.UIAbilityContext, sourceUri: string): Promise<ArrayBuffer> {
    const helper = photoAccessHelper.getPhotoAccessHelper(context)
    const predicates = new dataSharePredicates.DataSharePredicates()
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, sourceUri)
    const fetchResult = await helper.getAssets({
      fetchColumns: [photoAccessHelper.PhotoKeys.URI],
      predicates: predicates
    })

    try {
      if (fetchResult.getCount() < 1) {
        throw new Error('asset not found')
      }

      const asset = await fetchResult.getFirstObject()
      return await new Promise<ArrayBuffer>((resolve, reject) => {
        photoAccessHelper.MediaAssetManager.requestImageData(
          context,
          asset,
          {
            deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE
          },
          {
            onDataPrepared: (data: ArrayBuffer): void => {
              resolve(data)
            }
          }
        ).catch((error: Error) => reject(error))
      })
    } finally {
      fetchResult.close()
      helper.release()
    }
  }

  private normalizeBaseUrl(baseUrl: string): string {
    return baseUrl.endsWith('/') ? baseUrl.slice(0, baseUrl.length - 1) : baseUrl
  }
}
