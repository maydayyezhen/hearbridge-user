/**
 * 训练页脚手架查询服务，负责组装课程展示信息。
 */
import { getCourseDetailCache } from '../../../repository/course/CourseDetailRepository'
import { getCoursePreview } from '../../../repository/course/CoursePreviewRepository'
import { TrainSessionRuntime } from '../../../repository/train-session/TrainSessionRepository'
import { TrainPageCourseDisplay } from '../model/TrainPageCourseDisplay'


/**
 * 获取训练页课程展示信息。
 */
export function getTrainPageCourseDisplay(runtime: TrainSessionRuntime): TrainPageCourseDisplay {
  const result = new TrainPageCourseDisplay()
  if (runtime.courseCode.length === 0) {
    return result
  }
  const detail = getCourseDetailCache(runtime.courseCode)
  const preview = getCoursePreview(runtime.courseCode)
  result.courseName = String(detail?.courseName ?? preview?.courseName ?? runtime.courseCode)
  result.courseIntro = String(detail?.intro ?? preview?.intro ?? '')
  result.courseCoverUrl = String(detail?.coverUrl ?? preview?.coverUrl ?? '')
  return result
}
