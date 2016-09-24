# qsub-wrapper

A simple wrapper to execute qsub commands from CLI avoiding the
creation of complicated PBS scripts. An intermediate PBS configuration in a
shell string is generated automatically by the wrapper and passed directly to
qsub command.

It can be executed as follows:

```
$ ./qsub-wrapper.sh -N SLEEP_TEST -- sleep 4
# NCORES:     1
# QSUB ARGS:  -d /public/ -N SLEEP_TEST
# RUNNING:    sleep 10
733631.server01
```

And produces as result:

```
$ cat SLEEP_TEST.o733631
# HOST: worker_hostname
# DATE: Sat Sep 24 19:03:01 CEST 2016
# NCORES: 1
# QSUB ARGS: -d /public/ -N SLEEP_TEST
# RUNNING: sleep 10
# ELAPSED_TIME: 10 seconds
```

When executed without arguments it shows a simple help screen:

```
$ ./qsub-wrapper.sh
Error: a double dash (--) followed by a command is mandatory.
    qsub-wrapper.sh [--ncores=N] [qsub_args ...] -- command [args ...]
```

The syntax of this wrapper is:

- After `./qsub_wrapper.sh` you include as many qsub arguments as you want
  (output name, node properties, resources, ...)
- Next you should write `--` (double dash) indicating the end of qsub arguments
  and the start of the command you want to execute.
- Finally you write your command and all the arguments required by this command.

Currently, all jobs are enqueued with `nice=19`, the working directory will be
retrieved by `pwd` command in the moment you execute the wrapper. There is an
optional argument `--ncores=N` which allow to indicate how many cores your
program uses. Given `ncores` option automatically sets the property `-l
nodes=1:ppn=N` in the list of qsub arguments. If `ncores` option is not given,
this wrapper won't set any job property/resource.
