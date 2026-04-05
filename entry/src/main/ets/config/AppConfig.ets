// App 全局后端 API 根地址：登录、课程、训练、记录、收藏、资料等接口统一走这里。
export const APP_API_BASE_URL: string = 'http://192.168.43.6:8501'

// 首页/训练入口里默认课程封面占位图：当课程详情还没拿到封面，或本地需要兜底时使用。
export const DEFAULT_COURSE_COVER_URL: string =
  'https://placehold.co/400x240/svg?text=Course'

// 训练模块默认训练封面占位图：用于少数没有返回训练封面时的兜底展示。
export const DEFAULT_TRAINING_COVER_URL: string =
  'https://placehold.co/400x240/svg?text=Training'

// “我的”页面默认头像：用户信息还没返回时，先展示这张默认头像。
export const DEFAULT_USER_AVATAR_URL: string =
  'https://placehold.co/400x400/svg?text=Avatar'

// “我的”页面默认背景头图：用户尚未设置背景头图时作为默认展示图。
export const DEFAULT_PROFILE_COVER_URL: string =
  'https://placehold.co/1200x600/svg?text=Cover'
