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
    if (argc != 2) {
        printf("Missing argument, aborting\n");
        return EXIT_FAILURE;
    }

    if((fd = open(argv[1], O_RDONLY, S_IRUSR | S_IWUSR | S_IXUSR | S_IROTH)) == -1) {
        printf("Error while opening file, aborting\n");
        return EXIT_FAILURE;
    }
    dup2(fd, STDIN_FILENO);
    while(scanf("%s", buffer) != -1) {
        printf("J'ai lu: %s\n", buffer);
    }
    close(fd);


    return EXIT_SUCCESS;
}