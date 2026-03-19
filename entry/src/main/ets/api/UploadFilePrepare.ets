import common from '@ohos.app.ability.common'
import fileIo from '@ohos.file.fs'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import dataSharePredicates from '@ohos.data.dataSharePredicates'

export class PreparedUploadFile {
  originalUri: string
  preparedPath: string
  preparedUri: string

  constructor(originalUri: string, preparedPath: string, preparedUri: string) {
    this.originalUri = originalUri
    this.preparedPath = preparedPath
    this.preparedUri = preparedUri
  }
}

class PhotoFetchOptions {
  fetchColumns: Array<string>
  predicates: dataSharePredicates.DataSharePredicates

  constructor(fetchColumns: Array<string>, predicates: dataSharePredicates.DataSharePredicates) {
    this.fetchColumns = fetchColumns
    this.predicates = predicates
  }
}

class MediaRequestOptions {
  deliveryMode: photoAccessHelper.DeliveryMode

  constructor(deliveryMode: photoAccessHelper.DeliveryMode) {
    this.deliveryMode = deliveryMode
  }
}

class ImageDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
  onDataPrepared: (data: ArrayBuffer) => void

  constructor(targetPath: string, resolveFn: () => void, rejectFn: (error: Error) => void) {
    this.onDataPrepared = (data: ArrayBuffer): void => {
      try {
        const file = fileIo.openSync(targetPath,
          fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
        fileIo.writeSync(file.fd, data)
        fileIo.closeSync(file)
        resolveFn()
      } catch (error) {
        rejectFn(error as Error)
      }
    }
  }
}

class VideoPreparedHandler implements photoAccessHelper.MediaAssetDataHandler<boolean> {
  onDataPrepared: (data: boolean) => void

  constructor(resolveFn: () => void, rejectFn: (error: Error) => void) {
    this.onDataPrepared = (data: boolean): void => {
      if (data) {
        resolveFn()
        return
      }
      rejectFn(new Error('Media asset video export returned false'))
    }
  }
}

function decodeIfPossible(text: string): string {
  try {
    return decodeURIComponent(text)
  } catch (_error) {
    return text
  }
}

function sanitizeFileName(fileName: string): string {
  const decoded = decodeIfPossible(fileName)
  const sanitized = decoded.replace(/[^A-Za-z0-9._-]/g, '_')
  if (sanitized.length > 0) {
    return sanitized
  }
  return `upload_${Date.now()}`
}

function ensureUploadDir(context: common.UIAbilityContext): string {
  const uploadDir = `${context.cacheDir}/upload-cache`
  try {
    fileIo.statSync(uploadDir)
  } catch (_error) {
    fileIo.mkdirSync(uploadDir)
  }
  return uploadDir
}

function buildPreparedPath(context: common.UIAbilityContext, fileName: string): string {
  const uploadDir = ensureUploadDir(context)
  return `${uploadDir}/${Date.now()}_${sanitizeFileName(fileName)}`
}

function toFileUri(filePath: string): string {
  if (filePath.startsWith('file://')) {
    return filePath
  }
  return `file://${filePath}`
}

function isPhotoAssetUri(uri: string): boolean {
  return uri.indexOf('file://media/Photo') === 0 || uri.indexOf('datashare://') === 0
}

async function getPhotoAssetByUri(context: common.UIAbilityContext, assetUri: string): Promise<photoAccessHelper.PhotoAsset> {
  const helper = photoAccessHelper.getPhotoAccessHelper(context)
  const predicates = new dataSharePredicates.DataSharePredicates()
  predicates.equalTo(photoAccessHelper.PhotoKeys.URI, assetUri)
  const options = new PhotoFetchOptions([photoAccessHelper.PhotoKeys.URI], predicates)
  const fetchResult = await helper.getAssets(options as photoAccessHelper.FetchOptions)
  try {
    if (fetchResult.getCount() < 1) {
      throw new Error('Photo asset not found')
    }
    return await fetchResult.getFirstObject()
  } finally {
    fetchResult.close()
  }
}

async function preparePhotoAssetFile(context: common.UIAbilityContext, sourceUri: string, fileName: string,
  mimeType: string): Promise<PreparedUploadFile> {
  const asset = await getPhotoAssetByUri(context, sourceUri)
  const preparedPath = buildPreparedPath(context, fileName)
  const preparedUri = toFileUri(preparedPath)
  const requestOptions = new MediaRequestOptions(photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE)
  if (mimeType.startsWith('video/')) {
    await new Promise<void>((resolve, reject) => {
      photoAccessHelper.MediaAssetManager.requestVideoFile(context, asset,
        requestOptions as photoAccessHelper.RequestOptions, preparedUri,
        new VideoPreparedHandler(resolve, reject))
        .catch((error: Error) => reject(error))
    })
  } else {
    await new Promise<void>((resolve, reject) => {
      photoAccessHelper.MediaAssetManager.requestImageData(context, asset,
        requestOptions as photoAccessHelper.RequestOptions, new ImageDataHandler(preparedPath, resolve, reject))
        .catch((error: Error) => reject(error))
    })
  }
  return new PreparedUploadFile(sourceUri, preparedPath, preparedUri)
}

async function prepareGenericUriFile(context: common.UIAbilityContext, sourceUri: string, fileName: string): Promise<PreparedUploadFile> {
  const preparedPath = buildPreparedPath(context, fileName)
  const preparedUri = toFileUri(preparedPath)
  await fileIo.copy(sourceUri, preparedUri)
  return new PreparedUploadFile(sourceUri, preparedPath, preparedUri)
}

export async function prepareUploadFile(context: common.UIAbilityContext, sourceUri: string, fileName: string,
  mimeType: string): Promise<PreparedUploadFile> {
  if (isPhotoAssetUri(sourceUri)) {
    return await preparePhotoAssetFile(context, sourceUri, fileName, mimeType)
  }
  return await prepareGenericUriFile(context, sourceUri, fileName)
}
