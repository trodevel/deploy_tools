#!/bin/bash

# $Revision: 11451 $ $Date:: 2019-05-16 #$ $Author: serge $

USER=$1
HOST=$2

CONFIG=./rollout.cfg

show_help()
{
    echo "Usage: rollout.sh USER HOST"
}

if [ -z "$USER" ]
then
    show_help
    exit
fi

if [ -z "$HOST" ]
then
    show_help
    exit
fi

USERHOST=$USER@$HOST

echo "host          = $HOST"
echo "userhost      = $USERHOST"
#exit

if [ ! -f $CONFIG ]
then
    echo "ERROR: config file $CONFIG not found"
    exit
fi

source $CONFIG

[[ -z "$PACKAGE" ]]          && echo "ERROR: \$PACKAGE is not defined in the config file" && exit
[[ -z "$PACKAGE_FILES" ]]    && echo "ERROR: \$PACKAGE_FILES is not defined in the config file" && exit
[[ -z "$PACKAGE_DEST_DIR" ]] && echo "ERROR: \$PACKAGE_DEST_DIR is not defined in the config file" && exit

DATUM=$(date -u +%Y%m%d_%H%M)
NAME=${PACKAGE}_$DATUM
ARCNAME=$NAME.tar.gz

source $CONFIG             # need to include config file 2 times in order to pass $NAME, etc.

echo "package       = $PACKAGE"
echo "name          = $NAME"
echo
echo "package files = $PACKAGE_FILES"
echo "name          = $PACKAGE_DEST_DIR"
echo "post actions  = $PACKAGE_POST_ACTIONS"
echo

tar cfvz $ARCNAME $PACKAGE_FILES --transform "s,^,$PACKAGE/,"

scp $ARCNAME $USERHOST:$PACKAGE_DEST_DIR
error=$?

#echo error=$error

if [ $error -ne "0" ]
then
    echo "ERROR: scp failed, error code $error"
    exit
fi

#exit

ssh $USERHOST "\
if [ ! -d $PACKAGE_DEST_DIR ]; then echo 'ROLLOUT: creating $PACKAGE_DEST_DIR'; mkdir $PACKAGE_DEST_DIR; else echo 'ROLLOUT: destination directory $PACKAGE_DEST_DIR exists'; fi; \
cd $PACKAGE_DEST_DIR; \
if [ -d $PACKAGE.prev ]; then echo 'ROLLOUT: removing existing previous package'; rm -rf $PACKAGE.prev; fi; \
if [ -d $PACKAGE ]; then echo 'ROLLOUT: package with the same name EXISTS, renaming to previous'; mv $PACKAGE $PACKAGE.prev; else echo 'ROLLOUT: package is NEW'; fi; \
tar xfvz $ARCNAME; \
$PACKAGE_POST_ACTIONS \
"

rm $ARCNAME
