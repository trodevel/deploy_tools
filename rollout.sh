#!/bin/bash

# $Revision: 2490 $ $Date:: 2015-09-07 #$ $Author: serge $

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

if [ -z "$PACKAGE" ]
then
    echo "ERROR: \$PACKAGE is not defined in the config file"
    exit
fi

if [ -z "$PACKAGE_FILES" ]
then
    echo "ERROR: \$PACKAGE_FILES is not defined in the config file"
    exit
fi

DATUM=$(date -u +%Y%m%d_%H%M)
NAME=${PACKAGE}_$DATUM
ARCNAME=$NAME.tar.gz

source $CONFIG             # need to include config file 2 times in order to pass $NAME, etc.

echo "package       = $PACKAGE"
echo "name          = $NAME"
echo
echo "package files = $PACKAGE_FILES"
echo "post actions  = $PACKAGE_POST_ACTIONS"
echo

tar cfvz $ARCNAME $PACKAGE_FILES

scp $ARCNAME $USERHOST:
error=$?

#echo error=$error

if [ $error -ne "0" ]
then
    echo "ERROR: scp failed, error code $error"
    exit
fi

#exit

ssh $USERHOST "\
mkdir $NAME; \
tar xfvz $ARCNAME -C $NAME; \
ln -sf ~/$NAME ~/$PACKAGE; \
$PACKAGE_POST_ACTIONS; \
"
