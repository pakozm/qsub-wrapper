#!/bin/bash

## MIT License
##
## Copyright (c) 2016 Francisco Zamora-Martinez
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

# qsub-wrapper.sh [--ncores=N] [qsub_args ...] -- command [args ...]

qsub_args="-d $(pwd)"
for arg in "$@"; do
    if [[ $arg == "--" ]]; then
        double_dash=1
    else
        if [[ -z $double_dash ]]; then
            if [[ $arg == --ncores=* ]]; then
                ncores=${arg/--ncores=/}
                qsub_args="-l nodes=1:ppn=$ncores $qsub_args"
            else
                qsub_args="$qsub_args $arg"
            fi
        else # double dash
            command="$command $arg"
        fi
    fi
done

if [[ ( -z $double_dash ) || ( -z $command ) ]]; then
    >&2 echo "Error: a double dash (--) followed by a command is mandatory."
    >&2 echo "    $(basename $0) [--ncores=N] [qsub_args ...] -- command [args ...]"
    exit -1
fi

if [[ -z $ncores ]]; then
    ncores=1
fi

echo "# CORES:     $ncores"
echo "# QSUB ARGS:  $qsub_args"
echo "# RUNNING:   $command"
echo "#!/bin/bash
#PBS -l nice=19
echo \# HOST:       \$(hostname)
echo \# DATE:       \$(date)
echo \# NCORES:     $ncores
echo \# QSUB ARGS:  $qsub_args
echo \# RUNNING:    $command
cd $(pwd);
STARTTIME=\$(date +%s)
$command
ENDTIME=\$(date +%s)
echo \# ELAPSED_TIME: \$((ENDTIME - STARTTIME)) seconds" |
qsub $qsub_args
