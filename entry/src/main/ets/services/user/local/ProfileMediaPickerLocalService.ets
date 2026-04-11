/**
 * 用户资料媒体选择本地服务，负责封装资料页图片选择所需的系统能力调用。
 */

import common from '@ohos.app.ability.common'
import picker from '@ohos.file.picker'

/**
 * 选择单张资料图片。
 * @param context Ability 上下文。
 * @returns 选中的图片资源地址；若用户未选择则返回空字符串。
 */
export async function pickSingleProfileImage(context: common.UIAbilityContext): Promise<string> {
  // context 参数保留用于兼容现有调用签名。
  void context
  const documentPicker = new picker.DocumentViewPicker()
  const documentSelectOptions = new picker.DocumentSelectOptions()
  documentSelectOptions.fileSuffixFilters = ['图片|.jpg,.jpeg,.png,.webp,.bmp,.gif']
  const result = await documentPicker.select(documentSelectOptions) as Array<string>
  if (!result || result.length === 0) return ''
  return result[0]
}
