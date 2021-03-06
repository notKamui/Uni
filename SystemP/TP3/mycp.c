#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define SSIZE_MAX 1048576 // 1MiB

int main(int argc, char **argv) {
    size_t size;
    int fd;
    char buffer[SSIZE_MAX];
    if (argc != 3) {
        printf("Missing argument, aborting\n");
        return EXIT_FAILURE;
    }

    if((fd = open(argv[1], O_RDONLY)) == -1) {
        printf("Error while opening file, aborting\n");
        return EXIT_FAILURE;
    }
    size = read(fd, buffer, SSIZE_MAX);
    close(fd);

    if((fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IXUSR | S_IROTH)) == -1) {
        printf("Error while opening file, aborting\n");
        return EXIT_FAILURE;
    }
    write(fd, buffer, size);
    close(fd);

    return EXIT_SUCCESS;
}