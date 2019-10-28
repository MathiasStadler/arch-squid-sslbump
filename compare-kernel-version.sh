#!/bin/bash

# from here
# https:://coderwall.com/p/khvxca/bash-string-version-comparaison


CURRENT_KERNEL_VERSION_SHORT=$(uname --kernel-release|sed 's/-.*//g')
EXPECTED_KERNEL_VERSION="4.19.0"

verlte() {
    [ "$1" = "$2" ] && return 1 || [  "$2" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $2 $1
}

check_version()
{
    verlt $CURRENT_KERNEL_VERSION_SHORT $EXPECTED_KERNEL_VERSION && echo "Kernel version $CURRENT_KERNEL_VERSION_SHORT is < $EXPECTED_KERNEL_VERSION"
    [[ "$CURRENT_KERNEL_VERSION_SHORT" == $EXPECTED_KERNEL_VERSION ]] && echo "Kernel version $CURRENT_KERNEL_VERSION_SHORT is ~> $EXPECTED_KERNEL_VERSION"
    [[ "$CURRENT_KERNEL_VERSION_SHORT" == $EXPECTED_KERNEL_VERSION ]] && echo "Kernel version $CURRENT_KERNEL_VERSION_SHORT is ~> $EXPECTED_KERNEL_VERSION"
    verlte $CURRENT_KERNEL_VERSION_SHORT $EXPECTED_KERNEL_VERSION && echo "Kernel version $CURRENT_KERNEL_VERSION_SHORT is > $EXPECTED_KERNEL_VERSION"
}

check_version
