#include "./FuncA.h"
#include <sys/wait.h>
#include <string.h>
extern int CreateHTTPserver();


void sigintHandler(int s)
{
    const char* msg1 = "Caught signal SIGINT. Exiting gracefully...\n";
    const char* msg2 = "\nAll child processes terminated\n";

    write(STDOUT_FILENO, msg1, strlen(msg1));

    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, 0 )) > 0);

    if (pid == -1)
        write(STDOUT_FILENO, msg2, strlen(msg2));

    _exit(EXIT_SUCCESS);
}


void sigchldHandler(int s)
{
    const char* msg1 = "Caught signal SIGCHLD. Terminating children...\n";
    const char* msg2 = "\nChild process terminated\n";

    write(STDOUT_FILENO, msg1, strlen(msg1));

    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, WNOHANG )) > 0)
    {
        if (WIFEXITED(status))
            write(STDOUT_FILENO, msg2, strlen(msg2));
    }
}


int main(int argc, char const *argv[]) {
    signal(SIGINT, sigintHandler);
    signal(SIGCHLD, sigchldHandler);

    CreateHTTPserver();

    return 0;
}
