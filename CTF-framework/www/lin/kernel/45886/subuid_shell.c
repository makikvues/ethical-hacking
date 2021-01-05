#define _GNU_SOURCE
#include <unistd.h>
#include <grp.h>
#include <err.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sched.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/prctl.h>
int main(void) {
  int sync_pipe[2];
  char dummy;
  if (socketpair(AF_UNIX, SOCK_STREAM, 0, sync_pipe)) err(1, "pipe");

  pid_t child = fork();
  if (child == -1) err(1, "fork");
  if (child == 0) {
    prctl(PR_SET_PDEATHSIG, SIGKILL);
    close(sync_pipe[1]);
    if (unshare(CLONE_NEWUSER)) err(1, "unshare userns");

    if (write(sync_pipe[0], "X", 1) != 1) err(1, "write to sock");
    if (read(sync_pipe[0], &dummy, 1) != 1) err(1, "read from sock");

    if (setgid(0)) err(1, "setgid");
    if (setuid(0)) err(1, "setuid");

    execl("/bin/bash", "bash", NULL);
    err(1, "exec");
  }

  close(sync_pipe[0]);
  if (read(sync_pipe[1], &dummy, 1) != 1) err(1, "read from sock");

  char cmd[1000];
  sprintf(cmd, "echo deny > /proc/%d/setgroups", (int)child);
  if (system(cmd)) errx(1, "denying setgroups failed");
  sprintf(cmd, "newuidmap %d 0 100000 1000", (int)child);
  if (system(cmd)) errx(1, "newuidmap failed");
  sprintf(cmd, "newgidmap %d 0 100000 1000", (int)child);
  if (system(cmd)) errx(1, "newgidmap failed");

  if (write(sync_pipe[1], "X", 1) != 1) err(1, "write to sock");

  int status;
  if (wait(&status) != child) err(1, "wait");
  return 0;
}
