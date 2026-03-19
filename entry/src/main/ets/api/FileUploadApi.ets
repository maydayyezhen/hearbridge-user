import common from '@ohos.app.ability.common'
import http from '@ohos.net.http'
import fileIo from '@ohos.file.fs'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import dataSharePredicates from '@ohos.data.dataSharePredicates'
import { recordApiDebug, stringifyDebugBody } from './ApiDebug'

export interface UploadApiResult {
  code: number
  message: string
  data: string | null
  rawBody: string
  ok: boolean
  httpCode: number
}

interface UploadEnvelope {
  code: number
  message: string
  data: string | null
}

class FetchOptionsWrapper {
  fetchColumns: Array<string>
  predicates: dataSharePredicates.DataSharePredicates

  constructor(fetchColumns: Array<string>, predicates: dataSharePredicates.DataSharePredicates) {
    this.fetchColumns = fetchColumns
    this.predicates = predicates
  }
}

class RequestOptionsWrapper {
  deliveryMode: photoAccessHelper.DeliveryMode

  constructor(deliveryMode: photoAccessHelper.DeliveryMode) {
    this.deliveryMode = deliveryMode
  }
}

class UploadDebugBody {
  contentType: string
  uploadMode: string
  localUri: string
  fileName: string
  mimeType: string

  constructor(contentType: string, uploadMode: string, localUri: string, fileName: string, mimeType: string) {
    this.contentType = contentType
    this.uploadMode = uploadMode
    this.localUri = localUri
    this.fileName = fileName
    this.mimeType = mimeType
  }
}

function normalizeBaseUrl(baseUrl: string): string {
  return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
}

function parseUploadResult(httpCode: number, rawBody: string): UploadApiResult {
  try {
    const parsed = JSON.parse(rawBody) as UploadEnvelope
    const code = Number(parsed.code ?? httpCode)
    const message = String(parsed.message ?? '')
    const data = typeof parsed.data === 'string' ? parsed.data : null
    return {
      code,
      message,
      data,
      rawBody,
      ok: httpCode === 200 && code === 200 && data !== null,
      httpCode
    }
  } catch (_error) {
    return {
      code: httpCode,
      message: rawBody,
      data: null,
      rawBody,
      ok: false,
      httpCode
    }
  }
}

function isPhotoAssetUri(uri: string): boolean {
  return uri.indexOf('file://media/Photo') === 0 || uri.indexOf('datashare://') === 0
}

function sliceBuffer(buffer: ArrayBuffer, size: number): ArrayBuffer {
  if (size >= buffer.byteLength) {
    return buffer
  }
  return buffer.slice(0, size)
}

async function readPhotoAssetData(context: common.UIAbilityContext, sourceUri: string): Promise<ArrayBuffer> {
  const helper = photoAccessHelper.getPhotoAccessHelper(context)
  const predicates = new dataSharePredicates.DataSharePredicates()
  predicates.equalTo(photoAccessHelper.PhotoKeys.URI, sourceUri)
  const fetchOptions = new FetchOptionsWrapper([photoAccessHelper.PhotoKeys.URI], predicates)
  const fetchResult = await helper.getAssets(fetchOptions as photoAccessHelper.FetchOptions)

  try {
    if (fetchResult.getCount() < 1) {
      throw new Error('Photo asset not found')
    }

    const asset = await fetchResult.getFirstObject()
    return await new Promise<ArrayBuffer>((resolve, reject) => {
      photoAccessHelper.MediaAssetManager.requestImageData(
        context,
        asset,
        new RequestOptionsWrapper(photoAccessHelper.DeliveryMode.FAST_MODE) as photoAccessHelper.RequestOptions,
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

function readGenericFileData(sourceUri: string): ArrayBuffer {
  const file = fileIo.openSync(sourceUri, fileIo.OpenMode.READ_ONLY)
  try {
    const stat = fileIo.statSync(file.fd)
    const size = Number(stat.size)
    if (size <= 0) {
      return new ArrayBuffer(0)
    }
    const buffer = new ArrayBuffer(size)
    const readSize = fileIo.readSync(file.fd, buffer)
    return sliceBuffer(buffer, readSize)
  } finally {
    fileIo.closeSync(file)
  }
}

async function readUploadBytes(context: common.UIAbilityContext, fileUri: string, mimeType: string): Promise<ArrayBuffer> {
  if (isPhotoAssetUri(fileUri) && mimeType.indexOf('image/') === 0) {
    return await readPhotoAssetData(context, fileUri)
  }
  return readGenericFileData(fileUri)
}

export async function uploadFileToServer(context: common.UIAbilityContext, baseUrl: string, token: string, fileUri: string,
  fileName: string, mimeType: string): Promise<UploadApiResult> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/file/upload/binary`
  const debugBody = stringifyDebugBody(new UploadDebugBody('application/octet-stream',
    isPhotoAssetUri(fileUri) ? 'binary-photo-asset' : 'binary-file-read', fileUri, fileName, mimeType))
  const requestInstance = http.createHttp()

  try {
    const payload = await readUploadBytes(context, fileUri, mimeType)
    if (payload.byteLength <= 0) {
      const emptyError = 'Upload payload is empty'
      recordApiDebug('FileUploadApi', 'POST', requestUrl, token.length > 0, debugBody, emptyError)
      return parseUploadResult(500, emptyError)
    }

    const response = await requestInstance.request(requestUrl, {
      method: http.RequestMethod.POST,
      expectDataType: http.HttpDataType.STRING,
      usingCache: false,
      connectTimeout: 30000,
      readTimeout: 30000,
      header: {
        token,
        Accept: 'application/json',
        'Content-Type': 'application/octet-stream',
        'X-Filename': fileName
      },
      extraData: payload
    })

    const rawBody = typeof response.result === 'string' ? response.result : JSON.stringify(response.result)
    recordApiDebug('FileUploadApi', 'POST', requestUrl, token.length > 0, debugBody, rawBody)
    return parseUploadResult(Number(response.responseCode), rawBody)
  } catch (error) {
    const errorText = `upload request error: ${JSON.stringify(error)}`
    recordApiDebug('FileUploadApi', 'POST', requestUrl, token.length > 0, debugBody, errorText)
    return parseUploadResult(500, errorText)
  } finally {
    requestInstance.destroy()
  }
}
