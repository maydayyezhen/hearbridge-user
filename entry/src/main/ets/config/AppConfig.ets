/**
 * AppConfig 文件，负责项目配置定义。
 */

/** 当前环境标识。 */
export let APP_ENV: string = 'dev'
/** 开发环境 API 地址。 */
export const DEV_API_BASE_URL: string = 'http://192.168.43.6:8501'
/** 发布环境 API 地址。 */
export const RELEASE_API_BASE_URL: string = ''
/** App 全局后端 API 根地址。 */
export const APP_API_BASE_URL: string = APP_ENV === 'release' ? RELEASE_API_BASE_URL : DEV_API_BASE_URL
/** 是否启用 API 调试浮层。 */
export const ENABLE_API_DEBUG_OVERLAY: boolean = false
/** 是否初始化调试态存储。 */
export const ENABLE_API_DEBUG_STATE: boolean = ENABLE_API_DEBUG_OVERLAY

// 首页/训练入口里默认课程封面占位图：当课程详情还没拿到封面，或本地需要兜底时使用。
export const DEFAULT_COURSE_COVER_URL: string = ''

// 训练模块默认训练封面占位图：用于少数没有返回训练封面时的兜底展示。
export const DEFAULT_TRAINING_COVER_URL: string = ''

// “我的”页面默认头像：用户信息还没返回时，先展示这张默认头像。
export const DEFAULT_USER_AVATAR_URL: string = ''

// “我的”页面默认背景头图：用户尚未设置背景头图时作为默认展示图。
export const DEFAULT_PROFILE_COVER_URL: string = ''
