/**
 * 共享文件资源本地服务，负责读取本地图片/音视频资源并生成上传所需字节数据，不直接发起网络请求。
 */
import common from '@ohos.app.ability.common'
import fileIo from '@ohos.file.fs'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import dataSharePredicates from '@ohos.data.dataSharePredicates'

/**
 * 判断给定 uri 是否为系统相册资源。
 */
function isPhotoAssetUri(uri: string): boolean {
  return uri.indexOf('file://media/Photo') === 0 || uri.indexOf('datashare://') === 0
}

/**
 * 按实际读取长度裁剪缓冲区。
 */
function sliceBuffer(buffer: ArrayBuffer, size: number): ArrayBuffer {
  if (size >= buffer.byteLength) {
    return buffer
  }
  return buffer.slice(0, size)
}

/**
 * 读取系统相册资源的字节数据。
 */
async function readPhotoAssetData(context: common.UIAbilityContext, sourceUri: string): Promise<ArrayBuffer> {
  try {
    const helper = photoAccessHelper.getPhotoAccessHelper(context)
    const predicates = new dataSharePredicates.DataSharePredicates()
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, sourceUri)
    const fetchResult = await helper.getAssets({
      fetchColumns: [photoAccessHelper.PhotoKeys.URI],
      predicates
    } as photoAccessHelper.FetchOptions)

    try {
      if (fetchResult.getCount() < 1) {
        throw new Error('Photo asset not found')
      }

      const asset = await fetchResult.getFirstObject()
      return await new Promise<ArrayBuffer>((resolve, reject) => {
        photoAccessHelper.MediaAssetManager.requestImageData(
          context,
          asset,
          { deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE } as photoAccessHelper.RequestOptions,
          {
            onDataPrepared: (data: ArrayBuffer): void => {
              resolve(data)
            }
          }
        ).catch((error: Error) => reject(error))
      })
    } finally {
      try {
        fetchResult.close()
      } catch (_error) {
      }
      try {
        helper.release()
      } catch (_error) {
      }
    }
  } catch (_error) {
    return new ArrayBuffer(0)
  }
}

/**
 * 读取普通文件 uri 的字节数据。
 */
function readGenericFileData(sourceUri: string): ArrayBuffer {
  let file: fileIo.File | null = null
  try {
    file = fileIo.openSync(sourceUri, fileIo.OpenMode.READ_ONLY)
    const stat = fileIo.statSync(file.fd)
    const size = Number(stat.size)
    if (size <= 0) {
      return new ArrayBuffer(0)
    }
    const buffer = new ArrayBuffer(size)
    const readSize = fileIo.readSync(file.fd, buffer)
    return sliceBuffer(buffer, readSize)
  } catch (_error) {
    return new ArrayBuffer(0)
  } finally {
    if (file !== null) {
      try {
        fileIo.closeSync(file)
      } catch (_error) {
      }
    }
  }
}

/**
 * 读取上传所需的字节载荷。
 * @param context 页面上下文。
 * @param fileUri 本地文件或相册资源地址。
 * @param mimeType 文件 MIME 类型。
 * @returns 上传接口需要的字节数组。
 */
export async function readUploadPayload(context: common.UIAbilityContext, fileUri: string, mimeType: string): Promise<ArrayBuffer> {
  if (isPhotoAssetUri(fileUri) && mimeType.indexOf('image/') === 0) {
    return await readPhotoAssetData(context, fileUri)
  }
  return readGenericFileData(fileUri)
}
