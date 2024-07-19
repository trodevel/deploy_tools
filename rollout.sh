#!/bin/bash

# $Revision: 11451 $ $Date:: 2019-05-16 #$ $Author: serge $

<<'COMMENT'

Rollout

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
# rollout.sh <rollout_config> <destination_user_host>
#
# rollout_config        - config file to create a package
#
# destination_user_host - name of the output file
#
# Example: rollout.sh config.cfg package.tar.gz
#
#<he>***************************************************************************

show_help()
{
    sed -e '1,/^#<hb>/d' -e '/^#<he>/,$d' $0 | cut -c 3-
}

CONFIG=$1
DEST_USER_HOST=$2

[[ -z "$CONFIG" ]]    && show_help && exit;
[[ -z "$DEST_USER_HOST" ]] && show_help && exit;
[[ ! -f "$CONFIG" ]]  && { echo "ERROR: rollout config $CONFIG does not exist"; exit 1; }

echo "DEBUG: config = $CONFIG"
echo "DEBUG: output = $DEST_USER_HOST"

source $CONFIG

[[ -z "$PACKAGE" ]]          && { echo "ERROR: NAME is not defined in the config file $CONFIG"; exit 1; }
[[ -z "$PACKAGE" ]]          && { echo "ERROR: PACKAGE is not defined in the config file $CONFIG"; exit 1; }
[[ -z "$PACKAGE_DEST_DIR" ]] && { echo "ERROR: PACKAGE_DEST_DIR is not defined in the config file $CONFIG"; exit 1; }

echo "DEBUG: name             = $NAME"
echo "DEBUG: package          = $PACKAGE"
echo "DEBUG: package dest dir = $PACKAGE_DEST_DIR"
echo "DEBUG: post actions     = $PACKAGE_POST_ACTIONS"
echo

DATUM=$(date -u +%Y%m%d_%H%M)
ARCNAME=${NAME}_${DATUM}.tar.gz

scp $PACKAGE $DEST_USER_HOST:$PACKAGE_DEST_DIR/$ARCNAME
error=$?

#echo error=$error

[[ $error -ne 0 ]] && { echo "ERROR: scp failed, error code $error, file $ARCNAME, host $DEST_USER_HOST"; exit 1; }

#exit

ssh $DEST_USER_HOST "\
if [ ! -d $PACKAGE_DEST_DIR ]; then echo 'ROLLOUT: creating $PACKAGE_DEST_DIR'; mkdir $PACKAGE_DEST_DIR; else echo 'ROLLOUT: destination directory $PACKAGE_DEST_DIR exists'; fi; \
cd $PACKAGE_DEST_DIR; \
if [ -d $NAME.prev ]; then echo 'ROLLOUT: removing existing previous package'; rm -rf $NAME.prev; fi; \
if [ -d $NAME ]; then echo 'ROLLOUT: package with the same name EXISTS, renaming to previous'; mv $NAME $NAME.prev; else echo 'ROLLOUT: package is NEW'; fi; \
tar xfz $ARCNAME; \
$PACKAGE_POST_ACTIONS \
"
