/**
 * 训练运行时共享类型。
 */

/** 训练类型。 */
export type TrainingType = 'speech' | 'gesture'
/** 训练页练习模式。 */
export type PracticeMode = 'audio' | 'video'
/** 训练项状态。 */
export type TrainItemStatus = '' | 'pending' | 'current' | 'in_progress' | 'completed'
