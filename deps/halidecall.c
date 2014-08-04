#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>
#include <error.h>
#include <errno.h>

void *halide_malloc(void *ctx, size_t);
void halide_free(void *ctx, void *ptr);
int halide_debug_to_file(void *ctx, const char *filename, void *data, int, int, int, int, int, int);
int halide_start_clock(void *ctx);
int64_t halide_current_time_ns(void *ctx);
uint64_t halide_profiling_timer(void *ctx);
int halide_printf(void *ctx, const char *fmt, ...);

void *halide_malloc(void *ctx, size_t len)
{
    void *p;
    int status = posix_memalign(&p, 32, len+64);
    if (status != 0)
	error(status, errno, "posix_memalign failed on allocation of size %ld", len);
    return (void *)((char*)p+32);
}

void halide_free(void *ctx, void *ptr)
{
    free((char *)ptr-32);
}

int halide_printf(void *ctx, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int status = vprintf(fmt, args);
    va_end(args);
    return status;
}
