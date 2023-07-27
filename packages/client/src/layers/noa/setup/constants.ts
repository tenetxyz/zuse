// 4 is very fast
// 8 still runs extremely well
// 12 might be "high" setting
// 16 is the limit before performance issues
export const CHUNK_RENDER_DISTANCE = 3;
export const CHUNK_SIZE = 16;
export const SKY_PLANE_COLOR = [0.6, 0.7, 1]; // The blue plane at the top of the sky that gives it a darker blue color
export const SCENE_COLOR = [0.65, 0.75, 0.85]; // This was carefully chosen so the foggy skyplane fades nicely with the background color of the scene
export const FOG_COLOR = [0.83, 0.88, 1];
export const MIN_CHUNK = 4;
export const MIN_HEIGHT = MIN_CHUNK * CHUNK_SIZE;
