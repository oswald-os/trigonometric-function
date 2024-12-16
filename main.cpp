#include "./FuncA.h"
#include <sys/wait.h>
#include <string.h>
extern int CreateHTTPserver();


void sigintHandler(int s)
{
    const char* msg1 = "Caught signal SIGINT. Exiting gracefully...\n";
    const char* msg2 = "\nAll child processes terminated\n";

    fwrite(msg1, sizeof(char), strlen(msg1), stdout);

    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, 0 )) > 0);

    if (pid == -1)
        fwrite(msg2, sizeof(char), strlen(msg2), stdout);

    exit(EXIT_SUCCESS);
}


void sigchldHandler(int s)
{
    const char* msg1 = "Caught signal SIGCHLD. Terminating children...\n";
    const char* msg2 = "\nChild process terminated\n";

    fwrite(msg1, sizeof(char), strlen(msg1), stdout);

    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, WNOHANG )) > 0)
    {
        if (WIFEXITED(status))
            fwrite(msg2, sizeof(char), strlen(msg2), stdout);
    }
}


int main(int argc, char const *argv[]) {
    signal(SIGINT, sigintHandler);
    signal(SIGCHLD, sigchldHandler);

    CreateHTTPserver();

    return 0;
}
