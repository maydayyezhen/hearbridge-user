/**
 * FavoriteApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

/** 收藏接口响应源对象。 */
export interface FavoriteActionResponseSource {
  success?: boolean
}

/** addCourseFavorite。 */
export async function addCourseFavorite(courseCode: string): Promise<ApiResult<FavoriteActionResponseSource>> {
  return await requestApi<FavoriteActionResponseSource>({
    path: `/app/favorite/course/${encodeURIComponent(courseCode)}`,
    method: http.RequestMethod.POST
  })
}

/** removeCourseFavorite。 */
export async function removeCourseFavorite(courseCode: string): Promise<ApiResult<FavoriteActionResponseSource>> {
  return await requestApi<FavoriteActionResponseSource>({
    path: `/app/favorite/course/${encodeURIComponent(courseCode)}`,
    method: http.RequestMethod.DELETE
  })
}

/** addTrainingItemFavorite。 */
export async function addTrainingItemFavorite(itemCode: string): Promise<ApiResult<FavoriteActionResponseSource>> {
  return await requestApi<FavoriteActionResponseSource>({
    path: `/app/favorite/training-item/${encodeURIComponent(itemCode)}`,
    method: http.RequestMethod.POST
  })
}

/** removeTrainingItemFavorite。 */
export async function removeTrainingItemFavorite(itemCode: string): Promise<ApiResult<FavoriteActionResponseSource>> {
  return await requestApi<FavoriteActionResponseSource>({
    path: `/app/favorite/training-item/${encodeURIComponent(itemCode)}`,
    method: http.RequestMethod.DELETE
  })
}
