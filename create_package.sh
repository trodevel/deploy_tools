#!/bin/bash

<<'COMMENT'

Create Package

Copyright (C) 2024 Dr. Sergey Kolevatov

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

COMMENT

#<hb>***************************************************************************
#
# create_package.sh <package_config> <output_file>
#
# package_config       - config file to create a package
#
# output_file          - name of the output file
#
# Example: create_package.sh config.cfg package.tar.gz
#
#<he>***************************************************************************

show_help()
{
    sed -e '1,/^#<hb>/d' -e '/^#<he>/,$d' $0 | cut -c 3-
}

CFG=$1
FL_OUT=$2

[[ -z "$CFG" ]]    && show_help && exit;
[[ -z "$FL_OUT" ]] && show_help && exit;
[[ ! -f "$CFG" ]]  && { echo "ERROR: package config does not exist"; exit 1; }

echo "DEBUG: config = $CFG"
echo "DEBUG: output = $FL_OUT"

source "$CFG"

src=$1
dest=$2

[[ -z "$NAME" ]]  &&  { echo "ERROR: package name NAME in not defined in config $CFG"; exit 1; }
[[ -z "$INPUT" ]] &&  { echo "ERROR: input folder INPUT in not defined in config $CFG"; exit 1; }

INPUTS=$( echo $INPUT )

for s in $INPUT
do
    test -d "$s" || { echo "ERROR: source directory $s doesn't exit"; exit 1; }
done

tar -zcvf $FL_OUT $INPUT --transform "s~^~$NAME/~"
