#!/bin/sh

# Ensure ADSP module is loaded and Type-C USB busses are reset before
# filesystems are mounted

if grep -q -E 'qcom,sc8280xp-adsp-pas|qcom,x1e80100-adsp-pas' \
    /sys/bus/platform/devices/*.remoteproc/modalias 2> /dev/null; then
    modprobe qcom_q6v5_pas
fi
