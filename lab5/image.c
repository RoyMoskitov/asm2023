void work_image_c(void * from, void * to, int x, int y){
    int i;
    unsigned char *src = from, *dst = to;
    if (x < 0 || y < 0)
        return;
    for (i = 0; i < x * y; i++) {
        dst[i * 4] = 255 - src[i * 4];       // Invert Red
        dst[i * 4 + 1] = 255 - src[i * 4 + 1]; // Invert Green
        dst[i * 4 + 2] = 255 - src[i * 4 + 2]; // Invert Blue
        dst[i * 4 + 3] = src[i * 4 + 3];       // Preserve Alpha
 }
}
