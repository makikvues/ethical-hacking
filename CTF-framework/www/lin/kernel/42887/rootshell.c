#define _GNU_SOURCE
#include <linux/capability.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#define die() exit(__LINE__)
static void __attribute__ ((constructor)) status(void) {
    if (dup2(STDIN_FILENO, STDOUT_FILENO) != STDOUT_FILENO) die();
    if (dup2(STDIN_FILENO, STDERR_FILENO) != STDERR_FILENO) die();
    const pid_t pid = getpid();
    if (pid <= 0) die();
    printf("Pid:\t%zu\n", (size_t)pid);
    uid_t ruid, euid, suid;
    gid_t rgid, egid, sgid;
    if (getresuid(&ruid, &euid, &suid)) die();
    if (getresgid(&rgid, &egid, &sgid)) die();
    printf("Uid:\t%zu\t%zu\t%zu\n", (size_t)ruid, (size_t)euid, (size_t)suid);
    printf("Gid:\t%zu\t%zu\t%zu\n", (size_t)rgid, (size_t)egid, (size_t)sgid);
    static struct __user_cap_header_struct header;
    if (capget(&header, NULL)) die();
    if (header.version <= 0) die();
    header.pid = pid;
    static struct __user_cap_data_struct data[2];
    if (capget(&header, data)) die();
    printf("CapInh:\t%08x%08x\n", data[1].inheritable, data[0].inheritable);
    printf("CapPrm:\t%08x%08x\n", data[1].permitted, data[0].permitted);
    printf("CapEff:\t%08x%08x\n", data[1].effective, data[0].effective);
    fflush(stdout);
    for (;;) sleep(10);
    die();
}