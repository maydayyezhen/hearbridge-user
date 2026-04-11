/**
 * ConfigApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

/** 首页 Hero 配置源对象。 */
export interface HomeHeroConfigSource {
  title?: string
  subtitle?: string
  mediaUrl?: string
  jumpType?: string
  jumpValue?: string
}

/** 首页推荐课程配置源对象。 */
export interface HomeRecommendConfigSource {
  courseCode?: string
  courseName?: string
  coverUrl?: string
  recommendText?: string
  durationText?: string
  jumpType?: string
  jumpValue?: string
}

export interface AppSplashConfigSource {
  mediaUrl?: string
  title?: string
  subtitle?: string
  jumpType?: string
  jumpValue?: string
}

/** 启动配置响应源对象。 */
export interface BootstrapConfigResponseSource {
  homeHero?: HomeHeroConfigSource
  homeRecommend?: HomeRecommendConfigSource
  appSplash?: AppSplashConfigSource
}

/** getBootstrapConfig。 */
export async function getBootstrapConfig(): Promise<ApiResult<BootstrapConfigResponseSource>> {
  return await requestApi<BootstrapConfigResponseSource>({
    path: '/app/config/bootstrap',
    method: http.RequestMethod.GET
  })
}
